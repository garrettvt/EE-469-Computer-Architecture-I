//Leonard Dul and Garrett Tashiro
//October 23, 2021
//EE 469
//Lab 2

//andModule has 1-bit a, and b as inputs and returns
//1-bit out as the output. This module uses the gate 
//primitive AND to implement a two input AND gate. 

`timescale 1ns/10ps

module andModule(a, b, out);
		input logic 	a, b;
		output logic 	out;
		
		//Gate primitive for an AND gate that takes
		//1-bit a, and b as inputs and returns 1-bit
		//out as the output.
		and #0.05 andIt(out, a, b);
endmodule 

//andModule_testbench tests all cases for a
//two input AND gate.
module andModule_testbench();
		logic		a, b, out;
		
		andModule due(.a, .b, .out);
		
		initial begin
			a = 0; b = 0; 		#10;
			a = 0; b = 1;		#10;
			a = 1; b = 0;		#10;
			a = 1; b = 1;		#10;
		end
endmodule 

