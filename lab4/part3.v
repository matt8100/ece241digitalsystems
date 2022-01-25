`timescale 1ns / 1ns // `timescale time_unit/time_precision

module part3(clock, reset, ParallelLoadn, RotateRight, ASRight, Data_IN, Q);
	input clock, reset, ParallelLoadn, RotateRight, ASRight;
	input [7:0] Data_IN;
	output reg [7:0] Q;
	
	always@(posedge clock)
		begin
			if (reset == 1) // reset register to 0
				Q <= 0;
			else // reset == 0
				begin
					if (ParallelLoadn == 1) // perform rotation
						begin
							if (RotateRight == 1) // rotate right
								begin
									if (ASRight == 1) // arithmetic shift, keep sign
										Q <= {Q[7], Q[7:1]};
									else // rotate right
										Q <= {Q[0], Q[7:1]};
								end
							else // RotateRight == 0; rotate left
								Q <= {Q[6:0], Q[7]};
						end
					else // ParallelLoadn == 0; load data
						Q <= Data_IN;
				end
		end
endmodule

