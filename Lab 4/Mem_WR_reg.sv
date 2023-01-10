//Leonard Dul and Garrett Tashiro
//November 28, 2021
//EE 469
//Lab 4

`timescale 1ns/10ps 

//Mem_WR_reg takes 1-bit clk, RegWE, 5-bit Rd, and 64-bit DataIn as inputs
//and returns 1-bit RegWE_out, 5-bit Rd_out, and 64-bit DataOut as outputs.
//This module implements the Mem pipeline register. It takes in the inputs
//and delays them for one clock cycle through register modules. D_FF module
//is used for single bit logic, and generateDFFs is used for multi-bit logic.
module Mem_WR_reg (RegWE, RegWE_out, Rd, Rd_out, DataIn, DataOut, clk);
		input  logic 	     clk;
		input  logic	     RegWE;
		input  logic [4:0]  Rd;
		input  logic [63:0] DataIn;
		output logic [4:0]  Rd_out;
		output logic [63:0] DataOut;
	   output logic	     RegWE_out;
		
		//D_FF modules for single bit input/output logic.
		//Passes values through a register to delay for a clock
		//cycle.
		D_FF RegWE_dff   (.q(RegWE_out), .d(RegWE), .reset(1'b0), .clk);
		
		//generateDFFs modules for multi-bit input/output logic.
		//Passes values through a register to delay for a clock
		//cycle.
		generateDFFs #(.bitz(5))  Rd_dffs     (.data_in(Rd), .data_out(Rd_out), .clk);
		generateDFFs #(.bitz(64)) Data_dffs   (.data_in(DataIn), .data_out(DataOut), .clk);
endmodule

//Mem_WR_reg_testbench tests for expected and unexpected behavior.
//The module first sets all input values to 0 and waits 3 clock
//cycles. After that it changes all input values to non-zero values
//and waits 3 clock cycles. This is to make sure that all outputs
//are correct. 
module Mem_WR_reg_testbench();
		logic 	    clk;
		logic	       RegWE;
		logic [4:0]  Rd;
		logic [63:0] DataIn;
		logic [4:0]  Rd_out;
		logic [63:0] DataOut;
	   logic	       RegWE_out;

		Mem_WR_reg dut(.*);
		
		// Set up a simulated clock.
		parameter CLOCK_PERIOD=10000;
		initial begin
			clk <= 0;
			forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
		end
		
		initial begin
			RegWE <= 1'd0; Rd <= 5'd0; DataIn <= 64'd0;
			
			repeat(3) @(posedge clk);
			
			RegWE <= 1'd1; Rd <= 5'd3; DataIn <= 64'd10;
			
			repeat(3) @(posedge clk);
			
			$stop; // End the simulation.
		end
endmodule 
