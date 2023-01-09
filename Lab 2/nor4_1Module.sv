//Leonard Dul and Garrett Tashiro
//October 26, 2021
//EE 469
//Lab 2

//nor4_1Module has 2-bit a, and b as inputs and returns
//1-bit out as the output. This module uses hierarchical 
//calls to orModule and norModule to first OR the incoming 
//bits in sets of two and then the outputs from the orModules
//get passed as inputs to the norModule.

`timescale 1ns/10ps

module nor4_1Module(out, a, b);
		input logic [1:0]		a, b;
		output logic			out;
		
		//Two 1-bit logics to hold the outputs from
		//each orModule to be used as inputs for norModule
		logic temp1, temp2;
		
		//orModule takes bit 1 from a and b and ORs them
		//together and holds the output in temp1
		orModule firstNorBase(temp1, a[1], b[1]);
		
		//orModule takes bit 0 from a and b and ORs them
		//together and holds the output in temp2
		orModule secondNorBase(temp2, a[0], b[0]);
		
		//norModule takes the outputs from the orModules
		//as inputs and NORs them to 1-bit out for the output
		norModule finalNorBase  (out, temp1, temp2);
endmodule 

//nor4_1Module_testbench tests 7 cases for when
//the bits for a changes and when the bits for b
//changes to makes sure that NOR is happening correctly
module nor4_1Module_testbench();
		logic [1:0]		a, b;
		logic				out;
		
		nor4_1Module dut(.a, .b, .out);
		
		initial begin
			a = 2'b00; b = 2'b00;		#10;
			a = 2'b01; b = 2'b00;		#10;
			a = 2'b10; b = 2'b00;		#10;
			a = 2'b11; b = 2'b00;		#10;
			b = 2'b01; a = 2'b00;		#10;
			b = 2'b10; a = 2'b00;		#10;
			b = 2'b11; a = 2'b00;		#10;
		end
endmodule
