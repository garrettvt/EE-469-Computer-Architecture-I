//Leonard Dul and Garrett Tashiro
//October 26, 2021
//EE 469
//Lab 2

//norModule has 1-bit a, and b as inputs and returns
//1-bit out as the output. This module uses the gate 
//primitive NOR to implement a two input NOR gate.

`timescale 1ns/10ps

module norModule(out, a, b);
		input logic 		a, b;
		output logic 		out;
		
		//Gate primitive for an NOR gate that takes
		//1-bit a, and b as inputs and returns 1-bit
		//out as the output.
		nor #0.05 norGate(out, a, b);
endmodule 

//norModule_testbench tests all cases for a
//two input NOR gate.
module norModule_testbench();
		logic		a, b, out;
		
		norModule dut(.a, .b, .out);
		
		initial begin
			a = 0; b = 0;		#10;
			a = 1; b = 0;		#10;
			a = 0; b = 1;		#10;
			a = 1; b = 1;		#10;
		end
endmodule
