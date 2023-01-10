//Leonard Dul and Garrett Tashiro
//October 23, 2021
//EE 469
//Lab 2

//xorModule has 1-bit a, and b as inputs and returns 1-bit out
//as the output. This module uses the gate primitive for an
//xor to implement an xor gate.

`timescale 1ns/10ps

module xorModule(a, b, out);
		input logic 	a, b;
		output logic 	out;
		
		//xor gate primitive that takes in 1-bit a, and b as
		//inputs and outputs 1-bit out. 
		xor #0.05 theXOR(out, a, b);
endmodule 

//xorModule_testbench tests all cases for a 
//two input xor gate. 
module xorModule_testbench();
		logic		a, b, out;
		
		xorModule due(.a, .b, .out);
		
		initial begin
			a = 0; b = 0; 		#10;
			a = 0; b = 1;		#10;
			a = 1; b = 0;		#10;
			a = 1; b = 1;		#10;
		end
endmodule
