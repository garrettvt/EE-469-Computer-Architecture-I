//Leonard Dul and Garrett Tashiro
//November 28, 2021
//EE 469
//Lab 4

`timescale 1ns/10ps 

//IF_reg takes 1-bit clk, 32-bit inst, and 64-bit PCin as inputs
//and returns 32-bit inst_out, and 64-bit PCout as outputs. This
//module implements the IF pipeline register, and uses generateDFFs
//module to pass the multi-bit values through DFF's and delay them
//for a clock cycle.
module IF_reg (inst, inst_out, PCin, PCout, clk);
		input  logic 	     clk;
		input  logic [31:0] inst;
		input	 logic [63:0] PCin;
	   output logic [31:0] inst_out;
		output logic [63:0] PCout;
		
		//generateDFFs modules for multi-bit input/output logic.
		//Passes values through a register to delay for a clock
		//cycle.
		generateDFFs #(.bitz(32)) IF_dffs (.data_in(inst), .data_out(inst_out), .clk);
	   generateDFFs #(.bitz(64)) PC_dffs (.data_in(PCin), .data_out(PCout), .clk);
endmodule


//IF_reg_testbench tests for expected and unexpected behavior.
//This module first sets the input values to 0 and waits 3
//clock cycles. After that all input values are changed to 
//non-zero values and then waits for 3 clock cycles. This is 
//done to make sure that all outputs update correctly. 
module IF_reg_testbench();
		logic 	    clk;
		logic [31:0] inst;
		logic [63:0] PCin;
	   logic [31:0] inst_out;
		logic [63:0] PCout;
		
		IF_reg dut(.*);
		
		// Set up a simulated clock.
		parameter CLOCK_PERIOD=10000;
		initial begin
			clk <= 0;
			forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
		end
		
		initial begin
			inst <= 32'd0; PCin <= 64'd0;		repeat(3) @(posedge clk);
			inst <= 32'd15; PCin <= 64'd20;  repeat(3) @(posedge clk);
			
			$stop; // End the simulation.
		end
endmodule 