//Leonard Dul and Garrett Tashiro
//November 04, 2021
//EE 469
//Lab 3

module shifter(
	input logic		[63:0]	value,
	input logic					direction, // 0: left, 1: right
	input	logic		[5:0]		distance,
	output logic	[63:0]	result
	);
	
	always_comb begin
		if (direction == 0)
			result = value << distance;
		else
			result = value >> distance;
	end
endmodule

module shifter_testbench();
	logic	[63:0]	value;
	logic				direction;
	logic [5:0]		distance;
	logic [63:0]	result;
	
	shifter dut (.value, .direction, .distance, .result);
	
	integer i, dir;
	initial begin
		value = 64'hDEADBEEFDECAFBAD;
		for(dir=0; dir<2; dir++) begin
			direction <= dir[0];
			for(i=0; i<64; i++) begin
				distance <= i; #10;
			end
		end
	end
endmodule
