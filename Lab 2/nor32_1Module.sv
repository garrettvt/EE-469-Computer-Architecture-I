//Leonard Dul and Garrett Tashiro
//October 26, 2021
//EE 469
//Lab 2

//nor32_1Module has 16-bit a, and b as inputs and returns
//1-bit out as the output. This module uses hierarchical 
//calls to nor16_1Module and uses the gate primitive for
//AND. This module implements a 32 input nor gate. 

`timescale 1ns/10ps

module nor32_1Module(out, a, b);
		input logic [15:0]	a, b;
		output logic			out;
		
		//Two 1-bit logics to hold the output value from
		//both nor8_1Module's.
		logic temp1, temp2;
		
		//nor16_1Module takes bits 8-15 from a and b as inputs
		//and returns 1-bit temp1 as the output.
		nor16_1Module firstNor(temp1, a[15:8], b[15:8]);
		
		//nor16_1Module takes bits 0-7 from a and b as inputs
		//and returns 1-bit temp2 as the output.
		nor16_1Module secondNor(temp2, a[7:0], b[7:0]);
		
		//Gate primitive for AND to and the outputs from
		//both nor8_1Module's to check for 0.
		and #0.05 finalNorBase  (out, temp1, temp2);
endmodule 

//nor32_1Module_testbench tests a case when bits coming
//in are all 0, and a few cases in which bits coming in 
//aren't all 0, thus, producings a 0 for the output out. 
module nor32_1Module_testbench();
		logic [15:0]	a, b;
		logic 			out;
		
		nor32_1Module dut(.a, .b, .out);
		
		initial begin
			a = 16'd0;  b= 16'd0;		#10;
			a = 16'd1;  b= 16'd0;		#10;
			a = 16'd5;  b= 16'd0;		#10;
			a = 16'd9;  b= 16'd0;		#10;
			a = 16'd20; b= 16'd0;		#10;
			a = 16'd70; b= 16'd0;		#10;
		end
endmodule
