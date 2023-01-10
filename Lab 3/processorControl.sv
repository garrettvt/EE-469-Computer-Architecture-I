//Leonard Dul and Garrett Tashiro
//November 06, 2021
//EE 469
//Lab 3

`timescale 1ns/10ps

//processorControl takes 1-bit zero, neg, o_f, and 11-bit OpCode
//as inputs and returns 3-bit ALUOp, 1-bit Reg2Loc, RegWrite, ALUSrc, 
//MemWrite, MemToReg, UncondBr, BrTaken, DAddrImm, setFlag, logicShift_LR,
//mul_signal, shiftDir, and CBZ_zero as outputs. This module implements 
//the control logic for our CPU. The module takes in the OpCodes, assigns
//instruction names with values, and has an always_comb block to assign
//outputs for each instruction. 

module processorControl (OpCode, Reg2Loc, RegWrite, 
						ALUSrc, ALUOp, MemWrite, MemToReg, UncondBr, 
						BrTaken, DAddrImm, zero, neg, o_f, setFlag, 
						logicShift_LR, mul_signal, shiftDir, CBZ_zero);

	input logic zero, neg, o_f;
	input logic [10:0] OpCode;
	output logic [2:0] ALUOp;
	output logic Reg2Loc, RegWrite, ALUSrc, MemWrite, MemToReg,
					 UncondBr, BrTaken, DAddrImm, setFlag, logicShift_LR,
					 mul_signal, shiftDir, CBZ_zero;				 
	
	//localparams logic for each instruction.
	//Using an 11 bit logic since the max instruction
	//length is 11 bits, and assigning unused bits
	//to x's. 
	localparam logic [10:0]  ADDI    = 11'b1001000100x, 
									 ADDS    = 11'b10101011000,
									 B_IMM26 = 11'b000101xxxxx,
									 B_LT 	= 11'b01010100xxx,
									 CBZ	   = 11'b10110100xxx,
									 LDUR    = 11'b11111000010,
									 STUR    = 11'b11111000000,
									 SUBS    = 11'b11101011000,
									 LSL		= 11'b11010011011,
									 LSR		= 11'b11010011010,
									 MUL     = 11'b10011011000;
	
	//This always_comb block is to assign the outputs
	//for each instruction based on the OpCode being passed.
	always_comb begin
	  casex (OpCode)
		ADDI : begin
			Reg2Loc   = 1'bx;
			RegWrite  = 1'b1;
			ALUSrc    = 1'b1;
			MemWrite  = 1'b0;
			MemToReg  = 1'b0;
			UncondBr  = 1'bx;
			BrTaken	 = 1'b0;
			DAddrImm  = 1'b0;
			ALUOp     = 3'b010;
			setFlag   = 1'b0;
			logicShift_LR = 1'b0;
			mul_signal = 1'b0;
			shiftDir  = 1'bx;
			CBZ_zero  = 1'b0;
		end

		B_IMM26 : begin
			Reg2Loc   = 1'bx;
			RegWrite  = 1'b0;
			ALUSrc    = 1'bx;
			MemWrite  = 1'b0;
			MemToReg  = 1'bx;
			UncondBr  = 1'b0; // changed based on upperInst
			BrTaken	 = 1'b1;
			DAddrImm  = 1'b0;
			ALUOp     = 3'bxxx; 
			setFlag   = 1'b0;
			logicShift_LR = 1'bx;
   		mul_signal = 1'bx;
			shiftDir  = 1'bx;
			CBZ_zero  = 1'b0;
		end
	  
		CBZ : begin
			Reg2Loc   = 1'b0;
			RegWrite  = 1'b0;
			ALUSrc    = 1'b0;
			MemWrite  = 1'b0;
			MemToReg  = 1'bx;
			UncondBr  = 1'b1;
			BrTaken	 = zero;
			DAddrImm  = 1'b0;
			ALUOp    = 3'b001; //B Bypass? OH the B control sig from lab 2
			setFlag   = 1'b0;  // changed dis
			logicShift_LR = 1'bx;
			mul_signal = 1'bx;
			shiftDir  = 1'bx;
			CBZ_zero  = 1'b1;
		end

		LDUR : begin
			Reg2Loc   = 1'bx;
			RegWrite  = 1'b1;
			ALUSrc    = 1'b1;
			MemWrite  = 1'b0;
			MemToReg  = 1'b1;
			UncondBr  = 1'bx;
			BrTaken	 = 1'b0;
			DAddrImm  = 1'b1;
			ALUOp     = 3'b010; //ADD
			setFlag   = 1'b0;
			logicShift_LR = 1'b0;
			mul_signal = 1'b0;
			shiftDir  = 1'bx;
			CBZ_zero  = 1'b0;
		end
	  
		STUR : begin
			Reg2Loc   = 1'b0;
			RegWrite  = 1'b0;
			ALUSrc    = 1'b1;
			MemWrite  = 1'b1;
			MemToReg  = 1'bx;
			UncondBr  = 1'bx;
			BrTaken	 = 1'b0;
			DAddrImm  = 1'b1;
			ALUOp     = 3'b010; //ADD
			setFlag   = 1'b0;
			logicShift_LR = 1'b0;
			mul_signal = 1'b0;
			shiftDir  = 1'bx;
			CBZ_zero  = 1'b0;
		end
		
		SUBS : begin
			Reg2Loc   = 1'b1;
			RegWrite  = 1'b1;
			ALUSrc    = 1'b0;
			MemWrite  = 1'b0;
			MemToReg  = 1'b0;
			UncondBr  = 1'bx;
			BrTaken	 = 1'b0;
			DAddrImm  = 1'bx;
			ALUOp     = 3'b011; //SUB
			setFlag   = 1'b1;
			logicShift_LR = 1'b0;
			mul_signal = 1'b0;
			shiftDir  = 1'bx;
			CBZ_zero  = 1'b0;
		end
		
		ADDS : begin
			Reg2Loc   = 1'b1;
			RegWrite  = 1'b1;
			ALUSrc    = 1'b0;
			MemWrite  = 1'b0;
			MemToReg  = 1'b0;
			UncondBr  = 1'bx;
			BrTaken	 = 1'b0;
			DAddrImm  = 1'bx;
			ALUOp     = 3'b010; //ADD
			setFlag   = 1'b1;
			logicShift_LR = 1'b0;
			mul_signal = 1'b0;
			shiftDir  = 1'bx;
			CBZ_zero  = 1'b0;
		end
		
		B_LT : begin
			Reg2Loc   = 1'bx;
			RegWrite  = 1'b0;
			ALUSrc    = 1'bx;
			MemWrite  = 1'b0;
			MemToReg  = 1'bx;
			UncondBr  = 1'b1;
			BrTaken	 = (neg != o_f); 
			DAddrImm  = 1'bx;
			ALUOp     = 3'bxxx; //Don't care
			setFlag   = 1'b0;
			logicShift_LR = 1'bx;
			mul_signal = 1'bx;
			shiftDir  = 1'bx;
			CBZ_zero  = 1'b0;
		end
	
		LSL : begin
			Reg2Loc   = 1'b1;
			RegWrite  = 1'b1;
			ALUSrc    = 1'b0;
			MemWrite  = 1'b0;
			MemToReg  = 1'b0;
			UncondBr  = 1'bx;
			BrTaken	 = 1'b0;
			DAddrImm  = 1'bx;
			ALUOp     = 3'b010; //ADD
			setFlag   = 1'b0;
			logicShift_LR = 1'b1;
			mul_signal = 1'b0;
			shiftDir  = 1'b0;
			CBZ_zero  = 1'b0;
		end
		
		LSR : begin
			Reg2Loc   = 1'b1;
			RegWrite  = 1'b1;
			ALUSrc    = 1'b0;
			MemWrite  = 1'b0;
			MemToReg  = 1'b0;
			UncondBr  = 1'bx;
			BrTaken	 = 1'b0;
			DAddrImm  = 1'bx;
			ALUOp     = 3'b010; //ADD
			setFlag   = 1'b0;
			logicShift_LR = 1'b1;
			mul_signal = 1'b0;
			shiftDir  = 1'b1;
			CBZ_zero  = 1'b0;
		end
		
		MUL : begin
			Reg2Loc   = 1'b1;
			RegWrite  = 1'b1;
			ALUSrc    = 1'bx;
			MemWrite  = 1'b0;
			MemToReg  = 1'b0;
			UncondBr  = 1'bx;
			BrTaken	 = 1'b0;
			DAddrImm  = 1'bx;
			ALUOp     = 3'bxxx;
			setFlag   = 1'b0;
			logicShift_LR = 1'b0;
			mul_signal = 1'b1;
			shiftDir  = 1'bx;
			CBZ_zero  = 1'b0;
		end
		 
		default : begin
			Reg2Loc   = 1'bx;
			RegWrite  = 1'b0;
			ALUSrc    = 1'bx;
			MemWrite  = 1'b0;
			MemToReg  = 1'bx;
			UncondBr  = 1'bx;
			BrTaken	 = 1'b0;
			DAddrImm  = 1'bx;
			ALUOp     = 3'bxxx;
			setFlag   = 1'b0;
			logicShift_LR = 1'bx;
			mul_signal = 1'bx;
			shiftDir  = 1'bx;
			CBZ_zero  = 1'b0;
		 end
	  endcase 
	end

endmodule

//processorControl_testbench tests for expected and unexpected behavior.
//This testbench tests each OpCode, and if the intrsution has an output
//that is depended on an input, then that instruction is tested multiple 
//times with the input values cahnging. 
module processorControl_testbench();
	logic zero;
	logic [10:0] OpCode;
	logic [2:0] ALUOp;
	logic Reg2Loc, RegWrite, ALUSrc, MemWrite, MemToReg, 
	      UncondBr, BrTaken, DAddrImm, neg, o_f, setFlag, 
			logicShift_LR, mul_signal, shiftDir, CBZ_zero;
		
		processorControl dut(.OpCode, .Reg2Loc, .RegWrite, 
						.ALUSrc, .ALUOp, .MemWrite, .MemToReg, .UncondBr, 
						.BrTaken, .zero, .DAddrImm, .neg, .o_f, .setFlag, 
						.logicShift_LR, .mul_signal, .shiftDir, .CBZ_zero);
		
		initial begin
		   //B Test
			OpCode = 11'b000101xxxxx; zero = 1'b0; neg <= 1'b0; o_f <= 1'b0;	#10000;
			//LDUR Test
			OpCode = 11'b11111000010; zero = 1'b0; neg <= 1'b0; o_f <= 1'b0;	#10000;
			//STUR Test
			OpCode = 11'b11111000000; zero = 1'b0; neg <= 1'b0; o_f <= 1'b0;	#10000;
			//ADDS Test
			OpCode = 11'b10101011000; zero = 1'b0; neg <= 1'b0; o_f <= 1'b0;	#10000;
			//SUBS Test
			OpCode = 11'b11101011000; zero = 1'b0; neg <= 1'b0; o_f <= 1'b0;	#10000;
			//CBZ Test 1
			OpCode = 11'b10110100xxx; zero = 1'b0; neg <= 1'b0; o_f <= 1'b0;	#10000;
			//CBZ Test 2
			OpCode = 11'b10110100xxx; zero = 1'b1; neg <= 1'b0; o_f <= 1'b0;	#10000;
			//ADDI Test 
			OpCode = 11'b1001000100x; zero = 1'b0; neg <= 1'b0; o_f <= 1'b0;	#10000;
			//LSL Test 
			OpCode = 11'b11010011011; zero = 1'b0; neg <= 1'b0; o_f <= 1'b0;	#10000;
			//LSR Test 
			OpCode = 11'b11010011010; zero = 1'b0; neg <= 1'b0; o_f <= 1'b0;	#10000;
			//MUL Test 
			OpCode = 11'b10011011000; zero = 1'b0; neg <= 1'b0; o_f <= 1'b0;	#10000;
			//B_LT Test 1
			OpCode = 11'b01010100xxx; zero = 1'b0; neg <= 1'b0; o_f <= 1'b0;	#10000;
			//B_LT Test 2
			OpCode = 11'b01010100xxx; zero = 1'b0; neg <= 1'b1; o_f <= 1'b0;	#10000;
			//B_LT Test 3
			OpCode = 11'b01010100xxx; zero = 1'b0; neg <= 1'b0; o_f <= 1'b1;	#10000;
		end
endmodule