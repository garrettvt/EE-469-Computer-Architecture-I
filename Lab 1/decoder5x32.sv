//Leonard Dul and Garrett Tashiro
//October 13, 2021
//EE 469
//Lab 1

`timescale 1ns/10ps

// The 5x32 decoder has one 2x4 decoder that acts as an enable to the four 3x8 decoders.
// By checking the two MSB's of the regAddr the 2x4 can send an enable to each of the
// specific 3x8. The 3x8's will then each output 8 bits that comprise the 32 lines into 
// our top level Mux.

module decoder5x32(regWrite, regAddr, decOut);
	input logic regWrite;
	input logic [4:0] regAddr;
	output logic [31:0] decOut;
	
	logic [3:0] enableConn;
	
	// Creates our enable signal to select one or none of the 3x8 decoders
	decoder2x4 enabler (.regAddr(regAddr[4:0]), .enable(enableConn[3:0]), .regWrite(regWrite));
	
	// If enabled, will pass a single bit from decOut that acts as a signal to select which register
	// is desired.
	decoder3x8 set0_7   (.regAddr(regAddr[4:0]), .enable(enableConn[0]), .regOut(decOut[7:0]));
	decoder3x8 set8_15  (.regAddr(regAddr[4:0]), .enable(enableConn[1]), .regOut(decOut[15:8]));
	decoder3x8 set16_23 (.regAddr(regAddr[4:0]), .enable(enableConn[2]), .regOut(decOut[23:16]));
	decoder3x8 set24_31 (.regAddr(regAddr[4:0]), .enable(enableConn[3]), .regOut(decOut[31:24]));
	
endmodule

module decoder5x32_testbench();

	logic regWrite;
	logic [4:0] regAddr;
	logic [31:0] decOut;
	
 decoder5x32 dut (.regWrite, .regAddr, .decOut);

 initial begin
 
 // Test that every register address given will provide the corresponding decOut signal to 
 // used by it's respective register afterwards.

 regAddr = 5'b00000; regWrite = 1; #10;
 regAddr = 5'b00001; regWrite = 1; #10;
 regAddr = 5'b00010; regWrite = 1; #10;
 regAddr = 5'b00011; regWrite = 1; #10;
 regAddr = 5'b00100; regWrite = 1; #10;
 regAddr = 5'b00101; regWrite = 1; #10;
 regAddr = 5'b00110; regWrite = 1; #10;
 regAddr = 5'b00111; regWrite = 1; #10;
 regAddr = 5'b01000; regWrite = 1; #10;
 regAddr = 5'b01001; regWrite = 1; #10;
 regAddr = 5'b01010; regWrite = 1; #10;
 regAddr = 5'b01011; regWrite = 1; #10;
 regAddr = 5'b01100; regWrite = 1; #10;
 regAddr = 5'b01101; regWrite = 1; #10;
 regAddr = 5'b01110; regWrite = 1; #10;
 regAddr = 5'b01111; regWrite = 1; #10;
 regAddr = 5'b10000; regWrite = 1; #10;
 regAddr = 5'b10001; regWrite = 1; #10;
 regAddr = 5'b10010; regWrite = 1; #10;
 regAddr = 5'b10011; regWrite = 1; #10;
 regAddr = 5'b10100; regWrite = 1; #10;
 regAddr = 5'b10101; regWrite = 1; #10;
 regAddr = 5'b10110; regWrite = 1; #10;
 regAddr = 5'b10111; regWrite = 1; #10;
 regAddr = 5'b11000; regWrite = 1; #10;
 regAddr = 5'b11001; regWrite = 1; #10;
 regAddr = 5'b11010; regWrite = 1; #10;
 regAddr = 5'b11011; regWrite = 1; #10;
 regAddr = 5'b11100; regWrite = 1; #10;
 regAddr = 5'b11101; regWrite = 1; #10;
 regAddr = 5'b11110; regWrite = 1; #10;
 
 // Test that with no enable present, none of the decOut signals will be true.
 regAddr = 5'b00000; regWrite = 0; #10;
 regAddr = 5'b00001; regWrite = 0; #10;
 regAddr = 5'b00010; regWrite = 0; #10;
 regAddr = 5'b00011; regWrite = 0; #10;
 regAddr = 5'b00100; regWrite = 0; #10;
 regAddr = 5'b00101; regWrite = 0; #10;
 regAddr = 5'b00110; regWrite = 0; #10;
 regAddr = 5'b00111; regWrite = 0; #10;
 regAddr = 5'b01000; regWrite = 0; #10;
 regAddr = 5'b01001; regWrite = 0; #10;
 regAddr = 5'b01010; regWrite = 0; #10;
 regAddr = 5'b01011; regWrite = 0; #10;
 regAddr = 5'b01100; regWrite = 0; #10;
 regAddr = 5'b01101; regWrite = 0; #10;
 regAddr = 5'b01110; regWrite = 0; #10;
 regAddr = 5'b01111; regWrite = 0; #10;
 regAddr = 5'b10000; regWrite = 0; #10;
 regAddr = 5'b10001; regWrite = 0; #10;
 regAddr = 5'b10010; regWrite = 0; #10;
 regAddr = 5'b10011; regWrite = 0; #10;
 regAddr = 5'b10100; regWrite = 0; #10;
 regAddr = 5'b10101; regWrite = 0; #10;
 regAddr = 5'b10110; regWrite = 0; #10;
 regAddr = 5'b10111; regWrite = 0; #10;
 regAddr = 5'b11000; regWrite = 0; #10;
 regAddr = 5'b11001; regWrite = 0; #10;
 regAddr = 5'b11010; regWrite = 0; #10;
 regAddr = 5'b11011; regWrite = 0; #10;
 regAddr = 5'b11100; regWrite = 0; #10;
 regAddr = 5'b11101; regWrite = 0; #10;
 regAddr = 5'b11110; regWrite = 0; #10;
 
 end
endmodule
