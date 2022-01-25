`timescale 1ns / 1ns // `timescale time_unit/time_precision

module part2(Clock, Reset_b, Data, Function, ALUout);
	input Clock, Reset_b;
	input [3:0] Data;
	input [2:0] Function;
	output reg [7:0] ALUout;
	
	// I/O wires
	wire [3:0] A, B;
	reg [7:0] out;
	assign A = Data;
	assign B = ALUout[3:0];
	
	// intermediate wires
	wire [3:0] case0_sum, case0_cout, case1_sum;
	wire case1_cout;
	lab3part2 adder(A, B, 1'b0, case0_sum, case0_cout);
	assign {case1_cout, case1_sum} = A + B;
	
	always@(*)
	begin
		case(Function)
			3'b001: out = {3'b0, case1_cout, case1_sum};
			3'b000: out = {3'b0, case0_cout[3], case0_sum};
			3'b010: out = {{4{B[3]}}, B};
			3'b011: out = (|A | |B);
			3'b100: out = (&A & &B);
			3'b101: out = B << A;
			3'b110: out = A * B;
			3'b111: out <= ALUout;
			default: out = 8'b0;
		endcase
	end
	
	always@(posedge Clock)
		begin
			if (Reset_b == 0)
				ALUout <= 0;
			else
				ALUout <= out;
		end
endmodule

// case 0: 4-bit ripple carry adder
module lab3part2(a, b, c_in, s, c_out);
	input [3:0] a, b;
	input c_in;
	output [3:0] s;
	output [3:0] c_out;
	
	fullAdder bit0(a[0], b[0], c_in, s[0], c_out[0]);
    fullAdder bit1(a[1], b[1], c_out[0], s[1], c_out[1]);
    fullAdder bit2(a[2], b[2], c_out[1], s[2], c_out[2]);
	fullAdder bit3(a[3], b[3], c_out[2], s[3], c_out[3]);
endmodule

module fullAdder(a, b, cin, s, cout);
	input a, b, cin;
	output s, cout;
	assign s = cin^a^b;
	assign cout = (a&b) | (cin&a)| (cin&b);
endmodule
