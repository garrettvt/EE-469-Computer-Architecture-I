//Leonard Dul and Garrett Tashiro
//November 04, 2021
//EE 469
//Lab 3

module mult (
	input logic		[63:0]	A, B,
	input logic					doSigned,				// 1: signed multiply 0: unsigned multiply
	output logic	[63:0]	mult_low, mult_high 
	);
	
	logic signed	[63:0]	signedA, signedB;
	logic signed	[127:0]	signedResult;
	logic				[127:0]	unsignedResult;
	
	// --- Signed math ---
	always_comb begin
		signedA = A;
		signedB = B;
		signedResult = signedA * signedB;
	end
	
	// --- Unsigned math ---
	always_comb
		unsignedResult = A * B;
		
	// --- Pick the right output ---
	always_comb
		if (doSigned)
			{mult_high, mult_low} = signedResult;
		else
			{mult_high, mult_low} = unsignedResult;

endmodule

module mult_testbench();
	logic [63:0]	A, B;
	logic				doSigned;
	logic	[63:0]	mult_low, mult_high;
	logic	[127:0]	fullVal;
	
	mult dut (.A, .B, .doSigned, .mult_low, .mult_high);
	
	assign fullVal = {mult_high, mult_low};
	
	integer i;
	initial begin
		for(i=0; i<2; i++) begin
			doSigned <= i[0];
		
			A <=  0; B <=  0; #10;
			A <=  1; B <=  2; #10;
			A <= -1; B <=  1; #10;
			A <= -1; B <= -1; #10;
			A <= 5<<35; B <= 6<<35; #10;
		end
	end
endmodule
