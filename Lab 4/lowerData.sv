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
	logic [31:0] instruction_out;
	// The control signals from the processerControl module used to determine the output of the
	// 2:1 muxes.
	logic Reg2Loc, RegWrite, ALUSrc, MemWrite, MemToReg, DAddrImm, UncondBr, BrTaken, logicShift_LR, mul_signal;
	// negative, zero, overflow, carry_out are inputs to flagSetALU module
	// setFlag is an output of flagSetALU, and an input of processorControl
	// CBZ_zero is an output of processorControl, and an input of flagSetALU
	logic negative, zero, overflow, carry_out, setFlag;
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
	// logic from prcoessor control passed through ID_EX_reg to the ALU
	logic [2:0]  ALUOp_out;
	// logic from processor control passed through ID_EX_reg
	logic ALUSrc_regID, MemWE_regID, Mem2Reg_regID, RegWE_regID;
	logic [63:0] dataA_out;
	logic [63:0] dataB_out;
	logic [4:0]  Rd_regID;
	logic of_flag_out, neg_flag_out, DAddrImm_regID;
	logic [63:0] Imm12Extend_regID, DAddr9Extend_regID; 
	logic [5:0]  inst_dist;
	logic LS_regID;
	logic mul_regID;
	// logic from processor control passed through EX_Mem_reg
	logic MemWe_regEX, Mem2Reg_regEX, RegWE_regEX;
	logic [63:0] Db_regEX;
	logic [4:0]  Rd_regEX;
	// logic from processor control passed through Mem_WR_reg
	logic [4:0]  Rd_regMem;
	logic [63:0] Dw_regMem;
	logic RegWE_regMem;
	// logic for data to the dataMem addr passed through the  Mem_WR_reg
	logic [63:0] mul2memMux_out;
	// logic for the control signals to the forwarding muxes
	logic control_Da1, control_Da2, control_Db1, control_Db2;
	// logic for the multiply shift direction
	logic shiftDir;
	// logic from the nor gate of the forward_Db_2 data to check for zero in the REG/DEC stage
	logic zero_checker;
	// logic for setflags 
	logic setFlag_regID;
	// logic for processor control for PC 
	logic [63:0] PC_regIF, PCoutput;
	// logic from the forwarding units data
	logic [63:0] forward_Da_1;
	logic [63:0] forward_Da_2;
	logic [63:0] forward_Db_1;
	logic [63:0] forward_Db_2;
	// logic for inverting the clk to regfile
	logic notclk;
	
//****************************************************************
						//	START OF IF PIPE - STAGE 2 (IN REG/DEC NOW)
//****************************************************************	
	
	// Generate statment used to create 5 muxes for 5-bits of the instrcution pased from upperInst.
	// If Reg2Loc is true it will select the bits for Rm, if false for Rd. It will then pass this to the regfile
	// as a value to ReadRegister2.
	genvar i; 
	generate 
		for(i= 0; i< 5; i++) begin : each_port_Ab
			mux2_1 port_Ab (.a(instruction_out[i]), .b(instruction_out[i+16]), .s(Reg2Loc), .out(mux_Ab[i])); 
		end 
	endgenerate
	
	// This is logic used to invert the clk to the regfile.
	not #0.05 clkInvert (notclk, clk);
	
	// Instantiates the regfile. RegWrite enables the register to be able to write. WriteRegister seletcs the register
	// to be written to. WriteData provides the data that is being written. ReadRegister1 provides the register from
	// Rn. ReadRegister2 provides the register through Rd or Rm. ReadData1 is the data from register selected by 
	// ReadRegister1. ReadData2 is the data from register selected by ReadRegister1 (either Rd or Rm).
	regfile regLower (.RegWrite(RegWE_regMem), .WriteRegister(Rd_regMem), .WriteData(Dw_regMem), 
							.ReadRegister1(instruction_out[9:5]), .ReadRegister2(mux_Ab), .ReadData1(Da), .ReadData2(Db), .clk(notclk));

	// Instantitation of a 64 input nor module. The purpose of this module is to pass it's output "zero_checker"
	// as an input o processorControl. It does this specifically to account for CBZ instructions that would need
	// to know if a previous instruction was zero before this information is discovered in the EX stage. In order
	// to get this zero earlier, we create this module in the REG/DEC stage at the output of the forwarding mux
	// that takes the Db line from the regfile. This uses the principle that on a CBZ the ALU would've done a "pass B"
	// therefore we can just check the B after the mux.
	
	nor64_1Module two64 (.a(forward_Db_2[63:32]), .b(forward_Db_2[31:0]), .out(zero_checker));
							
							
	// signExtend module will be used to sign extend the provided data from a LDUR or STUR instruction to 
	// make it 64-bits as it passes through the processor.
	signExtend #(.len(9)) load_store_extend (.address(instruction_out[20:12]), .extendAddr(DAddr9Extend));
	
	// zeroExtend module will be used to add zeros to the data provided from a ADDI instructions to 
	// make it 64-bits as it passes through the processor.
	zeroExtend #(.len(12)) imm_12_extend (.address(instruction_out[21:10]), .extendAddr(Imm12Extend));
	

	// Instantiations of the 4 muxes used to create 2 forwarding units to both inputs to the ALU. We use
	// two 2-1 muxes in series with each other to create a 3-1 mux for forwarding. Each of the forwarding muxes
	// will be able to forward to the next instruction using data from "mul2memMux" (the EX stage) or two instructions
	// away from the "Dw" (the MEM stage). Alternatively there can be no forwarding and either Da or Db is passed.
	// Each mux uses a controls signal from the forwarding_Unit on the first choosing whether it is forwarding from 
	// EX or MEM stage, and then choosing between that output and Da or Db respectively.
	muxModule firstALUmux_Da  (.A(mul2memMux), .B(Dw), .controlSig(control_Da1), .out(forward_Da_1));
	
	muxModule secondALUmux_Da (.A(Da), .B(forward_Da_1), .controlSig(control_Da2), .out(forward_Da_2));
	
	
	muxModule firstALUmux_Db  (.A(mul2memMux), .B(Dw), .controlSig(control_Db1), .out(forward_Db_1));
	
	muxModule secondALUmux_Db (.A(Db), .B(forward_Db_1), .controlSig(control_Db2), .out(forward_Db_2));
	
	// Instantiation of the forwarding unit. This is the control logic created to determine the operation of the 
	// forwarding muxes perviously mentioned. They first take inputs to addrA/B which are Rn and Rd/Rm (from mux_Ab)
	// respectively. Boht of these receive their input from instruction out of upperInst module, however that
	// instruction if passed through the IF_reg to make sure it is passed at the correct time. It also takes an
	// input of -
	//														FROM EX STAGE
	// Rd_regID - The value of the destination register that has been passed into the EX stage
	// RegWE_regID - The status of the current write enable that has been passed into EX stage
	// 													FROM MEM STAGE
	// Rd_regEX - The value of the destination register that has been passed into the MEM stage
	// RegWE_regEX - The status of the current write enable that has been passed into MEM stage
	//
	// Using these four value it could compare them to what came into addrA and addrB and decided if any
	// forwarding needs to occur, thus sending out the controls signals to their respective muxes for forwarding or
	// no forwarding.
	forwarding_Unit f_unit (.addrA(instruction_out[9:5]), .addrB(mux_Ab), .destReg_ALU(Rd_regID), .regWE_ALU(RegWE_regID), 
								   .destReg_dataMem(Rd_regEX), .regWE_dataMem(RegWE_regEX), .control_Da1, 
								   .control_Da2, .control_Db1, .control_Db2);
	
//****************************************************************
						//	START OF REG/DEC PIPE - STAGE 3 (IN EX NOW)
//****************************************************************


	// muxModule instantiation chooses either between the 64-bit data of an LDUR/STUR
	// instruction (from signExtend module) or from a ADDI instruction (from zeroExtend module). If the control
	// signal DAddrImm_regID is true then extended data from LDUR/STUR is pased, otherwise extended data from
	// ADDI instruction is passed. 
	//
	// Imm12Extend_regID, DAddr9Extend_regID, and DAddrImm_regID are two data signals and a control signal respectively
	// that are passed through the ID_EX_reg in order to keep instructions matched to the cycle they are supposed to 
	// execute in. 

	muxModule DAddr_Imm_mux(.A(Imm12Extend_regID), .B(DAddr9Extend_regID), .controlSig(DAddrImm_regID), .out(ALUSrc_in));

	// muxModule instantiation to choose either between the 64-bit data from previously
	// mentioned operations or from dataB_out (the ReadData2 port data from regfile that has been passed through
	// ID_EX_reg). If ALUSrc_regID signal (passed through ID_EX_reg) is true then select the data from DAddr_Imm_mux 
	// muxes, if false from the dataB_out (Rd or Rn based on mux) port.
	muxModule ALUSrc_mux(.A(dataB_out), .B(ALUSrc_in), .controlSig(ALUSrc_regID), .out(ALUSrc_out));
	
	// Instantiation of the ALU. It takes the data from the dataA_out (ReadData1 or Rn) and from the
	// the ALUsrc_out. Input to cntrl, ALUOp_out(passed from proccessor control through ID_EX_reg) will 
	// determine the operation performed. Result is output as ALU_out. Also provides a negative, zero, overflow, 
	// carry_out signal based on the result of the operation (sends this to the flagSetALU).
	alu aluMod (.A(dataA_out), .B(ALUSrc_out), .cntrl(ALUOp_out), .result(ALU_out), .negative, .zero, .overflow, .carry_out);
	
	// Instantiation of the shifter module. Can perform left or right shifts based on the input to direction. 
	// Direction is set by control signal from processorControl (passed through ID_EX_REG).
   //	Distance shifted is determined by the distance set in the instruction code (passed through ID_EX_REG). 
	// LSR and LSL both provide a register to shift data from based on dataA_out (Rn passed through ID_EX_reg). 
	// Output "logicShift" is then fed to shift_mux muxes which will chose between shift or ALU.
	shifter LSL_LSR (.value(dataA_out), .direction(shift_regID), .distance(inst_dist), .result(logicShift));
	
	// Generate statement is used to create 64 muxes to choose either between the 64-bit data from ALU 
	// or from shifter. If LS_regID signal is true then pass the data from the shifter, otherwise
	// pass the data from the ALU. Output is shift2mulMux which feeds into the muxes from multiplying
	// "mul_mux";
	generate 
		for(i= 0; i< 64; i++) begin : each_shift_mux
			mux2_1 shift_mux (.a(ALU_out[i]), .b(logicShift[i]), .s(LS_regID), .out(shift2mulMux[i])); 
		end 
	endgenerate

	// Instantiation of the mult mod, performs multiplication. Takes data inputs from dataA_out and dataB_out 
	// (passed through ID_EX_REG) and executes the result. Passes the lower 64-bits to multOutput and upper 64-bits 
	// to multHighOutput. Since our processor is set for odometer math, multHighOutput is sent to dead logic and is 
	// not used. Since we are in two's comp the control signal to do signed or unsigned multiplication is not 
	// important and arbitraily set to 1.
	mult multMod (.A(dataA_out), .B(dataB_out), .doSigned(1'b1), .mult_low(multOutput), .mult_high(multHighOutput));
	
	// Generate statement is used to create 64 muxes to choose either between the 64-bit data passed from 
	// the shift_mux muxes or from the mult module. If mul_regID (passed through ID_EX_REG) signal is true then pass 
	// the data from the mult module (multOutput), otherwise pass the data from shift_mux muxes (shift2mulMux).
	// Output is mul2memMux (the final ouput before reaching dataMem).
	generate 
		for(i= 0; i< 64; i++) begin : each_mul_mux
			mux2_1 mul_mux (.a(shift2mulMux[i]), .b(multOutput[i]), .s(mul_regID), .out(mul2memMux[i])); 
		end 
	endgenerate
	
	// This module takes the signals from the ALU (not included the mathematically computed data).
	// It's purpose inside the module is to deal with ADDS and SUBS signals in order to set the flags.
	// Flags are set when the setFlag_regID input (passed through ID_EX_REG) to this module is true. Outputs of 
	// this module connect to the processerControl. Our flagSetALU module is designed to control all signals 
	// (minus arithmetic data) from the ALU simultaneously on being required to be set. Currently our ALU 
	// flags have have neg_out and of_out passed to two muxes in order to account for B.LT instructions involved in
	// forwarding.
	flagSetALU theFlags(.setFlag(setFlag_regID), .neg_in(negative), .zero_in(zero), .of_in(overflow), 
							  .co_in(carry_out), .neg_out, .zero_out, .of_out, .co_out, .clk);
							  
	
	// These muxes are used for in determining if the processorControl will require the negative or overflow
	// respectively from either the flagSetALU module or the ALU. Negative and overflow are neccesary signals 
	// for the B.LT condition. If setFlag_regID is true then the ALU signals are used, otherwise flagsetALU signals
	// are used. This is output to the processor control in order to determine the correct signal based on ARM 
	// instructions involving B.LT
	mux2_1 negative_flag(.a(neg_out), .b(negative), .s(setFlag_regID), .out(neg_flag_out));
	
	mux2_1 over_flow_out_flag(.a(of_out), .b(overflow), .s(setFlag_regID), .out(of_flag_out));


//****************************************************************
						//	START OF EX PIPE (3)
//****************************************************************							 
							
							
	// This is the datamemory module. It takes the address from the output of the mul_mux muxes, "mul2memMux_out" 
	// (passed through EX_Mem_reg). It allows a write enable from control signal MemWe_regEX (passed through 
	// EX_Mem_reg). It allows a read enable from control signal Mem2Reg_regEX (passed through EX_Mem_reg).
	// Data input to the datamem module is from Db_regEX (Rd or Rn). Data output from the module is DataMem_out
	// which is fed to the memReg muxes.
	datamem dataMemMod(.address(mul2memMux_out), .write_enable(MemWe_regEX), .read_enable(Mem2Reg_regEX), 
							 .write_data(Db_regEX), .clk(clk), .xfer_size(4'b1000), .read_data(DataMem_out));

	// Generate statement is used to create 64 muxes to choose either between the 64-bit data passed from 
	// the datamemory or from the mul_mux muxes. If Mem2Reg_regEX signal is true then pass the data from 
	// the datamemory (DataMem_out), otherwise pass the data from  mul2memMux_out). Output is
	// Dw which feeds back into the regfile at WriteData.
	generate 
		for(i= 0; i< 64; i++) begin : each_memReg_mux
			mux2_1 memReg_mux (.a(mul2memMux_out[i]), .b(DataMem_out[i]), .s(Mem2Reg_regEX), .out(Dw[i])); 
		end 
	endgenerate
	

//****************************************************************
						//	START OF MEM PIPE (4)
//****************************************************************
	
	
	// Instantiation of the upperInst module used to update the PC and update the instruction that is fed to the
	// lowerData module. Passes that instruction as "instruction", also takes unCondBr and BrTaken muxes as control
	// signal inputs from processorControl. Passes the data from the instruction neccesary for CondAddr19 and
	// BrAddr26 which are used for conditional and non-conditional instructions respectively (AKA the amount
	// that it has to update the PC counter by for those scenarios). All outputs are passed to the IF_reg.
	upperInst counter (.CondAddr19(instruction_out[23:5]), .BrAddr26(instruction_out[25:0]), .UncondBr, 
							 .BrTaken, .instr(instruction), .PC_count_in(PC_regIF), .PCoutput, .clk, .reset);
	
	// Instantiation of the processorControl unit. This module is used in order to determine the control signals
	// to the muxes. It is passed the OpCode fom each instruction (designed to take OpCodes of different lengths
	// with the knowledge that the largest OpCode is 11 bits). Each output control signal is described in lowerData
	// at its connection point. It takes inputs for zero, negative, and overflow from the appropriate locations
	// as inputs and passes along all its outputs to the next register EX_Mem_reg. 
	processorControl  controlUnit (.OpCode(instruction_out[31:21]), .Reg2Loc, .RegWrite, 
													.ALUSrc, .ALUOp, .MemWrite, 
													.MemToReg, .UncondBr, .BrTaken,
													.DAddrImm, .zero(zero_checker), 
													.neg(neg_flag_out), .o_f(of_flag_out), 
													.setFlag, .logicShift_LR, 
													.mul_signal, .shiftDir);
													
	// This is the IF_reg which passes along instructions from the upperInst module to the REG/DEC stage
	// where the regfile and processorControl are located.
	IF_reg regIF (.inst(instruction), .inst_out(instruction_out), .PCin(PCoutput), .PCout(PC_regIF), .clk);												
		
	// This is the ID_EX_reg which passes along instructions from processor control and regile to the
	// EX stage. Also includes the controls signals that are passed to the aritmethic muxes in the EX stage.
	// Also passes the data from the forwarding muxes through to the EX stage.
	ID_EX_reg regID_EX (.ALUSrc, .ALUOp, .MemWE(MemWrite), .Mem2Reg(MemToReg), 
							  .RegWE(RegWrite), .ALUSrc_out(ALUSrc_regID), .ALUOp_out, 
							  .MemWE_out(MemWE_regID), .Mem2Reg_out(Mem2Reg_regID), .RegWE_out(RegWE_regID),
							  .Rd(instruction_out[4:0]), .dataA(forward_Da_2), .dataB(forward_Db_2), 
							  .Rd_out(Rd_regID), .dataA_out, .dataB_out, .shiftIn(shiftDir), 
							  .shiftOut(shift_regID), .instIn(instruction_out[15:10]), .instOut(inst_dist),
							  .LS_in(logicShift_LR), .LS_out(LS_regID), .mul_in(mul_signal), 
							  .mul_out(mul_regID), .setFlagControl(setFlag), .setFlagControl_out(setFlag_regID), 
							  .DAddr9Extend, .DAddr9Extend_out(DAddr9Extend_regID), .Imm12Extend, 
							  .Imm12Extend_out(Imm12Extend_regID), .DAddrImm, .DAddrImm_out(DAddrImm_regID), .clk);
							  
	// This is the EX_Mem_reg which passes data and control signals from the EX stage to the MEM stage where
	// dataMem is located.
	EX_Mem_reg regEX_Mem (.MemWE(MemWE_regID), .Mem2Reg(Mem2Reg_regID), .RegWE(RegWE_regID),
								 .MemWE_out(MemWe_regEX), .Mem2Reg_out(Mem2Reg_regEX), .RegWE_out(RegWE_regEX), 
								 .mul_mem_in(mul2memMux), .mul_mem_out(mul2memMux_out), 
								 .Db_in(dataB_out), .Db_out(Db_regEX), .Rd(Rd_regID), .Rd_out(Rd_regEX), .clk);
	
	// This is the Mem_WR_reg which passes data and control signals from the MEM stage to the WR stage.
	Mem_WR_reg regMem_WR (.RegWE(RegWE_regEX), .RegWE_out(RegWE_regMem), .Rd(Rd_regEX), .Rd_out(Rd_regMem), 
								 .DataIn(Dw), .DataOut(Dw_regMem),  .clk);
	
	
endmodule
