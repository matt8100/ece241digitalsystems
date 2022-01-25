`timescale 1ns / 1ns // ModelSim

// FPGA
// Part 2 skeleton
/*
module fill(CLOCK_50,KEY,SW,VGA_CLK,VGA_HS,VGA_VS,VGA_BLANK_N,VGA_SYNC_N,VGA_R,VGA_G,VGA_B);
	input			CLOCK_50;//	50 MHz
	input	[3:0]	KEY;
	input [9:0] SW;
	output VGA_CLK; //	VGA Clock
	output VGA_HS; //	VGA H_SYNC
	output VGA_VS; //	VGA V_SYNC
	output VGA_BLANK_N; //	VGA BLANK
	output VGA_SYNC_N; // VGA SYNC
	output [7:0]	VGA_R; //	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output [7:0]	VGA_G; //	VGA Green[7:0]
	output [7:0]	VGA_B; //	VGA Blue[7:0]
	wire resetn;
	assign resetn = KEY[0];
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	part2 u0(KEY[0], KEY[1], KEY[2], SW[9:7], KEY[3], SW[6:0], CLOCK_50, x, y,colour, writeEn);
endmodule
*/


// FAKE_FPGA
/*
`timescale 1ns / 1ps
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

	part2 u0(KEY[0], KEY[1], KEY[2], SW[9:7], KEY[3], SW[6:0], CLOCK_50, x, y, colour, plot);
endmodule
*/

module part2(iResetn,iPlotBox,iBlack,iColour,iLoadX,iXY_Coord,iClock,oX,oY,oColour,oPlot);
	parameter X_SCREEN_PIXELS = 8'd160;
	parameter Y_SCREEN_PIXELS = 7'd120;

	input wire iResetn, iPlotBox, iBlack, iLoadX;
	input wire [2:0] iColour;
	input wire [6:0] iXY_Coord;
	input wire 	    iClock;
	output wire [7:0] oX;         // VGA pixel coordinates
	output wire [6:0] oY;

	output wire [2:0] oColour;     // VGA pixel colour (0-7)
	output wire 	     oPlot;       // Pixel draw enable
	
	
	wire ld_x, ld_y, ld_plot, ld_black;
	control #(X_SCREEN_PIXELS, Y_SCREEN_PIXELS) c0(iResetn, iPlotBox, iBlack, iClock, iLoadX, ld_x, ld_y, ld_plot, ld_black);
	datapath #(X_SCREEN_PIXELS, Y_SCREEN_PIXELS) d0(iResetn, iColour, iXY_Coord, iClock, oX, oY, oColour, oPlot, ld_x, ld_y, ld_plot, ld_black);
endmodule

module control(iResetn,iPlotBox,iBlack,iClock,iLoadX,ld_x,ld_y,ld_plot,ld_black);
	parameter X_SCREEN_PIXELS = 8'd160;
	parameter Y_SCREEN_PIXELS = 7'd120;
	// Inputs
	input wire iResetn, iPlotBox, iBlack, iClock, iLoadX;

	// Outputs
	output reg ld_x, ld_y, ld_plot, ld_black;

	// Registers
	reg [2:0] current_state, next_state;
	reg [3:0] plotCounter;
	reg [14:0] blackCounter;
    
    localparam  S_LOAD_X        = 3'd0,
                S_LOAD_X_WAIT   = 3'd1,
                S_LOAD_Y        = 3'd2,
                S_LOAD_Y_WAIT   = 3'd3,
                S_PLOT          = 3'd4,
								S_BLACK		    = 3'd5,
								S_BLACK_WAIT    = 3'd6;
				
	// State logic
	always@(*)
		begin
			case(current_state)
				S_LOAD_X:
					begin
						if (iBlack) next_state = S_BLACK;
						else next_state = iLoadX ? S_LOAD_X_WAIT : S_LOAD_X;
					end
				S_LOAD_X_WAIT:
					if (iBlack) next_state = S_BLACK;
					else next_state = iLoadX ? S_LOAD_X_WAIT : S_LOAD_Y;
				S_LOAD_Y:
					if (iBlack) next_state = S_BLACK;
					else next_state = iPlotBox ? S_LOAD_Y_WAIT : S_LOAD_Y;
				S_LOAD_Y_WAIT:
					if (iBlack) next_state = S_BLACK;
					else next_state = iPlotBox ? S_LOAD_Y_WAIT : S_PLOT;
				S_PLOT:
					if (iBlack) next_state = S_BLACK;
					else if (&plotCounter) next_state = S_LOAD_X;
					else next_state = S_PLOT;
				S_BLACK:
					begin
						if (blackCounter == X_SCREEN_PIXELS*Y_SCREEN_PIXELS) next_state = S_LOAD_X;
						else next_state = S_BLACK;
					end
				default: next_state = S_LOAD_X;
			endcase
		end
		
	// Output logic
	always@(*)
		begin
			ld_x = 0;
			ld_y = 0;
			ld_plot = 0;
			ld_black = 0;
	
			case(current_state)
				S_LOAD_X: ld_x = 1;
				S_LOAD_Y: ld_y = 1;
				S_PLOT: ld_plot = 1;
				S_BLACK: ld_black = 1;
			endcase
		end
		
	// Register logic
	always@(posedge iClock)
		if (!iResetn)
			begin
				plotCounter <= 0;
				blackCounter <= 0;
				current_state <= S_LOAD_X;
			end
		else
			begin
				if (current_state == S_LOAD_X)
					begin
						plotCounter <= 0;
						blackCounter <= 0;
					end
				if (current_state == S_PLOT) plotCounter <= plotCounter + 1;
				if (current_state == S_BLACK) blackCounter <= blackCounter + 1;
				current_state <= next_state;
			end
endmodule

module datapath(iResetn,iColour,iXY_Coord,iClock,oX,oY,oColour,oPlot,ld_x,ld_y,ld_plot,ld_black);
	parameter X_SCREEN_PIXELS = 8'd160;
	parameter Y_SCREEN_PIXELS = 7'd120;
	// Inputs
	input iResetn, iClock, ld_x, ld_y, ld_plot, ld_black;
	input [2:0] iColour;
	input [6:0] iXY_Coord;

	// Outputs
	output reg [7:0] oX;
	output reg [6:0] oY;
	output reg [2:0] oColour;
	output reg oPlot;
	
	// Registers
	reg [7:0] xCoord, xBlackIter;
	reg [6:0] yCoord, yBlackIter;
	reg [1:0] xIter, yIter;
	
	always@(posedge iClock)
		if (!iResetn) // Sync low reset
			begin
				xCoord <= 0;
				yCoord <= 0;
				xIter <= 0;
				yIter <= 0;
				xBlackIter <= 0;
				yBlackIter <= 0;
			end
		else if (ld_black) // Draw black over whole screen
			begin
				oPlot <= 1;
				oX <= xBlackIter;
				oY <= yBlackIter;
				oColour <= 0;
				xBlackIter <= xBlackIter + 1;
				if (xBlackIter == X_SCREEN_PIXELS) yBlackIter <= yBlackIter + 1;
			end
		else
			begin
				oColour <= iColour;
				if (ld_x) // Load x into register
					begin
						oPlot <= 0;
						xCoord <= {1'b0, iXY_Coord};
					end
				if (ld_y) // Load y into register
					begin
						oPlot <= 0;
						yCoord <= iXY_Coord;
					end
				if (ld_plot)
					begin
						oPlot <= 1;
						oX <= xCoord + xIter;
						oY <= yCoord + yIter;
						xIter <= xIter + 1;
						if (&xIter) yIter <= yIter + 1; // Move down a row
					end
			end
endmodule