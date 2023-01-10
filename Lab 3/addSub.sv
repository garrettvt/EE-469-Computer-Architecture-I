//Leonard Dul and Garrett Tashiro
//October 23, 2021
//EE 469
//Lab 2

`timescale 1ns/10ps

// This module creates an adder/subtractor (our ALUslice) unit for single bit operations. It will 
// take two bits and perform one of the two operation based on the subSignal provided. 

module addSub(A, B, Cin, Cout, S, subSignal);
	input logic A, B, Cin, subSignal;
	output logic Cout, S;
	
	logic notB;
	logic mux2Adder;
	
	not #0.05 invert(notB, B);
	
	// The mux here is used to select between addition and subtraction operations. Will invert
	// the B signal if subtraction is to be used and output to our fullAdder module.
	
	mux2_1 muxSingle (.a(B), .b(notB), .s(subSignal), .out(mux2Adder));
	
	// The fullAdder will take the output of the mux as well as the A input and add the two functions
	// together providing an output/carryout/carryin.
	
	fullAdder fAddSingle (.A(A), .B(mux2Adder), .Cin(Cin), .Cout(Cout), .S(S));
	
endmodule

module addSub_testbench();
		logic A, B, Cin, Cout, S, subSignal;
		
		addSub dut(.A, .B, .Cin, .Cout, .S, .subSignal);
		
		initial begin 
		// Data bits 1-63
			A <= 0; B <= 0; Cin <= 0; subSignal <=0;  #10;
			A <= 0; B <= 0; Cin <= 1; 		#10;
			A <= 0; B <= 1; Cin <= 0;		#10;
			A <= 0; B <= 1; Cin <= 1;		#10;
			A <= 1; B <= 0; Cin <= 0;		#10;
			A <= 1; B <= 0; Cin <= 1;		#10;
			A <= 1; B <= 1; Cin <= 0;		#10;
			A <= 1; B <= 1; Cin <= 1;		#10;
		// Data bit 0	
			A <= 0; B <= 0; Cin <= 1; subSignal <=1;  #10;
			A <= 0; B <= 0; Cin <= 1; 		#10;
			A <= 0; B <= 1; Cin <= 1;		#10;
			A <= 0; B <= 1; Cin <= 1;		#10;
			A <= 1; B <= 0; Cin <= 1;		#10;
			A <= 1; B <= 0; Cin <= 1;		#10;
			A <= 1; B <= 1; Cin <= 1;		#10;
			A <= 1; B <= 1; Cin <= 1;		#10;

		end
endmodule