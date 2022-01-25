`timescale 1ns / 1ns // `timescale time_unit/time_precision

module part2(ClockIn, Reset, Speed, CounterValue);
	input ClockIn, Reset;
	input [1:0] Speed;
	output reg [3:0] CounterValue;
	wire EnableDC;
	
	RateDivider u1(ClockIn, Reset, Speed, EnableDC);
	
	always@(posedge ClockIn)
		if (Reset)
			CounterValue <= 0;
		else if (EnableDC)
			CounterValue <= CounterValue + 1;
endmodule

module RateDivider(ClockIn, Reset, Speed, EnableDC);
	input ClockIn, Reset;
	input [1:0] Speed;
	output reg EnableDC;
	reg [10:0] Counter, ParallelLoad;
	
	always@(*) // Automarker clock frequency 500 Hz 
		if (Speed == 0) // Follow 500 Hz frequency
			ParallelLoad <= 0;
		else if (Speed == 2'b01) // 1 pulse per second; count 499 periods
			ParallelLoad <= 11'b00111110011;
		else if (Speed == 2'b10) // 1 pulse per two seconds; count 999 periods
			ParallelLoad <= 11'b01111100111;
		else if (Speed == 2'b11) // 1 pulse per four seconds, count 1999 periods
			ParallelLoad <= 11'b11111001111;
	
	always@(negedge ClockIn)
		if (EnableDC == 1) // Reset EnableDC if previously enabled
			EnableDC <= 0;
		else if (!Counter) // If 0 reached, enable EnableDC and reset counter
			begin
				EnableDC <= 1;
				Counter <= ParallelLoad;
			end
		else // If 0 not reached, count down
			Counter <= Counter - 1;
	
	always@(posedge ClockIn)
		if (Reset == 1) // Synchronous active high reset
			begin
				EnableDC <= 0;
				Counter <= ParallelLoad;
			end
		else if (EnableDC == 1 && ParallelLoad == 0)
			EnableDC <= 0;
endmodule