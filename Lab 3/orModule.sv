//Leonard Dul and Garrett Tashiro
//October 23, 2021
//EE 469
//Lab 2


//orModule has 1-bit a, and b as inputs and returns
//1-bit out as the output. This module uses the OR
//gate primitive to implement a two input OR gate.

`timescale 1ns/10ps

module orModule(out, a, b);
		input logic 	a, b;
		output logic 	out;
		
		//Gate primitive for OR that takes 1-bit a, and
		//b as inputs and returns 1-bit out as the output.
		or #0.05 andIt(out, a, b);
endmodule

//orModule_testbench tests all cases for a
//two input OR gate.
module orModule_testbench();
		logic		a, b, out;
		
		orModule due(.a, .b, .out);
		
		initial begin
			a = 0; b = 0; 		#10;
			a = 0; b = 1;		#10;
			a = 1; b = 0;		#10;
			a = 1; b = 1;		#10;
		end
endmodule 


