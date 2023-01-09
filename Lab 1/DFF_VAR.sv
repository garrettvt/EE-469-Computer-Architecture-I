//Leonard Dul and Garrett Tashiro
//October 13, 2021
//EE 469
//Lab 1

`timescale 1ns/10ps

// The DFF_VAR file is used to create an individual register and also includes 
// a 2x1 mux in order to select appropriate register.

module DFF_VAR (q, d, clk, reset, enable); 
 output logic [63:0] q; 
 input logic [63:0] d; 
 input logic clk; 
 input logic reset;
 input logic enable;
 
 logic dataAccepted[63:0];
 
// Generate statement used to create the 64 DFF's used in a single register. 
  
genvar i; 
	generate 
		for(i=0; i<64; i++) begin : eachDff
		
			// 2x1 Mux used in order to select which of the registers recieve the data.
			
			mux2_1 selector (.a(q[i]), .b(d[i]), .s(enable), .out(dataAccepted[i]));
			
			// If selected the data is allowed to be an input to the 64 DFF's.
			
			D_FF dffs (.q(q[i]), .d(dataAccepted[i]), .reset(reset), .clk(clk)); 
		end 
	endgenerate 
endmodule

module DFF_VAR_testbench();

	logic [63:0] q;
	logic [63:0] d; 
	logic clk;
	logic reset;
	logic enable;
	
 DFF_VAR dut (.q, .d, .clk, .reset, .enable);
	
parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end

 // Set up the inputs to the design. Each line is a clock cycle.
 initial begin
 @(posedge clk);
 
	// Test four data inputs into the DFF's and verify that they change on 
	// positive edge of the clock.
	
	d <= 64'd0; enable <= 1; repeat(1) @(posedge clk);
	d <= 64'd1; enable <= 1; repeat(1)@(posedge clk);
	d <= 64'd12; enable <= 1; repeat(1) @(posedge clk);
	d <= 64'd63; enable <= 1; repeat(1) @(posedge clk);
	
	// Turn enable off and verify that the DFF retains the data within it,
	// no updated data.
	
	d <= 64'd10; enable <= 0; repeat(1) @(posedge clk);
	d <= 64'd11; enable <= 0; repeat(1) @(posedge clk);
	
 $stop; // End the simulation.
 end
endmodule
