`timescale 1ns / 1ns // `timescale time_unit/time_precision

module part1(Clock, Enable, Clear_b, CounterValue);
	input Clock, Enable, Clear_b;
	output [7:0] CounterValue;
	
	tflipflop Q0(Clock, Enable, Clear_b, CounterValue[0]);
	tflipflop Q1(Clock, (Enable && CounterValue[0]), Clear_b, CounterValue[1]);
	tflipflop Q2(Clock, (Enable && &CounterValue[1:0]), Clear_b, CounterValue[2]);
	tflipflop Q3(Clock, (Enable && &CounterValue[2:0]), Clear_b, CounterValue[3]);
	tflipflop Q4(Clock, (Enable && &CounterValue[3:0]), Clear_b, CounterValue[4]);
	tflipflop Q5(Clock, (Enable && &CounterValue[4:0]), Clear_b, CounterValue[5]);
	tflipflop Q6(Clock, (Enable && &CounterValue[5:0]), Clear_b, CounterValue[6]);
	tflipflop Q7(Clock, (Enable && &CounterValue[6:0]), Clear_b, CounterValue[7]);
endmodule

module tflipflop(Clock, T, Resetn, Q);
	input Clock, T, Resetn;
	output reg Q;
	
	always@(negedge Resetn, posedge Clock)
		begin
			if (!Resetn)
				Q <= 0;
			else
				begin
					if (T)
						Q <= ~Q;
					else
						Q <= Q;
				end
		end
endmodule