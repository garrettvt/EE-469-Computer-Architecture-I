//Leonard Dul and Garrett Tashiro
//November 06, 2021
//EE 469
//Lab 3

`timescale 1ns/10ps 

//upperInst takes 1-bit clk, reset, UncondBr, BrTaken, 19-bit
//CondAddr19, and 26-bit BrAddr26 as inputs and returns 32-bit
//instr as an output. This module implements the top right corner
//of the CPU datapath picture. This module does hierarchical calls
//to mux2_1, shifter, fullerAdder, signExtend, DFF_VAR, and 
//instructmem. The module has handles the datapath for the PC counter
//which is connected to adders, as well as muxes. The branching for 
//the datapath is handled in this module. 

module upperInst(CondAddr19, BrAddr26, UncondBr, BrTaken, instr, clk, reset);
	input logic clk;
	input logic reset;
	input logic UncondBr, BrTaken; //, reset, enable;
	input logic  [18:0] CondAddr19;
	input logic  [25:0] BrAddr26;
	output logic [31:0] instr;
	
	//64-bit logics to hold the outputs from
	//the modules that are called through
	//hierarchy
	logic [63:0] condExtend, brExtend;
	logic [63:0] unCondMux_output;
	logic [63:0] PCinput;
	logic [63:0] PCoutput;
	
	logic [63:0] shifted;
	
	logic [63:0] tempCoutUnCond;
	logic [63:0] addWireUnCond;
	
	logic [63:0] tempCoutbrTaken;
	logic [63:0] addWirebrTaken;
	
	//signExtend conditionalExtend takes the parameter of 19, 
	//and has 19-bit CondAddr19 as an input and returns 64-bit
	//condExtend as an output. This parameterized module is 
	//taking in the 19-bit conditional branch address and sign
	//extending it. The output from conditionalExtend is passed
	//to unCondMux as an input.
	signExtend #(.len(19)) conditionalExtend(.address(CondAddr19), .extendAddr(condExtend));
	
	//signExtend branchExtend takes the parameter of 26, and
	//has 26-bit BrAddr26 as an input and returns 64-bit
	//brExtend as an output. This parameterized module is 
	//taking in the 26-bit unconditional branch address and sign
	//extending it. The output from branchExtend is passed
	//to unCondMux as an input.
	signExtend #(.len(26)) branchExtend(.address(BrAddr26), .extendAddr(brExtend));
	
	//genvar i used in for loop
	genvar i;

	//This generate statement is for the unconditional mux. There 
	//is a for loop that goes from 0 to 63, and takes the 64- bit  
	//outputs from branchExtend and conditionalExtend as inputs as
	//well as 1-bit UncondBr as a control signal, and returns 64-bit
	//unCondMux_output. The 64-bit output is passed to shifter as 
	//an input.
	generate 
		for(i=0; i< 64; i++) begin : eachUnCondMux
			mux2_1 unCondMux (.a(brExtend[i]), .b(condExtend[i]), .s(UncondBr), .out(unCondMux_output[i])); 
		end 
	endgenerate
	
	//shifter has 64-bit unCondMux_output being passed as an input
	//and has direction set to 0 to shift left, as well as distance
	//set to 2 to shift 2 places. This module returns 64-bit shifted
	//as an output. This module shifts the intput to the left by 2.
	shifter unCondShift_2 (.value(unCondMux_output),
								  .direction(1'b0), // 0: left, 1: right
								  .distance(6'd2),
								  .result(shifted));

	//Generate statement for the unCond and PC ADDER
	//This generate statement uses a hierarchical call to the fullAdder
	//module that takes 64-bit shifted, and PCoutput as inputs. This 
	//generate statement outputs 64-bit addWireUnCond. 
	generate 
		fullAdder addModunCond (.A(shifted[0]), .B(PCoutput[0]), .Cin(1'b0), .Cout(tempCoutUnCond[0]), .S(addWireUnCond[0]));	
		for(i = 1; i< 64; i++) begin : each_adder_UnCond_PC
			fullAdder addModunCond (.A(shifted[i]), .B(PCoutput[i]), .Cin(tempCoutUnCond[i-1]), .Cout(tempCoutUnCond[i]), .S(addWireUnCond[i]));
		end 
	endgenerate

	//Generate statement for the PC and 4 ADDER
	//This generate does the fullAdder for PC and 4. 
	//First three fullAdders are specific for adding 
	//the 4, then the other 61 are in a for loop to 
	//just be zeros.  
	generate  
		fullAdder addModbrTaken0 (.A(1'b0), .B(PCoutput[0]), .Cin(1'b0), .Cout(tempCoutbrTaken[0]), .S(addWirebrTaken[0]));
		fullAdder addModbrTaken1 (.A(1'b0), .B(PCoutput[1]), .Cin(tempCoutbrTaken[0]), .Cout(tempCoutbrTaken[1]), .S(addWirebrTaken[1]));
		fullAdder addModbrTaken2 (.A(1'b1), .B(PCoutput[2]), .Cin(tempCoutbrTaken[1]), .Cout(tempCoutbrTaken[2]), .S(addWirebrTaken[2]));
		for(i = 3; i< 64; i++) begin : each_adder_brTaken_PC
			fullAdder addModbrTaken (.A(1'b0), .B(PCoutput[i]), .Cin(tempCoutbrTaken[i-1]), .Cout(tempCoutbrTaken[i]), .S(addWirebrTaken[i]));
		end 
	endgenerate	
	
	//Generate Statements for brTakenMux
	//This generate statement is a 2:1 mux for the branch taken.
	//The 64-bit outputs from both fullAdders are passed into
	//the 2:1 mux and output 64-bit PCinput. The generate uses 
	//a for loop that loops from 0 to 63 to mux all 64-bits from
	//the inputs and uses BrTaken as the control logic.
	generate 
		for(i=0; i< 64; i++) begin : eacBrTakenMux
			mux2_1 brTaken (.a(addWirebrTaken[i]), .b(addWireUnCond[i]), .s(BrTaken), .out(PCinput[i]));
		end 
	endgenerate
	
	//DFF_VAR takes 64-bit PCinput, 1-bit clk, reset, and enable as inputs 
	//and returns 64-Bit PCoutput as an output. This module creates a register
	//that is a single line that is 64-bits. The output is passed to instructmem.
	DFF_VAR PC (.q(PCoutput), .d(PCinput), .clk, .reset, .enable(1'b1));
	
	//instructmem takes 64-bit PCoutput, and 1-bit clk as inputs and returns
	//32-bit instr. This module takes the 64-bit register an outputs the
	//32-bit instruction.
	instructmem instructMod (.address(PCoutput), .instruction(instr), .clk);
	
endmodule
