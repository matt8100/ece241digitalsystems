`timescale 1ns / 1ns // `timescale time_unit/time_precision

module part3(Clock, Resetn, Go, Divisor, Dividend, Quotient, Remainder);
    input Clock, Resetn, Go;
    input [3:0] Divisor, Dividend;
    output reg [3:0] Remainder, Quotient;

    always@(posedge Clock)
		if (!Resetn)
			begin
				Quotient <= 0;  
				Remainder <= 0;
			end 
		else if (Go)
			begin
				Quotient <= Dividend / Divisor; 
				Remainder <= Dividend % Divisor; 
			end
endmodule