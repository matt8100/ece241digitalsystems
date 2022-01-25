`timescale 1ns / 1ns // `timescale time_unit/time_precision

module part2(a, b, c_in, s, c_out);
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