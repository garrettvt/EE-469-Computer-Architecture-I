//Leonard Dul and Garrett Tashiro
//October 13, 2021
//EE 469
//Lab 1

`timescale 1ns/10ps

// regfile is the main module that connects the decoder, registers, and multiplexors together.

module regfile(RegWrite, WriteRegister, WriteData, ReadRegister1, ReadRegister2, ReadData1, ReadData2, clk);
	input logic clk;
	input logic RegWrite;
	input logic [4:0] WriteRegister;
	input logic [63:0] WriteData;
	input logic [4:0]ReadRegister1;
	input logic [4:0]ReadRegister2;
	output logic [63:0] ReadData1;
	output logic [63:0] ReadData2;
	
	// Logic used to to connect the decoder to the registers. It will select the desired register based on 
	// the decOut value.
	logic [31:0] dec2regConn;
	
	// Logic used to connect the registers to the multiplexors. 2-D array used to represent the specific register
   // sending a 64 bit value.	
	logic [31:0][63:0] data2Mux;
	
	// Hardcode reset to value 0.
	assign reset = 0;
	
	// Instantiate the decoder and connect it to register via dec2regConn.
	decoder5x32 decModule (.regWrite(RegWrite), .regAddr(WriteRegister), .decOut(dec2regConn));
   
	// Generate statement used in order to create 31 registers. 
	genvar i; 
	generate 
		for(i=0; i< 31; i++) begin : eachReg
			DFF_VAR dff_reg (.q(data2Mux[i]), .d(WriteData), .clk(clk), .reset(reset), .enable(dec2regConn[i])); 
		end 
		
		// Makes sure that register 32 will provide a 0 input to multiplexors.
		assign data2Mux[31] = 0;
	endgenerate 
	
	// Instatiate each of the multiplexors and attached their respective ReadRegister and ReadData signals.  
	mux64x32_1 ReadReg1 (.incoming(data2Mux), .select(ReadRegister1), .out(ReadData1));
	
	mux64x32_1 ReadReg2 (.incoming(data2Mux), .select(ReadRegister2), .out(ReadData2));
	
endmodule


// Test bench for Register file
`timescale 1ns/10ps

module regstim(); 		

	parameter ClockDelay = 5000;

	logic	[4:0] 	ReadRegister1, ReadRegister2, WriteRegister;
	logic [63:0]	WriteData;
	logic 			RegWrite, clk;
	logic [63:0]	ReadData1, ReadData2;

	integer i;

	// Your register file MUST be named "regfile".
	// Also you must make sure that the port declarations
	// match up with the module instance in this stimulus file.
	regfile dut (.ReadData1, .ReadData2, .WriteData, 
					 .ReadRegister1, .ReadRegister2, .WriteRegister,
					 .RegWrite, .clk);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

	initial begin
		// Try to write the value 0xA0 into register 31.
		// Register 31 should always be at the value of 0.
		RegWrite <= 5'd0;
		ReadRegister1 <= 5'd0;
		ReadRegister2 <= 5'd0;
		WriteRegister <= 5'd31;
		WriteData <= 64'h00000000000000A0;
		@(posedge clk);
		
		$display("%t Attempting overwrite of register 31, which should always be 0", $time);
		RegWrite <= 1;
		@(posedge clk);

		// Write a value into each  register.
		$display("%t Writing pattern to all registers.", $time);
		for (i=0; i<31; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*64'h0000010204080001;
			@(posedge clk);
			
			RegWrite <= 1;
			@(posedge clk);
		end

		// Go back and verify that the registers
		// retained the data.
		$display("%t Checking pattern.", $time);
		for (i=0; i<32; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*64'h0000000000000100+i;
			@(posedge clk);
		end
		$stop;
	end
endmodule
