//Leonard Dul and Garrett Tashiro
//November 28, 2021
//EE 469
//Lab 4

`timescale 1ns/10ps

//generateDFFs is a parameterized module that takes in 1-bit clk, 
//and parameterized data_in as inputs and returns parameterized output
//data_out. This parameterized module uses a generate statement with 
//the module DFF to have correct number of DFF's for a muti-bit input. 
module generateDFFs #(parameter bitz = 32)(data_in, data_out, clk);
		input logic 					clk;
		input logic  [bitz - 1:0]	data_in;
		output logic [bitz - 1:0]	data_out;
		
		//genvar i for generate statements for loop.
		genvar i; 
		
		//generate statement from 0 to bitz (the parameter variable) that
		//calls DFF module that will delay all the bits for one clock cycle
		generate 
			for(i=0; i< bitz; i++) begin : eachDff
				
				// If selected the data is allowed to be an input to the 64 DFF's.
				
				D_FF dffs (.q(data_out[i]), .d(data_in[i]), .reset(1'b0), .clk); 
			end 
		endgenerate 
endmodule 

//generateDFFs_testbench tests for expected and unexpected behavior. 
//This module  has the parameter be 2, and first sets data_in to 01
//and waits 3 clock cycles. It then sets it to be 10 and waits 3 cycles. 
//It finally sets it to 11 and waits 3 clock cycles to view that the
//output is updating correctly. 
module generateDFFs_testbench();
		logic 		clk;
		logic [1:0] data_in;
		logic [1:0] data_out;
		
		generateDFFs #(.bitz(2)) dut(.*);
		
		// Set up a simulated clock.
		parameter CLOCK_PERIOD=10000;
		initial begin
			clk <= 0;
			forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
		end
		
		initial begin
			data_in <= 2'b01;		repeat(3) @(posedge clk);
			data_in <= 2'b10;		repeat(3) @(posedge clk);
			data_in <= 2'b11;		repeat(3) @(posedge clk);
			
			$stop; // End the simulation.
		end
endmodule 