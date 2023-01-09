`timescale 1ns/10ps

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

