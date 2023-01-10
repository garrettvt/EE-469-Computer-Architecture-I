//Leonard Dul and Garrett Tashiro
//November 7, 2021
//lab 3

`timescale 1ns/10ps 


//zeroExtend is a parameterized module that takes a parameterized input
//address that is (len - 1)-bits and returns 64-bit extendAddr. This module
//takes an address and extends it to 64 bits. The extended bits are all zeros.
module zeroExtend #(parameter len = 1)(address, extendAddr);
		input logic [len - 1: 0]	address;
	   output logic [63:0]			extendAddr;	
		
		//1-bit logic zero to hold the value 0
		logic zero;
		assign zero = 0;
		
		//genvar i for the variable in the for loop in the generate statement
		genvar i;
		
		//This generate statement takes the original address that passed in,
		//and assigns the lower bits of extendAddr to the address passed in. 
		//There is a second for loop that assigns the upper remaining bits 
		//of the 64-bit output to 0.
		generate
			for(i = 0; i < len; i++) begin : setAddress
				assign extendAddr[i] = address[i];
			end
		
			for(i = len; i < 64; i++) begin : zeroExtend
				assign extendAddr[i] = zero;
			end
		endgenerate 
endmodule

//zeroExtend_testbench tests expected and unexpected behavior.
//This testbench has five different 10-bit addresses that it tests.
//Each address tested is different, and has the most significant
//bit with either a 1 or a 0.
module zeroExtend_testbench();
	logic [9:0]  	address;
	logic [63:0]	extendAddr;
	
	zeroExtend #(.len(10)) dut(.address, .extendAddr);
	
	initial begin
		address = 10'b0111111111;		#100;
		address = 10'b1000000000;		#100;
		address = 10'b1110010101;		#100;
		address = 10'b0000000000;		#100;
		address = 10'b1111111111;		#100;
	end
endmodule
