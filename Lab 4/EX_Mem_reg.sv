//Leonard Dul and Garrett Tashiro
//November 28, 2021
//EE 469
//Lab 4

`timescale 1ns/10ps 

//EX_Mem_reg takes in 1-bit clk, MemWE, Mem2Reg, RegWE, 5-bit Rd 
//and 64-bit mul_mem_in, and Db_in as inputs and returns 1-bit
//MemWE_out, Mem2Reg_out, RegWE_out, 5-bit Rd_out, 64-bit mul_mem_out, 
//and Db_out as outputs. This module implements the Ex/Mem pipeline
//register that calls the D_FF for 1-bit logic, and generateDFFs for 
//multi-bit logic. Al values are passed through DFFs to delay for
//a clock cycle.
module EX_Mem_reg (MemWE, Mem2Reg, RegWE, MemWE_out, Mem2Reg_out, RegWE_out,
						 mul_mem_in, mul_mem_out, Db_in, Db_out, Rd, Rd_out, clk);
		input  logic 	     clk;
		input  logic	     MemWE, Mem2Reg, RegWE;
		input  logic [4:0]  Rd;
		input  logic [63:0] mul_mem_in, Db_in;
		output logic [4:0]  Rd_out;
		output logic [63:0] mul_mem_out, Db_out;
	   output logic		  MemWE_out, Mem2Reg_out, RegWE_out;
		
		//D_FF modules for single bit input/output logic.
		//Passes values through a register to delay for a clock
		//cycle.
		D_FF MemWE_dff   (.q(MemWE_out), .d(MemWE), .reset(1'b0), .clk);
		D_FF Mem2Reg_dff (.q(Mem2Reg_out), .d(Mem2Reg), .reset(1'b0), .clk);
		D_FF RegWE_dff   (.q(RegWE_out), .d(RegWE), .reset(1'b0), .clk);
		
		//generateDFFs modules for multi-bit input/output logic.
		//Passes values through a register to delay for a clock
		//cycle.
		generateDFFs #(.bitz(64)) mulmem_dffs (.data_in(mul_mem_in), .data_out(mul_mem_out), .clk);
		generateDFFs #(.bitz(64)) Db_dffs 	  (.data_in(Db_in), .data_out(Db_out), .clk);
		generateDFFs #(.bitz(5))  Rd_dffs     (.data_in(Rd), .data_out(Rd_out), .clk);
endmodule

//EX_Mem_reg_testbench tests for expected and unexpected behavior.
//This module first starts by setting all inputs to 0 and waiting
//3 clk cycles. After that it sets all input values to non-zero values
//and waits 3 clk cycles to check and see if the outputs update correctly.
module EX_Mem_reg_testbench();
		logic 	    clk;
		logic	       MemWE, Mem2Reg, RegWE;
		logic [4:0]  Rd;
		logic [63:0] mul_mem_in, Db_in;
		logic [4:0]  Rd_out;
		logic [63:0] mul_mem_out, Db_out;
	   logic		    MemWE_out, Mem2Reg_out, RegWE_out;
		
		EX_Mem_reg dut(.*);
		
		// Set up a simulated clock.
		parameter CLOCK_PERIOD=10000;
		initial begin
			clk <= 0;
			forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
		end
		
		initial begin
			MemWE <= 1'd0; Mem2Reg <= 1'd0; RegWE <= 1'd0; Rd <= 5'd0;
			mul_mem_in <= 64'd0; Db_in <= 64'd0;
			
			repeat(3) @(posedge clk);
			
			MemWE <= 1'd1; Mem2Reg <= 1'd1; RegWE <= 1'd1; Rd <= 5'd2;
			mul_mem_in <= 64'd10; Db_in <= 64'd10;
			
			repeat(3) @(posedge clk);
			
			$stop; // End the simulation.
		end
endmodule 
