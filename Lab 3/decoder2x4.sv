//Leonard Dul and Garrett Tashiro
//October 13, 2021
//EE 469
//Lab 1

`timescale 1ns/10ps

// The 2x4 decoder is used as an enabler in order to determine which of the
// four 3x8 decoders (if any) should be accessed based on the address provided
// by WriteRegister and the regWrite signal.

module decoder2x4(regWrite, regAddr, enable);
	input logic regWrite;
	input logic [4:0] regAddr;
	output logic [3:0] enable;

	logic regAddr4;
	logic regAddr3;
	
	// Use not gates in order to have inverted inputs
	not #0.05 (regAddr4, regAddr[4]);
	not #0.05(regAddr3, regAddr[3]);
	
	// Based on the two MSB's from the WriteRegister (register address) the output "enable"
	// will choose which of the register to store data in.
	and #0.05 (enable[0], regAddr4, regAddr3, regWrite);     
	and #0.05 (enable[1], regAddr4, regAddr[3], regWrite);   
	and #0.05 (enable[2], regAddr[4], regAddr3, regWrite);   
	and #0.05 (enable[3], regAddr[4], regAddr[3], regWrite);                                         
	
endmodule

module decoder2x4_testbench();
	logic regWrite;
	logic [4:0] regAddr;
	logic [3:0] enable;
		
		decoder2x4 dut(.regWrite, .regAddr, .enable);
		
		initial begin
		//Tests that without a regWrite signal that none of the four 3x8 decoders are chosen.
				regWrite = 0; regAddr = 5'b00000; #10;
		//Since enable is a four bit signal, each position in the 4-bit's represents
		//an enabling signal to choose choose one of the four 3x8 decoders. Verifies that
		//MSB's 00 produces 0001
		//MSB's 01 produces 0010
		//MSB's 10 produces 0100
		//MSB's 11 produces 1000
				regWrite = 1; regAddr = 5'b00000; #10;
				regWrite = 1; regAddr = 5'b01000; #10;
				regWrite = 1; regAddr = 5'b10000; #10;
				regWrite = 1; regAddr = 5'b11000; #10;				
		end
endmodule 