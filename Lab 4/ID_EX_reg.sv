//Leonard Dul and Garrett Tashiro
//November 28, 2021
//EE 469
//Lab 4

`timescale 1ns/10ps 

//ID_EX_reg is the second pipeline register that has 1-bit clk,
//DAddrImm, ALUSrc, MemWE, Mem2Reg, RegWE, shiftIn, LS_in, mul_in,
//setFlagControl, 3-bit ALUOp, 5-bit Rd, 6-bit instIn, 64-bit dataA, 
//dataB, DAddr9Extend, and Imm12Extend as inputs and returns 1-bit 
//DAddrImm_out, ALUSrc_out, MemWE_out, Mem2Reg_out, RegWE_out, 
//shiftOut, LS_out, mul_out, setFlagControl_out, 3-bit ALUOp_out,  
//5-bit Rd_out, 6-bit instOut, 64-bit dataA_out, dataB_out, 
//DAddr9Extend_out, and Imm12Extend_out as outputs. This module
//is passes all necessary flags, and vlaues to the third stage.
//This module calls D_FF and generateDFF to pass the values through
//a DFF to delay values. 
module ID_EX_reg (ALUSrc, ALUOp, MemWE, Mem2Reg, RegWE,
						ALUSrc_out, ALUOp_out, MemWE_out, Mem2Reg_out, 
						RegWE_out, Rd, dataA, dataB, Rd_out, 
						dataA_out, dataB_out, shiftIn, shiftOut,
						instIn, instOut, LS_in, LS_out, mul_in, mul_out,
						setFlagControl, setFlagControl_out, DAddr9Extend,
						DAddr9Extend_out, Imm12Extend, Imm12Extend_out,
						DAddrImm, DAddrImm_out, clk);
						
		input  logic 	clk, DAddrImm;
		input  logic   [2:0]  ALUOp;
		input  logic   [4:0]  Rd;
		input  logic   [5:0]  instIn;
		input	 logic   [63:0] dataA, dataB, DAddr9Extend, Imm12Extend;
		input  logic	ALUSrc, MemWE, Mem2Reg, RegWE, shiftIn, LS_in, mul_in;
		input  logic   setFlagControl;
		output logic   [4:0]  Rd_out;
		output logic   [5:0]  instOut;
		output logic   [2:0]  ALUOp_out;
	   output logic	ALUSrc_out, MemWE_out, Mem2Reg_out, RegWE_out, LS_out, mul_out;
		output logic   shiftOut, DAddrImm_out;
		output logic   [63:0] dataA_out, dataB_out, DAddr9Extend_out, Imm12Extend_out;
		output  logic   setFlagControl_out;
		
		//All DFF's for 1-bit bit values being passed. 
		//This is to delay the values for one clock cycle
		//for 1-bit values;
		D_FF ALUSrc_dff   (.q(ALUSrc_out), .d(ALUSrc), .reset(1'b0), .clk);
		D_FF DAddr_dff    (.q(DAddrImm_out), .d(DAddrImm), .reset(1'b0), .clk);
		D_FF MemWE_dff    (.q(MemWE_out), .d(MemWE), .reset(1'b0), .clk);
		D_FF Mem2Reg_dff  (.q(Mem2Reg_out), .d(Mem2Reg), .reset(1'b0), .clk);
		D_FF RegWE_dff    (.q(RegWE_out), .d(RegWE), .reset(1'b0), .clk);
		D_FF shiftDir_dff (.q(shiftOut), .d(shiftIn), .reset(1'b0), .clk);
		D_FF LS_dff 	   (.q(LS_out), .d(LS_in), .reset(1'b0), .clk);
		D_FF mul_dff 	   (.q(mul_out), .d(mul_in), .reset(1'b0), .clk);
		D_FF flag_dff 	   (.q(setFlagControl_out), .d(setFlagControl), .reset(1'b0), .clk);
		
		//Using generateDFFs for multi-bit values. This is a parameterized module. 
		//This is to delays the values for one clk cycle for multi-bit values.
		generateDFFs #(.bitz(3))  ALUOP_dffs (.data_in(ALUOp), .data_out(ALUOp_out), .clk);
		generateDFFs #(.bitz(5))  Rd_dffs    (.data_in(Rd), .data_out(Rd_out), .clk);
		generateDFFs #(.bitz(6))  inst_dffs  (.data_in(instIn), .data_out(instOut), .clk);
		generateDFFs #(.bitz(64)) dataA_dffs (.data_in(dataA), .data_out(dataA_out), .clk);
		generateDFFs #(.bitz(64)) dataB_dffs (.data_in(dataB), .data_out(dataB_out), .clk);
		generateDFFs #(.bitz(64)) Daddr_dffs (.data_in(DAddr9Extend), .data_out(DAddr9Extend_out), .clk);
		generateDFFs #(.bitz(64)) Imm_dffs   (.data_in(Imm12Extend), .data_out(Imm12Extend_out), .clk);
		
endmodule


//ID_EX_reg_testbench tests for expected and unexpected behavior. 
//This testbench first starts by having all input values set to 0
//and running for 3 clock cycles. The values of inputs are all 
//changed and runs with those values for 3 clock cycles to make 
//sure that all outputs are updating correctly. 
module ID_EX_reg_testbench();
		logic 	clk, DAddrImm;
		logic   [2:0]  ALUOp;
		logic   [4:0]  Rd;
		logic   [5:0]  instIn;
		logic   [63:0] dataA, dataB, DAddr9Extend, Imm12Extend;
		logic	  ALUSrc, MemWE, Mem2Reg, RegWE, shiftIn, LS_in, mul_in;
		logic   setFlagControl;
		logic   [4:0]  Rd_out;
		logic   [5:0]  instOut;
		logic   [2:0]  ALUOp_out;
	   logic	  ALUSrc_out, MemWE_out, Mem2Reg_out, RegWE_out, LS_out, mul_out;
		logic   shiftOut, DAddrImm_out;
		logic   [63:0] dataA_out, dataB_out, DAddr9Extend_out, Imm12Extend_out;
		logic   setFlagControl_out;
		
		ID_EX_reg dut(.*);
		
		// Set up a simulated clock.
		parameter CLOCK_PERIOD=10000;
		initial begin
			clk <= 0;
			forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
		end
		
		initial begin
			ALUSrc <= 1'd0; MemWE <= 1'd0; Mem2Reg <= 1'd0; RegWE <= 1'd0; 
			shiftIn <= 1'd0; LS_in <= 1'd0; mul_in <= 1'd0; DAddrImm <= 1'b0;
			setFlagControl <= 1'd0; ALUOp <= 3'd0; Rd <= 5'd0; instIn <= 6'd0; 
			dataA <= 64'd0; dataB <= 64'd0; DAddr9Extend <= 64'd0; Imm12Extend <= 64'd0;
			
			repeat(3) @(posedge clk);
			
			ALUSrc <= 1'd1; MemWE <= 1'd1; Mem2Reg <= 1'd1; RegWE <= 1'd1; 
			shiftIn <= 1'd1; LS_in <= 1'd1; mul_in <= 1'd1; DAddrImm <= 1'b1;
			setFlagControl <= 1'd1; ALUOp <= 3'd1; Rd <= 5'd1; instIn <= 6'd1; 
			dataA <= 64'd10; dataB <= 64'd10; DAddr9Extend <= 64'd10; Imm12Extend <= 64'd10;
			
			repeat(3) @(posedge clk);
			
			$stop; // End the simulation.
		end
endmodule 