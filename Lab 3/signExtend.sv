//Leonard Dul and Garrett Tashiro
//November 6, 2021
//lab 3

`timescale 1ns/10ps 

//signExtend is a parameterized module that takes a parameterized input
//address that is (len - 1)-bits and returns 64-bit extendAddr. This module
//takes an address and extends it to 64 bits. The extended bits are dependent
//on what the most significant bit of the input address is to extend the sign
//of that address. 

module signExtend #(parameter len = 1)(address, extendAddr);
		input logic [len - 1: 0]	address;
	   output logic [63:0]			extendAddr;	
		
		//1-bit logic sign to hold the sign value 
		//(most significant bit) of the input address
		logic sign;
		assign sign = address[len - 1];
		
		//genvar i for the variable in the for loop in the generate statement
		genvar i;
		
		//This generate statement has two for loops to assign the values for 
		//extendedAddr. The first for loop goes from i = 0 to i < len, with
		//len being the parameter of the module for how many bits are in the 
		//input address. This for loop assigns the lower bits of 64-bit extenedAddr.
		//The second for loop assigns the upper bits of extnededAddr with the 
		//most significant bit of the input address.
		generate
			for(i = 0; i < len; i++) begin : setAddress
				assign extendAddr[i] = address[i];
			end
		
			for(i = len; i < 64; i++) begin : signExtend
				assign extendAddr[i] = sign;
			end
		endgenerate 
endmodule

//signExtend_testbench tests for expected and unexpected behavior.
//This testbench tests 5 different 10-bit addresses that have 
//either a 1 or a 0 as the most significant bit to see if the module
//would extend the value of that bit.
module signExtend_testbench();
	logic [9:0]  	address;
	logic [63:0]	extendAddr;
	
	signExtend #(.len(10)) dut(.address, .extendAddr);
	
	initial begin
		address = 10'b0111111111;		#100;
		address = 10'b1000000000;		#100;
		address = 10'b1110010101;		#100;
		address = 10'b0000000000;		#100;
		address = 10'b1111111111;		#100;
	end
endmodule
