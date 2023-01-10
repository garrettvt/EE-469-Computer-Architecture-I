//Leonard Dul and Garrett Tashiro
//October 26, 2021
//EE 469
//Lab 2

`timescale 1ns/10ps

// This ALU modules takes two 64 bit inputs and based on the the control signal provided
// and will perform one of six operations
// 1) Pass B data 
// 2) Add data
// 3) Subtract data
// 4) AND data
// 5) OR data
// 6) XOR data
// The ALU also provides a negative, zero, overflow, and carry out signal, which are important
// for addition and subtraction operations.

module alu (A, B, cntrl, result, negative, zero, overflow, carry_out);

	input logic	 [63:0] A, B;
	input logic	 [2:0]  cntrl;
	output logic [63:0] result;
	output logic negative, zero, overflow, carry_out;
	
// Tempwire are the connections between each of the ALUslice's Carry In's and Carry Out's.
// addSubWire are the outputs of the computation for each ALUslice.
// orWire, andWire, and xorWire are the outputs for each respective bit operation type. 	
	
	logic [63:0] tempWire;
	logic [63:0] addSubWire;
	logic [63:0] orWire;
	logic [63:0] andWire;
	logic [63:0] xorWire;
	
// This generate statement first creates the components required for the six operations for the 
// 0th bit of A and B data. Afterwards, the subsequent bits have their components generated in the
// for loop. The 0th bit computations are isolated because the addition/subtraction operations 
// require a Cin(Carry In) that has a different connection than the remaining 63 bits.

// The control signal's LSB is used as an input for all of the ALU's add/subtraction operation and 
// also for the Cin for the 0th ALUSlice's addSub unit (This is done in order to add the +1 when negating
// the value in two's complement). Though a control signal for "or" also passes a 1 as the LSB, when 
// performing an "or" operation there are muxs that will select the ouput from the or modules, disregarding
// any computations from the addSub units.

	genvar i;  
	generate 
	   addSub ALUslice_bit0 (.A(A[0]), .B(B[0]), .Cin(cntrl[0]), .Cout(tempWire[0]), .S(addSubWire[0]), .subSignal(cntrl[0]));	
		orModule orBundle0 (.a(A[0]), .b(B[0]), .out(orWire[0]));
		andModule andBundle0 (.a(A[0]), .b(B[0]), .out(andWire[0]));
		xorModule xorBundle0 (.a(A[0]), .b(B[0]), .out(xorWire[0]));
			
		for(i = 1; i< 64; i++) begin : each_ALU_Slice
			addSub ALUslice_mid1 (.A(A[i]), .B(B[i]), .Cin(tempWire[i-1]), .Cout(tempWire[i]), .S(addSubWire[i]), .subSignal(cntrl[0]));
			orModule orBundle (.a(A[i]), .b(B[i]), .out(orWire[i]));
			andModule andBundle (.a(A[i]), .b(B[i]), .out(andWire[i]));
			xorModule xorBundle (.a(A[i]), .b(B[i]), .out(xorWire[i]));
		end 
	endgenerate
	
// 2D array created for the use of 64 8:1 muxes.
	
	logic [63:0][7:0] allThem;
	
// This generate statement is used specifically for the zero signal. Instead of creating a 
// 64 input nor gate, a 2D array was to pass all possible operations to an 8:1 mux for each of
// the 64 resulting bits. The control signal would allow all 64 muxes to select the appropriate
// input to pass (collectively). Stores the passed computation data in result.
	generate
		for(i = 0; i< 64; i++) begin : opPick 
			assign allThem[i] = {1'b0, xorWire[i], orWire[i], andWire[i], addSubWire[i], addSubWire[i], 1'b0, B[i]};
			mux8_1 outputALU(.incoming(allThem[i]), .select(cntrl[2:0]), .out(result[i]));
		end
	endgenerate

// 64:1 mux used to pass the stored data from result in order to check if there are any 1's in
// the result data. If there are the value is not zero.

	nor64_1Module two64 (.a(result[63:32]), .b(result[31:0]), .out(zero));
	
// xorModule used to xor the 63rd and 62nd bits of the resultant data in "result". If the 
// values are the same there is overflow.
	
	xorModule overflowCheck (.a(tempWire[62]), .b(tempWire[63]), .out(overflow));
	
// Since data is in two's complement we can check the MSB in "result" directly to determine
// if negative.
	
	assign negative = result[63];

// Using the carry out connection of the last ALUslice we can determine if there was carry out.
	
	assign carry_out = tempWire[63];
	
endmodule

// Test bench for ALU

// Meaning of signals in and out of the ALU:

// Flags:
// negative: whether the result output is negative if interpreted as 2's comp.
// zero: whether the result output was a 64-bit zero.
// overflow: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
// carry_out: on an add or subtract, whether the computation produced a carry-out.

// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant


//alustim tests multiple cases for for outputting
//b, add, subtract, and, or, and xor. The tests will
//check for negative, zero, overflow, and carry_out
//if that instructions utilizes it. 
module alustim();

	parameter delay = 100000;

	logic		[63:0]	A, B;
	logic		[2:0]		cntrl;
	logic		[63:0]	result;
	logic					negative, zero, overflow, carry_out ;

	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
	

	alu dut (.A, .B, .cntrl, .result, .negative, .zero, .overflow, .carry_out);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	integer i;
	logic [63:0] test_val;
	initial begin
	
		$display("%t testing PASS_A operations", $time);
		cntrl = ALU_PASS_B;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == B && negative == B[63] && zero == (B == '0));
		end
		
		
		$display("%t testing addition", $time);
		cntrl = ALU_ADD;
		A = 64'h0000000000000001; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h0000000000000002 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
		
		
		//Testing for addition
		$display("%t testing multiple addition instructions", $time);
		cntrl = ALU_ADD;
		for (i= 1; i< 50; i++) begin
			A = i; B = i;
			#(delay);
			assert(result == (i + i) && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
		end
		
		
		$display("%t testing addition for carry_out, overflow, and zero", $time);
		A = 64'hffffffffffffffff; B = 64'h0000000000000001; 
		#(delay);
		assert(result == 64'h0000000000000000 && carry_out == 1 && overflow == 0 && negative == 0 && zero == 1);	
		
		
		//Testing for subtraction 
		$display("%t testing multiple subtractions", $time);
		cntrl = ALU_SUBTRACT;
		for (i= 50; i > 1; i--) begin
			A = i; B = i - 1;
			#(delay);
			assert(result == 64'h0000000000000001 && carry_out == 1 && overflow == 0 && negative == 0 && zero == 0);
		end
		
		
		$display("%t testing subtraction for carry_out, and zero", $time);
		A = 64'hffffffffffffffff; B = 64'hffffffffffffffff; 
		#(delay);
		assert(result == 64'h0000000000000000 && carry_out == 1 && overflow == 0 && negative == 0 && zero == 1);
		
		
		$display("%t testing subtraction for negative", $time);
		A = 64'h0000000000000000; B = 64'h0000000000000005; 
		#(delay);
		assert(result == 64'hfffffffffffffffb && carry_out == 0 && overflow == 0 && negative == 1 && zero == 0);	
		
		$display("%t testing subtraction for overlow", $time);
		A = 64'h8000000000000000; B = 64'h0fffffffffffffff; 
		#(delay);
		assert(result == 64'h7000000000000001 && carry_out == 1 && overflow == 1 && negative == 0 && zero == 0);
			
		//Testing for AND
		$display("%t testing multiple and", $time);
		cntrl = ALU_AND;
		for (i = 1; i < 50; i++) begin
			A = i; B = i;
			#(delay);
			assert(result == i);
		end
		
		$display("%t testing and 0", $time);
		A = 64'hffffffffffffffff; B = 64'h0000000000000000; 
		#(delay);
		assert(result == 64'h0000000000000000 && negative == 0 && zero == 1);
		
		$display("%t testing and negative", $time);
		A = 64'hffffffffffffffff; B = 64'hffffffffffffffff; 
		#(delay);
		assert(result == 64'hffffffffffffffff && negative == 1 && zero == 0);
		
		
		//Testing for OR
		$display("%t testing multiple or for 1's to 0's", $time);
		cntrl = ALU_OR;
		for (i = 1; i < 10; i++) begin
			A = i; B = 0;
			#(delay);
			assert(result == i && zero == 0);
		end
		
		$display("%t testing multiple or for 1's to 1's", $time);
		for (i = 1; i < 10; i++) begin
			A = i; B = i;
			#(delay);
			assert(result == i && zero == 0);
		end
		
		// what about ex, 4 bit -> 1000 in twos comp is that 8? or -0?
		
		$display("%t testing or for negative", $time);
		A = 64'h8000000000000000; B = 64'h0000000000000000; 
		#(delay);
		assert(result == 64'h8000000000000000 && negative == 1 && zero == 0);
		
		$display("%t testing or for zero", $time);
		A = 64'h0000000000000000; B = 64'h0000000000000000; 
		#(delay);
		assert(result == 64'h0000000000000000 && negative == 0 && zero == 1);
		
		
		//Testing for xor
		$display("%t testing multiple xor for 1's to 0's", $time);
		cntrl = ALU_XOR;
		for (i = 1; i < 10; i++) begin
			A = i; B = 0;
			#(delay);
			assert(result == i && zero == 0);
		end
		
		$display("%t testing multiple xor for 1 to 1", $time);
		A = 64'h0000000000000001; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h0000000000000000 && zero == 1);
	end
endmodule

