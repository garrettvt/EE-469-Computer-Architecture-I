//Leonard Dul and Garrett Tashiro
//October 13, 2021
//EE 469
//Lab 1

//decoder3x8 has 1-bit enable, 5-bit regAddr as inputs
//and returns 8-bit regOut as an output. This module
//uses gate primitives to implements a 3 by 8 decoder.

`timescale 1ns/10ps

module decoder3x8(regAddr, enable, regOut);
	input logic enable;
	input logic [4:0] regAddr;
	output logic [7:0] regOut;
	
	//three 1-bit logic's to hold nots values
	logic regAddr2;
	logic regAddr1;
	logic regAddr0;
	
	//Getting the not value for regAddr[2:0]
	not #0.05 (regAddr2, regAddr[2]);
	not #0.05 (regAddr1, regAddr[1]);
	not #0.05 (regAddr0, regAddr[0]);
	
	//The AND gates here are used to ensure that each regOut bit is only accessed and true
	//if the first three most LSB's of the regAddr match their corresponding 0-7 value and
	//enable is TRUE.
	and #0.05 (regOut[0], regAddr2, regAddr1, regAddr0, enable);
	and #0.05 (regOut[1], regAddr2, regAddr1, regAddr[0], enable);
	and #0.05 (regOut[2], regAddr2, regAddr[1], regAddr0, enable);
	and #0.05 (regOut[3], regAddr2, regAddr[1], regAddr[0], enable);
	and #0.05 (regOut[4], regAddr[2], regAddr1, regAddr0, enable);
	and #0.05 (regOut[5], regAddr[2], regAddr1, regAddr[0], enable);
	and #0.05 (regOut[6], regAddr[2], regAddr[1], regAddr0, enable);
	and #0.05 (regOut[7], regAddr[2], regAddr[1], regAddr[0], enable);
	
endmodule


module decoder3x8_testbench();
	logic enable;
	logic [4:0] regAddr;
	logic [7:0] regOut;
		
		decoder3x8 dut(.regOut, .regAddr, .enable);
		
		initial begin
		
		// The module will check the three LSB's from 0-7 and make sure they
		// match their postion in the 8-bit regOut as an output.
				enable = 1; regAddr = 5'b00000; #10;
				enable = 1; regAddr = 5'b00001; #10;
				enable = 1; regAddr = 5'b00010; #10;
				enable = 1; regAddr = 5'b00011; #10;
				enable = 1; regAddr = 5'b00100; #10;
				enable = 1; regAddr = 5'b00101; #10;
				enable = 1; regAddr = 5'b00110; #10;
				enable = 1; regAddr = 5'b00111; #10;
		// Check that with a FALSE enable none of the 7:0 bits on regOut are a value of 1
				enable = 0; regAddr = 5'b00111; #10;
		end
endmodule 