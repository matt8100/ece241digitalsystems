//`timescale 1ns / 1ns // `timescale time_unit/time_precision

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
	wire [3:0] counter;
	part2 u0(CLOCK_50, SW[9], SW[1:0], counter);
	
	always @(*)
		case(counter)
			4'b0000: HEX0 = 7'b1000000; //0
			4'b0001: HEX0 = 7'b1111001; //1
			4'b0010: HEX0 = 7'b0100100; //2
			4'b0011: HEX0 = 7'b0110000; //3
			4'b0100: HEX0 = 7'b0011001; //4
			4'b0101: HEX0 = 7'b0010010; //5
			4'b0110: HEX0 = 7'b0000010; //6
			4'b0111: HEX0 = 7'b1111000; //7
			4'b1000: HEX0 = 7'b0000000; //8
			4'b1001: HEX0 = 7'b0010000; //9
			4'b1010: HEX0 = 7'b0001000; //A
			4'b1011: HEX0 = 7'b0000011; //b
			4'b1100: HEX0 = 7'b1000110; //C
			4'b1101: HEX0 = 7'b0100001; //d
			4'b1110: HEX0 = 7'b0000110; //E
			4'b1111: HEX0 = 7'b0001110; //F
			default: HEX0 = 7'b0000000;
		endcase
endmodule
*/

module part2(ClockIn, Reset, Speed, CounterValue);
	input ClockIn, Reset;
	input [1:0] Speed;
	output reg [3:0] CounterValue;
	wire EnableDC;
	
	RateDivider #(500) u1(ClockIn, Reset, Speed, EnableDC);
	
	always@(posedge ClockIn)
		if (Reset)
			CounterValue <= 0;
		else if (EnableDC)
			CounterValue <= CounterValue + 1;
endmodule

module RateDivider(ClockIn, Reset, Speed, EnableDC);
	parameter CLOCKS_PER_SECOND = 500;
	input ClockIn, Reset;
	input [1:0] Speed;
	output reg EnableDC;
	reg [25:0] Counter, ParallelLoad;
	
	always@(*) // Automarker clock frequency 500 Hz 
		if (Speed == 0) // Follow 500 Hz frequency
			ParallelLoad <= 0;
		else if (Speed == 2'b01) // 1 pulse per second; count 499 periods
			ParallelLoad <= CLOCKS_PER_SECOND - 1;
		else if (Speed == 2'b10) // 1 pulse per two seconds; count 999 periods
			ParallelLoad <= CLOCKS_PER_SECOND * 2 - 1;
		else if (Speed == 2'b11) // 1 pulse per four seconds, count 1999 periods
			ParallelLoad <= CLOCKS_PER_SECOND * 4 - 1;
	
	always@(negedge ClockIn) // counting periods with falling edges
		if (EnableDC == 1) // Reset EnableDC if previously enabled
			EnableDC <= 0;
		else if (!Counter) // If 0 reached, enable EnableDC and reset counter
			begin
				EnableDC <= 1;
				Counter <= ParallelLoad; // load new/previous speed for next countdown
			end
		else // If 0 not reached, count down
			Counter <= Counter - 1;
	
	always@(posedge ClockIn)
		if (Reset == 1) // Synchronous active high reset
			begin
				EnableDC <= 0;
				Counter <= ParallelLoad; // reset to full speed value
			end
		else if (EnableDC == 1 && ParallelLoad == 0)
			EnableDC <= 0;
endmodule

