`timescale 1ns / 1ns // `timescale time_unit/time_precision

module part3(ClockIn, Resetn, Start, Letter, DotDashOut);
	input ClockIn, Resetn, Start;
	input [2:0] Letter;
	output reg DotDashOut;
	reg [11:0] Pattern;
	wire EnableDC;
	
	RateDivider u1(ClockIn, Resetn, EnableDC);
	
	always@(posedge Start) // Sets/overwrites pattern if Start high
		begin
			case(Letter)
				3'b000: Pattern <= 12'b101110000000;
				3'b001: Pattern <= 12'b111010101000;
				3'b010: Pattern <= 12'b111010111010;
				3'b011: Pattern <= 12'b111010100000;
				3'b100: Pattern <= 12'b100000000000;
				3'b101: Pattern <= 12'b101011101000;
				3'b110: Pattern <= 12'b111011101000;
				3'b111: Pattern <= 12'b101010100000;
				default: Pattern <= 12'b0;
			endcase
		end
	
	always@(negedge Resetn, posedge EnableDC)
		if (!Resetn) // active low async reset
			DotDashOut <= 0;
		else
			begin
				DotDashOut <= Pattern[11];
				Pattern <= {Pattern[10:0], Pattern[11]};
			end
		
endmodule

module RateDivider(ClockIn, Reset, EnableDC);
	input ClockIn, Reset;
	output reg EnableDC;
	wire [10:0] ParallelLoad;
	reg [10:0] Counter;
	assign ParallelLoad = 11'b00011111001;
	
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
	
	always@(negedge Reset, posedge ClockIn)
		if (!Reset) // active low async reset
			begin
				EnableDC <= 0;
				Counter <= ParallelLoad; // reset to full speed value
			end
		else if (EnableDC == 1 && ParallelLoad == 0)
			EnableDC <= 0;
endmodule

// 11-bit patterns for A-H
// A: 10111000000 .-
// B: 11101010100 -...
// C: 11101011101 -.-.
// D: 11101010000 -..
// E: 10000000000 .
// F: 10101110100 ..-.
// G: 11101110100 --.
// H: 10101010000 ....