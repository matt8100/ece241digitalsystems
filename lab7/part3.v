`timescale 1ns / 1ns // ModelSim

/*
`timescale 1ns / 1ps // fake_fpga
`default_nettype none

module main	(
	input wire CLOCK_50,            //On Board 50 MHz
	input wire [9:0] SW,            // On board Switches
	input wire [3:0] KEY,           // On board push buttons
	output wire [6:0] HEX0,         // HEX displays
	output wire [6:0] HEX1,         
	output wire [6:0] HEX2,         
	output wire [6:0] HEX3,         
	output wire [6:0] HEX4,         
	output wire [6:0] HEX5,         
	output wire [9:0] LEDR,         // LEDs
	output wire [7:0] x,            // VGA pixel coordinates
	output wire [6:0] y,
	output wire [2:0] colour,       // VGA pixel colour (0-7)
	output wire plot,               // Pixel drawn when this is pulsed
	output wire vga_resetn          // VGA resets to black when this is pulsed (NOT CURRENTLY AVAILABLE)
);

   part3 #(.CLOCKS_PER_SECOND(50E6)) u0(SW[9:7], KEY[0], CLOCK_50, x, y, colour, plot);

endmodule*/

module part3(iColour,iResetn,iClock,oX,oY,oColour,oPlot);
   input wire [2:0] iColour;
   input wire iResetn;
   input wire iClock;
   output wire [7:0] oX;         // VGA pixel coordinates
   output wire [6:0] oY;
   output wire [2:0] oColour;     // VGA pixel colour (0-7)
   output wire oPlot;       // Pixel drawn enable

   parameter
     X_SCREENSIZE = 160,  // X screen width for starting resolution and fake_fpga
     Y_SCREENSIZE = 120,  // Y screen height for starting resolution and fake_fpga
     CLOCKS_PER_SECOND = 1200, // 5 KHZ for fake_fpga
     X_BOXSIZE = 8'd4,   // Box X dimension
     Y_BOXSIZE = 7'd4,   // Box Y dimension
     X_MAX = X_SCREENSIZE - 1 - X_BOXSIZE, // 0-based and account for box width
     Y_MAX = Y_SCREENSIZE - 1 - Y_BOXSIZE,
     PULSES_PER_SIXTIETH_SECOND = CLOCKS_PER_SECOND / 60;

   wire ld_plot, ld_erase, ld_next;

   control #(PULSES_PER_SIXTIETH_SECOND) c0(iResetn, iClock, ld_plot, ld_erase, ld_next);
   datapath #(X_MAX, Y_MAX, X_SCREENSIZE, Y_SCREENSIZE) d0(iResetn, iColour, iClock, oX, oY, oColour, oPlot,  ld_plot, ld_erase, ld_next);
   
endmodule

module DelayCounter(iResetn, iClock, DelayClock);
   parameter PULSES_PER_SIXTIETH_SECOND;
   input iResetn, iClock;
   output reg DelayClock;

   reg [29:0] Counter;
      
   always@(negedge iClock, negedge iResetn)
      if (!iResetn)
         begin
            DelayClock <= 0;
            Counter <= PULSES_PER_SIXTIETH_SECOND - 1;
         end
      else if (DelayClock)
         DelayClock <= 0;
      else if (!Counter)
         begin
            DelayClock <= 1;
            Counter <= PULSES_PER_SIXTIETH_SECOND - 1;
         end
      else
         Counter <= Counter - 1;
endmodule

module FrameCounter(iResetn, iClock, DelayClock, FrameClock);
   input iResetn, iClock, DelayClock;
   output reg FrameClock;

   reg [3:0] Counter;
   
   always@(negedge DelayClock, negedge iResetn)
      if (!iResetn)
         begin
            FrameClock <= 0;
            Counter <= 4'd14;
         end
      else if (FrameClock)
         FrameClock <= 0;
      else if (!Counter)
         begin
            FrameClock <= 1;
            Counter <= 4'd14;
         end
      else
         Counter <= Counter - 1;
endmodule

module control(iResetn, iClock, ld_plot, ld_erase, ld_next);
   parameter PULSES_PER_SIXTIETH_SECOND;
	// Inputs
	input wire iResetn, iClock;

   // Outputs
   output reg ld_plot, ld_erase, ld_next;

	// Registers
	reg [2:0] current_state, next_state;
   reg [3:0] eraseCounter, plotCounter;

   reg DelayReset;
   wire DelayClock, FrameClock;
   DelayCounter #(PULSES_PER_SIXTIETH_SECOND) delay0(DelayReset, iClock, DelayClock);
   FrameCounter frame0(DelayReset, iClock, DelayClock, FrameClock);

   localparam  S_PLOT  = 3'd0,
               S_WAIT  = 3'd1,
               S_ERASE = 3'd2,
               S_NEXT  = 3'd3;

   // State Logic
   always@(*)
      begin
         case(current_state)
            S_PLOT: next_state = &plotCounter ? S_WAIT : S_PLOT;
            S_WAIT: next_state = (FrameClock) ? S_ERASE : S_WAIT;
            S_ERASE: next_state = &eraseCounter ? S_NEXT : S_ERASE;
            S_NEXT: next_state = S_PLOT;
            default: next_state = S_PLOT;
         endcase
      end

   // Output Logic
   always@(*)
      begin
         ld_plot = 0;
         ld_erase = 0;
         ld_next = 0;
         DelayReset = 1;
         case(current_state)
            S_PLOT:
               begin
                  ld_plot = 1;
                  DelayReset = 0;
               end
            S_WAIT: DelayReset = 1;
            S_ERASE: ld_erase = 1;
            S_NEXT: ld_next = 1;
         endcase
      end

   // Register Logic
   always@(posedge iClock)
      if (!iResetn)
         begin
            eraseCounter <= 0;
            plotCounter <= 0;
            current_state <= S_PLOT;
         end
      else
         begin
            case(current_state)
               S_PLOT: plotCounter <= plotCounter + 1;
               S_ERASE: eraseCounter <= eraseCounter + 1;
            endcase
            current_state <= next_state;
         end
   
endmodule

module datapath(iResetn, iColour, iClock, oX, oY, oColour, oPlot, ld_plot, ld_erase, ld_next);
	parameter X_MAX, Y_MAX, X_SCREENSIZE, Y_SCREENSIZE;
	// Inputs
	input iResetn, iClock, ld_plot, ld_erase, ld_next;
	input [2:0] iColour;

	// Outputs
	output reg [7:0] oX;
	output reg [6:0] oY;
	output reg [2:0] oColour;
	output reg oPlot;
	
	// Registers
	reg [7:0] CounterX;
	reg [6:0] CounterY;
	reg [1:0] xIter, yIter;
   reg DirX, DirY;
	
	always@(posedge iClock)
		if (!iResetn) // Sync low reset
			begin
				CounterX <= 0;
				CounterY <= 0;
				xIter <= 0;
				yIter <= 0;
            DirX <= 1;
            DirY <= 0;
			end
		else
			begin
            if (ld_plot)
               begin
                  oColour <= iColour;
                  oPlot <= 1;
                  oX <= CounterX + xIter;
                  oY <= CounterY + yIter;
                  xIter <= xIter + 1;
                  if (&xIter) yIter <= yIter + 1;
               end
            if (ld_erase)
               begin
                  oColour <= 0;
                  oPlot <= 1;
                  oX <= CounterX + xIter;
                  oY <= CounterY + yIter;
                  xIter <= xIter + 1;
                  if (&xIter) yIter <= yIter + 1;
               end
            if (ld_next)
               begin
                  oColour <= iColour;
                  oPlot <= 0;
                  // Change direction
                  if ((DirX && CounterX == X_MAX) || (!DirX && CounterX - 1 == 0)) DirX <= ~DirX;
                  if ((!DirY && CounterY == Y_MAX) || (DirY && CounterY - 1 == 0)) DirY <= ~DirY;
                  // Set next position
                  CounterX <= (DirX) ? CounterX + 1 : CounterX - 1;
                  CounterY <= (DirY) ? CounterY - 1 : CounterY + 1;
               end
			end
endmodule
