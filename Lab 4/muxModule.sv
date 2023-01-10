//Leonard Dul and Garrett Tashiro
//November 28, 2021
//EE 469
//Lab 4

`timescale 1ns/10ps 

//muxModule has 1-bit controlSig, 64-bit A, and B as inputs
//and returns 64-bit out as the output. This module uses the
//2:1 mux module and a generate statement to generate the muxes 
//needed to choose between two 64-bit values.
module muxModule (A, B, controlSig, out);
		input logic 			controlSig;
		input logic  [63:0]	A,B;
	   output logic [63:0]	out;	
		
		//genvar i for the for loop in the generate statement
		genvar i;
		
		//generate statement with a for loop and a 2:1 mux that picks between
		//two 64-bit values.
		generate 
			for(i= 0; i< 64; i++) begin : each_mux
				mux2_1 forward_mux (.a(A[i]), .b(B[i]), .s(controlSig), .out(out[i])); 
			end 
		endgenerate
	
endmodule 

//muxModule_testbench tests for expected and unexpected behaivor. 
//The testbench first sets controlSig to 0 to see if the correct 
//value is chosen. It then sets controlSig to 1 to see if the 
//correct value is chosen for the output.
module muxModule_testbench();
		logic 			controlSig;
		logic [63:0]	A,B;
	   logic [63:0]	out;
	
	muxModule dut(.A, .B, .controlSig, .out);
	
	initial begin
		A = 64'd30; B = 64'd2; controlSig = 0;	#10;
		A = 64'd30; B = 64'd2; controlSig = 1;	#10;

	end
endmodule
