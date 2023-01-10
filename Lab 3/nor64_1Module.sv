//Leonard Dul and Garrett Tashiro
//October 26, 2021
//EE 469
//Lab 2

//nor64_1Module has 32-bit a, and b as inputs and returns
//1-bit out as the output. This module uses hierarchical 
//calls to nor32_1Module and uses the gate primitive for
//AND. This module implements a 64 input nor gate. 

`timescale 1ns/10ps

module nor64_1Module(a, b, out);
		input logic [31:0]	a, b;
		output logic			out;
		
		//Two 1-bit logics to hold the output value from
		//both nor8_1Module's.
		logic temp1, temp2;
		
		//nor32_1Module takes bits 16-31 from a and b as inputs
		//and returns 1-bit temp1 as the output.
		nor32_1Module firstNor(temp1, a[31:16], b[31:16]);
		
		//nor32_1Module takes bits 0-15 from a and b as inputs
		//and returns 1-bit temp2 as the output
		nor32_1Module secondNor(temp2, a[15:0], b[15:0]);
		
		//Gate primitive for AND to and the outputs from
		//both nor8_1Module's to check for 0.
		and #0.05 finalNorBase  (out, temp1, temp2);
endmodule 

//nor64_1Module_testbench tests for when both 32-bit
//inputs are 0'ed out, and then has tests for if only
//a has bits that aren't 0, tests for if only b has 
//bits that aren't 0, and then tests for if both a and
//b have bits that aren't 0. 
module nor64_1Module_testbench();
		logic [31:0]	a, b;
		logic 			out;
		
		nor64_1Module dut(.a, .b, .out);
		
		initial begin
			a = 32'd0;   	b= 32'd0;		#10;
			a = 32'd1;   	b= 32'd0;		#10;
			a = 32'd5;   	b= 32'd0;		#10;
			a = 32'd94;  	b= 32'd0;		#10;
			a = 32'd200; 	b= 32'd0;		#10;
			a = 32'd70;  	b= 32'd0;		#10;
			
			a = 32'd700; 	b= 32'd0;		#10;
			a = 32'd64;   	b= 32'd0;		#10;
			a = 32'd1000; 	b= 32'd0;		#10;
			a = 32'd9780; 	b= 32'd0;		#10;
			
			a = 32'd0; 		b= 32'd10;		#10;
			a = 32'd0; 		b= 32'd11;		#10;
			a = 32'd0; 		b= 32'd55;		#10;
			a = 32'd0; 		b= 32'd700;		#10;
			
			a = 32'd45; 	b= 32'd10;		#10;
			a = 32'd12; 	b= 32'd11;		#10;
			a = 32'd90; 	b= 32'd55;		#10;
			a = 32'd69; 	b= 32'd700;		#10;
		end
endmodule 