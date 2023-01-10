//Leonard Dul and Garrett Tashiro
//November 06, 2021
//EE 469
//Lab 3

`timescale 1ns/10ps 

// lowerData module consists of the regfile, ALU, mult, shifter, and datamem. It used 2:1 muxes 
// that are provided control signals from the processorControl module in order to responded to the
// correct instruction from the upperInst module. The lowerData module also contains zeroExtend and
// signExtend modules in order to create 64-bit data that is passed through the module (dependent on
// the instruction. 

 module lowerData (clk, reset);
	
	input logic clk;
	input logic reset;
	// The control signal for the ALU that determines its mathematical function.
	logic [2:0] ALUOp;
	// This is the instruction signal provided from upperInst module.
	logic [31:0] instruction;
	// The control signals from the processerControl module used to determine the output of the
	// 2:1 muxes.
	logic Reg2Loc, RegWrite, ALUSrc, MemWrite, MemToReg, DAddrImm, UncondBr, BrTaken, logicShift_LR, mul_signal;
	// negative, zero, overflow, carry_out are inputs to flagSetALU module
	// setFlag is an output of flagSetALU, and an input of processorControl
	// CBZ_zero is an output of processorControl, and an input of flagSetALU
	logic negative, zero, overflow, carry_out, setFlag, CBZ_zero;
	// neg_out, zero_out, of_out, co_out are outputs of the flagSetAlu, and inputs of the processorControl
	logic neg_out, zero_out, of_out, co_out;
	
	// This logic is used for the output of the port_Ab muxes
	logic [4:0] mux_Ab;
	// Da, Db are outputs from the regfile, readport1 and readport2
	// Dw is an input to the regile, data write
	// DAddr9Extend is the output of the sign extend module
	// Imm12Extend is the output of the zero extend module
	logic [63:0] Da, Db, Dw, DAddr9Extend, Imm12Extend;
	// ALUSrc_in, ALUSrc_out are inputs and outputs of ALUSrc muxes respectively
	// ALU_out is the output of the ALU, input to the ALUSrc muxes
	logic [63:0] ALUSrc_in, ALUSrc_out, ALU_out;
	// output of datamemory, input to the mem2reg muxes
	logic [63:0] DataMem_out;
	// output of the mult module, input to the mult muxes
	logic [63:0] logicShift;
	// connects the output of the shift muxes to the input of the mult muxes
	logic [63:0] shift2mulMux;
	// connects the output of the mult muxes to the input of the mem2reg muxes
	logic [63:0] mul2memMux;
	// logic for the lower 64-bits of the multiplication
	logic [63:0] multOutput;
	// Unused logic for the upper 64-bits of the multiplication
	logic [63:0] multHighOutput;
	
	// Generate statment used to create 5 muxes for 5-bits of the instrcution pased from upperInst.
	// If Reg2Loc is true it will select the bits for Rm, if false for Rd. It will then pass this to the regfile
	// as a value to ReadRegister2.
	genvar i; 
	generate 
		for(i= 0; i< 5; i++) begin : each_port_Ab
			mux2_1 port_Ab (.a(instruction[i]), .b(instruction[i+16]), .s(Reg2Loc), .out(mux_Ab[i])); 
		end 
	endgenerate
	
	// Instantiates the regfile. RegWrite enables the register to be able to write. WriteRegister seletcs the register
	// to be written to. WriteData provides the data that is being written. ReadRegister1 provides the register from
	// Rn. ReadRegister2 provides the register through Rd or Rm. ReadData1 is the data from register selected by 
	// ReadRegister1. ReadData2 is the data from register selected by ReadRegister1 (either Rd or Rm).
	regfile regLower (.RegWrite(RegWrite), .WriteRegister(instruction[4:0]), .WriteData(Dw), 
							.ReadRegister1(instruction[9:5]), .ReadRegister2(mux_Ab), .ReadData1(Da), .ReadData2(Db), .clk(clk));

	// signExtend module will be used to sign extend the provided data from a LDUR or STUR instruction to 
	// make it 64-bits as it passes through the processor.
	signExtend #(.len(9)) load_store_extend (.address(instruction[20:12]), .extendAddr(DAddr9Extend));
	
	// zeroExtend module will be used to add zeros to the data provided from a ADDI instructions to 
	// make it 64-bits as it passes through the processor.
	zeroExtend #(.len(12)) imm_12_extend (.address(instruction[21:10]), .extendAddr(Imm12Extend));
	
	// Generate statement is used to create 64 muxes to choose either between the 64-bit data of an LDUR/STUR
	// instruction (from signExtend module) or from a ADDI instruction (from zeroExtend module). If the control
	// signal DAddrImm is true then extended data from LDUR/STUR is pased, otherwise extended data from
	// ADDI instruction is passed. 
	generate 
		for(i= 0; i< 64; i++) begin : each_DAddr_Imm_mux
			mux2_1 DAddr_Imm_mux (.a(Imm12Extend[i]), .b(DAddr9Extend[i]), .s(DAddrImm), .out(ALUSrc_in[i])); 
		end 
	endgenerate

	// Generate statement is used to create 64 muxes to choose either between the 64-but data from previously
	// mentioned operations or from Db (the ReadData2 port data from regfile). If ALUSrc signal is true then
	// select the data from DAddr_Imm_mux mucxes, if false from the Db (Rd or Rn based on mux) port.
	generate 
		for(i= 0; i< 64; i++) begin : each_ALUSrc_mux
			mux2_1 ALUSrc_mux (.a(Db[i]), .b(ALUSrc_in[i]), .s(ALUSrc), .out(ALUSrc_out[i])); 
		end 
	endgenerate
	
	// Instantiation of the ALU. It takes the data from the Da(ReadData1 or Rn). Input to cntrl will determine
	// the operation performed. Result is output as ALU_out. Also provides a negative, zero, overflow, carry_out
	// signal based on the result of the operation (sends this to the flagSetALU).
	alu aluMod (.A(Da), .B(ALUSrc_out), .cntrl(ALUOp), .result(ALU_out), .negative, .zero, .overflow, .carry_out);
	
	// Instantiation of the shifter module. Can perform left or right shifts based on the input to direction.
	// Direction is set by control signal from processorControl. Distance shifted is determined by the distance
	// set in the instruction code. LSR and LSL both provide a register to shift data from based on Da (Rn).
	// Output "logicShift" is then fed to shift_mux muxes.
	shifter LSL_LSR (.value(Da), .direction(shiftDir), .distance(instruction[15:10]), .result(logicShift));
	
	// Generate statement is used to create 64 muxes to choose either between the 64-bit data from ALU 
	// or from shifter. If logicShift_LR signal is true then pass the data from the shifter, otherwise
	// pass the data from the ALU.
	generate 
		for(i= 0; i< 64; i++) begin : each_shift_mux
			mux2_1 shift_mux (.a(ALU_out[i]), .b(logicShift[i]), .s(logicShift_LR), .out(shift2mulMux[i])); 
		end 
	endgenerate

	// Instantiation of the mult mod, performs multiplication. Takes data inputs from Da and Db and executes
	// the result pass the lower 64-bits to multOutput and upper 64-bits to multHighOutput. Sincer our 
	// processor is set for odometer math, multHighOutput is sent to dead logic and is not used. Since we
	// are in two's comp the control signal to do signed or unsigned multiplication is not important
	// and arbitraily set to 1.
	mult multMod (.A(Da), .B(Db), .doSigned(1'b1), .mult_low(multOutput), .mult_high(multHighOutput));
	
	// Generate statement is used to create 64 muxes to choose either between the 64-bit data passed from 
	// the shift_mux muxes or from the mult module. If mul_signal signal is true then pass the data from 
	// the mult module (multOutput), otherwise pass the data from shift_mux muxes (shift2mulMux).
	generate 
		for(i= 0; i< 64; i++) begin : each_mul_mux
			mux2_1 mul_mux (.a(shift2mulMux[i]), .b(multOutput[i]), .s(mul_signal), .out(mul2memMux[i])); 
		end 
	endgenerate
	
	// This module takes the signals from the ALU (not included the mathematically computed data).
	// It's purpose inside the module is to deal with ADDS and SUBS signals in order to set the flags.
	// Flags are set when the setFlag input to this module are true. Outputs of this module connect to the
	// processerControl. CBZ_Zero is a control signal passed from processorControl that is specifically for
	// CBZ instructions. Our flagSetALU module is designed to control all signals (minus arithmetic data) from
	// the ALU simultaneously. CBZ instructions require to pass Db through ALU and check if zero, therefore this
	// signal controls a mux in flagSetALU that will bypass the existing mux construction without having to
	// affect the setFlag control signal (thus changing all stored flags).
	flagSetALU theFlags(.setFlag, .CBZ_zero, .neg_in(negative), .zero_in(zero), .of_in(overflow), 
							  .co_in(carry_out), .neg_out, .zero_out, .of_out, .co_out, .clk);
	
	// This is the datamemory module. It takes the address from the output of the mul_mux muxes. It allows
	// a write enable from control signal MemWrite. It allows a read enable from control signal MemToReg.
	// data input to the datamem module is from Db (Rd or Rn). Data output from the module is DataMem_out
	// which is fed to the memReg muxes.
	datamem dataMemMod(.address(mul2memMux), .write_enable(MemWrite), .read_enable(MemToReg), .write_data(Db),
							 .clk(clk), .xfer_size(4'b1000), .read_data(DataMem_out));

	// Generate statement is used to create 64 muxes to choose either between the 64-bit data passed from 
	// the datamemory or from the mul_mux muxes. If MemToReg signal is true then pass the data from 
	// the datamemory (DataMem_out), otherwise pass the data from  mul_mux muxes (mul2memMux). Output is
	// Dw which feeds back into the regfile at WriteData.
	generate 
		for(i= 0; i< 64; i++) begin : each_memReg_mux
			mux2_1 memReg_mux (.a(mul2memMux[i]), .b(DataMem_out[i]), .s(MemToReg), .out(Dw[i])); 
		end 
	endgenerate
	
	// Instantiation of the upperInst module used to update the PC and update the instruction that is fed to the
	// lowerData module. Passes that instruction as "instruction", also takes unCondBr and BrTaken muxes as control
	// signal inputs from processorControl. Passes the data from the instruction neccesary for CondAddr19 and
	// BrAddr26 which are used for conditional and non-conditional instructions respectively (AKA the amount
	// that it has to update the PC counter by for those scenarios).
	upperInst counter (.CondAddr19(instruction[23:5]), .BrAddr26(instruction[25:0]), .UncondBr, .BrTaken, .instr(instruction), .clk, .reset);
	
	// Instantiation of the processorControl unit. This module is used in order to determine the control signals
	// to the muxes. It is passed the OpCode fom each instruction (designed to take OpCodes of different lengths
	// with the knowledge that the largest OpCode is 11 bits). Each output control signal is described in lowerData
	// at its connection point. 
	processorControl  controlUnit (.OpCode(instruction[31:21]), .Reg2Loc, .RegWrite, 
													.ALUSrc, .ALUOp, .MemWrite, 
													.MemToReg, .UncondBr, .BrTaken, 
													.DAddrImm, .zero(zero_out), 
													.neg(neg_out), .o_f(of_out), 
													.setFlag, .logicShift_LR, 
													.mul_signal, .shiftDir, .CBZ_zero);
endmodule
