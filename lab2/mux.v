`timescale 1ns / 1ns // `timescale time_unit/time_precision

//SW[2:0] data inputs
//SW[9] select signals

//LEDR[0] output display

module mux(LEDR, SW);
    input [9:0] SW;
    output [9:0] LEDR;

    mux2to1 u0(
        .x(SW[0]),
        .y(SW[1]),
        .s(SW[9]),
        .m(LEDR[0])
        );
endmodule

module mux2to1(x, y, s, m);
    input x; //select 0
    input y; //select 1
    input s; //select signal
    output m; //output
	
    // assign m = s & y | ~s & x;
	wire or_gate1, or_gate2, invert_s;
	v7404 invert_gate(.pin1(s), .pin2(invert_s));
	v7408 and_gate(.pin1(s), .pin2(y), .pin3(or_gate1), .pin4(invert_s), .pin5(x), .pin6(or_gate2));
	v7432 or_gate(.pin1(or_gate1), .pin2(or_gate2), .pin3(m));
endmodule

module v7404 (pin1, pin3, pin5, pin9, pin11, pin13,pin2, pin4, pin6, pin8, pin10, pin12);
	input pin1, pin3, pin5, pin9, pin11, pin13;
	output pin2, pin4, pin6, pin8, pin10, pin12;
	assign pin2 = ~pin1;
	assign pin4 = ~pin3;
	assign pin6 = ~pin5;
	assign pin8 = ~pin9;
	assign pin10 = ~pin9;
	assign pin12 = ~pin11;
endmodule

module v7408 (pin1, pin3, pin5, pin9, pin11, pin13,pin2, pin4, pin6, pin8, pin10, pin12);
	input pin1, pin2, pin4, pin5, pin9, pin10, pin12, pin13;
	output pin3, pin6, pin8, pin11;
	assign pin3 = pin1 & pin2;
	assign pin6 = pin4 & pin5;
	assign pin8 = pin9 & pin10;
	assign pin11 = pin12 & pin13;
endmodule

module v7432 (pin1, pin3, pin5, pin9, pin11, pin13,pin2, pin4, pin6, pin8, pin10, pin12);
	input pin1, pin2, pin4, pin5, pin9, pin10, pin12, pin13;
	output pin3, pin6, pin8, pin11;
	assign pin3 = pin1 | pin2;
	assign pin6 = pin4 | pin5;
	assign pin8 = pin9 | pin10;
	assign pin11 = pin12 | pin13;
endmodule