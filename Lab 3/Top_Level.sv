`timescale 1ns/10ps

module Top_Level(regWrite, writeReg, writeData, readReg1, readReg2, readData1, readData2, clk);
	input logic clk;
	input logic regWrite;
	input logic [4:0] writeReg;
	input logic [63:0] writeData;
	input logic [4:0]readReg1;
	input logic [4:0]readReg2;
	output logic [63:0] readData1;
	output logic [63:0] readData2;
	
	logic [30:0] dec2regConn;
	//logic [63:0] reg2muxConn;
	
	decoder5x32 decModule (.regWrite(regWrite), .regAddr(writeReg), .decOut(dec2regConn), .clk);
	regfile regModule (.decIn(dec2regConn[0]), .WriteData(writeData), .data2Mux());   // data2Mux connect to GARRETT FILES
                                         
	
endmodule

module Top_Level_testbench();

	logic clk;
	logic regWrite;
	logic [4:0] writeReg;
	logic [63:0] writeData;
	logic [4:0]readReg1;
	logic [4:0]readReg2;
   logic [63:0] readData1;
	logic [63:0] readData2;
	
 Top_Level dut (.regWrite, .writeReg, .writeData, .readReg1, .readReg2, .readData1, .readData2, .clk);
	
parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end

 // Set up the inputs to the design. Each line is a clock cycle.
 initial begin
 @(posedge clk);
 
 ///////////////////////////////////////////////////
 
 $stop; // End the simulation.
 end
endmodule