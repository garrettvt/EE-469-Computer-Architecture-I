//Leonard Dul and Garrett Tashiro
//October 26, 2021
//EE 469
//Lab 2

//nor8_1Module has 4-bit a, and b as inputs and returns
//1-bit out as the output. This module uses hierarchical 
//calls to nor4_1Module and uses the gate primitive for
//AND. This module implements an 8 input nor gate. 

`timescale 1ns/10ps 

module nor8_1Module(out, a, b);
		input logic [3:0]		a, b;
		output logic			out;
		
		//Two 1-bit logics to hold the output value from
		//both nor4_1Module's.
		logic temp1, temp2;
		
		//nor4_1Module takes bits 2-3 from a and b as inputs
		//and returns 1-bit temp1 as the output. 
		nor4_1Module firstNor(temp1, a[3:2], b[3:2]);
		
		//nor4_1Module takes bits 0-1 from a and b as inputs
		//and returns 1-bit temp2 as the output.
		nor4_1Module secondNor(temp2, a[1:0], b[1:0]);
		
		//Gate primitive for AND to and the outputs from
		//both nor4_1Module's to check for 0.
		and #0.05 finalNorBase  (out, temp1, temp2);
endmodule 


//nor8_1Module_testbench tests multiple cases to see
//if the inputs are lal 0's. 
module nor8_1Module_testbench();
		logic [3:0]		a, b;
		logic 			out;
		
		nor8_1Module dut(.a, .b, .out);
		
		initial begin
			a = 4'b0000; b = 4'b0000;		#10;
			a = 4'b0001; b = 4'b0000;		#10;
			a = 4'b0010; b = 4'b0000;		#10;
			a = 4'b0011; b = 4'b0000;		#10;
			b = 4'b0001; a = 4'b0000;		#10;
			b = 4'b0010; a = 4'b0000;		#10;
			b = 4'b0011; a = 4'b0000;		#10;
			
			a = 4'b1000; b = 4'b0000;		#10;
			a = 4'b1000; b = 4'b1100;		#10;
		end
endmodule
