//Leonard Dul and Garrett Tashiro
//November 9, 2021
//EE 469
//Lab 3

`timescale 1ns/10ps

//flagSetALU has 1-bit clk, setFlag, neg_in, zero_in, 
//of_in, and co_in as inputs and returns 1-bit neg_out, 
//zero_out, of_out, and co_out as outputs. This module
//takes in the flag values from the ALU, and uses hierarchical
//calls to mux2_1 as well as D_FF to set the flags from the 
//ALU when setFlags is high. If setFlags is high, the new flag
//values from the ALU will pass and be saved to temp variables. 

module flagSetALU(setFlag, CBZ_zero, neg_in, zero_in, of_in, co_in, neg_out, zero_out, of_out, co_out, clk);

		//1-bit temp logic to be inputs to the
		//muxes and take outputs from the D_FF's
		//to prevent metastability
		
		input logic    clk;
		input logic 	neg_in, zero_in, of_in, co_in, setFlag, CBZ_zero;
		output logic 	neg_out, zero_out, of_out, co_out;
		
		logic temp_neg;
		logic temp_zero;
		logic temp_CBZ;
		logic temp_of;
		logic temp_co;
		
		//negFlag takes 1-bit temp_neg, neg_in, and setFlag as inputs
		//and returns 1-bit neg_out as an output. This mux takes the 
		//value of the negative flag from the ALU to either pass the value, 
		//or hold the value. 1-bit neg_out is passed to negFlag_dff as an
		//input.
		mux2_1 negFlag 	(.a(temp_neg), .b(neg_in), .s(setFlag), .out(neg_out));
		
		//zeroFlag takes 1-bit temp_zero, neg_zero, and setFlag as inputs
		//and returns 1-bit temp_CBZ as an output. This mux takes the 
		//value of the zero flag from the ALU to either pass the value, 
		//or hold the value. 1-bit temp_CBZ is passed to zeroFlag_dff as an
		//input, as well as CBZzero mux.
		mux2_1 zeroFlag	(.a(temp_zero), .b(zero_in), .s(setFlag), .out(temp_CBZ));
		
		//ofFlag takes 1-bit temp_of, neg_in, and setFlag as inputs
		//and returns 1-bit of_out as an output. This mux takes the 
		//value of the overflow flag from the ALU to either pass the value, 
		//or hold the value. 1-bit of_out is passed to negFlag_dff as an
		//input.
		mux2_1 ofFlag		(.a(temp_of), .b(of_in), .s(setFlag), .out(of_out));
		
		//coFlag takes 1-bit temp_co, co_in, and setFlag as inputs
		//and returns 1-bit co_out as an output. This mux takes the 
		//value of the carry_out flag from the ALU to either pass the value, 
		//or hold the value. 1-bit co_out is passed to negFlag_dff as an
		//input.
		mux2_1 coFlag		(.a(temp_co), .b(co_in), .s(setFlag), .out(co_out));
		
		//CBZzero takes 1-bit temp_CBZ, zero_in, and CBZ_zero as inputs
		//and returns 1-bit zero_out as an output. This mux takes the 
		//value of the zero flag from the ALU to either pass the value, 
		// or passes the flagged zero value that is held.
		mux2_1 CBZzero	   (.a(temp_CBZ), .b(zero_in), .s(CBZ_zero), .out(zero_out));

		//negFlag_dff takes 1-bit output from negFlag mux as an input
		//and returns 1-bit temp_neg as an output. This module is designed
		//to prevent metastability.
		D_FF negFlag_dff  (.q(temp_neg), .d(neg_out), .reset(1'b0), .clk);
		
		//zeroFlag_dff takes 1-bit output from zeroFlag mux as an input
		//and returns 1-bit temp_zero as an output. This module is designed
		//to prevent metastability.
		D_FF zeroFlag_dff (.q(temp_zero), .d(temp_CBZ), .reset(1'b0), .clk);
		
		//ofFlag_dff takes 1-bit output from ofFlag mux as an input
		//and returns 1-bit temp_of as an output. This module is designed
		//to prevent metastability.
		D_FF ofFlag_dff   (.q(temp_of), .d(of_out), .reset(1'b0), .clk);
		
		//coFlag_dff takes 1-bit output from coFlag mux as an input
		//and returns 1-bit temp_co as an output. This module is designed
		//to prevent metastability.
		D_FF coFlag_dff   (.q(temp_co), .d(co_out), .reset(1'b0), .clk);
		
endmodule 

//flagSetALU_testbench tests for expected and unexpected behavior. 
//This testbench firts has setFlag set to 0 and CBZ_zero to 0 while  
//neg_in, zero_in, of_in, and co_in are set to different values. 
//This is done for three separate tests. Next, setFlag is set 1 for 
//one test, while neg_in, zero_in, of_in, and co_in are all set to 1. 
//The fifth test has setFlag set to 0, with neg_in, zero_in, of_in, 
//and co_in set to different values. This is done to see if the 
//output values would be updated or not if setFlag was 0. 
//The last test sets setFlag to 1 and the values for neg_in, zero_in, 
//of_in, and co_in are slightly different from when they were set the
//first time to make sure the output values will change. The last three
//tests have CBZ_zero set to 1, and has changing values forthe other values.
module flagSetALU_testbench();
		logic clk;
		logic neg_in, zero_in, of_in, co_in, setFlag, CBZ_zero;
		logic neg_out, zero_out, of_out, co_out;
		
		flagSetALU dut(.setFlag, .CBZ_zero, .neg_in, .zero_in, .of_in, .co_in, .neg_out, .zero_out, .of_out, .co_out, .clk);
		
		parameter CLOCK_PERIOD=100;
			initial begin
				clk <= 0;
	forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end

 // Set up the inputs to the design. Each line is a clock cycle.
 initial begin
 @(posedge clk);
			setFlag <= 0; CBZ_zero <= 0; neg_in <= 0; 
			zero_in <= 0; of_in <= 0; co_in <= 0; repeat(1) @(posedge clk);
			
			setFlag <= 0; CBZ_zero <= 0; neg_in <= 1; 
			zero_in <= 1; of_in <= 1; co_in <= 1; repeat(1) @(posedge clk);
			
			setFlag <= 0; CBZ_zero <= 0; neg_in <= 0; 
			zero_in <= 0; of_in <= 1; co_in <= 1; repeat(1) @(posedge clk);
			
			setFlag <= 1; CBZ_zero <= 0; neg_in <= 1; 
			zero_in <= 1; of_in <= 1; co_in <= 1; repeat(1) @(posedge clk);
			
			setFlag <= 0; CBZ_zero <= 0; neg_in <= 1; 
			zero_in <= 1; of_in <= 0; co_in <= 0; repeat(1) @(posedge clk);
			
			setFlag <= 1; CBZ_zero <= 0; neg_in <= 0; 
			zero_in <= 0; of_in <= 1; co_in <= 1; repeat(1) @(posedge clk);
			
			setFlag <= 0; CBZ_zero <= 1; neg_in <= 1; 
			zero_in <= 0; of_in <= 1; co_in <= 0; repeat(1) @(posedge clk);
			
			setFlag <= 1; CBZ_zero <= 1; neg_in <= 1; 
			zero_in <= 1; of_in <= 1; co_in <= 0; repeat(1) @(posedge clk);
			
			setFlag <= 1; CBZ_zero <= 1; neg_in <= 1; 
			zero_in <= 0; of_in <= 1; co_in <= 0; repeat(1) @(posedge clk);
		$stop;
		end
		
endmodule 