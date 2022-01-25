`timescale 1ns / 1ns // `timescale time_unit/time_precision

module part1(Clock, Resetn, w, z, CurState);
   input Clock, Resetn, w;
   output z;
   output [3:0] CurState;
   reg [3:0] PS, NS;
    
   localparam A = 4'b0000, B = 4'b0001, C = 4'b0010, D = 4'b0011, E = 4'b0100, F = 4'b0101, G = 4'b0110;
    
	// Next state combinational logic
	always@(*)
	begin: state_table
		case (PS)
			A: begin
				   if (w) NS = B;
				   else NS = A;
			   end
			B: begin
				   if(w) NS = C;
				   else NS = A;
			   end
			C: begin
				   if(w) NS = D;
				   else NS = E;
			   end
			D: begin
				   if(w) NS = F;
				   else NS = E;
			   end
			E: begin
				   if(w) NS = G;
				   else NS = A;
			   end
			F: begin
				   if(w) NS = F;
				   else NS = E;
			   end
			G: begin
				   if(w) NS = C;
				   else NS = A;
			   end
			default: NS = A;
		endcase
	end
    
    // State Registers
    always @(posedge Clock)
    begin: state_FFs
        if(!Resetn) // active low sync reset
            PS <=  A; // Reset state to A
        else
            PS <= NS;
    end

    // Output logic
    assign z = ((PS == F) | (PS == G));
    assign CurState = PS;
endmodule
