//Leonard Dul and Garrett Tashiro
//October 13, 2021
//EE 469
//Lab 1

`timescale 1ns/10ps

// Single DFF that stores and updates values on the positive edge of a clock

module D_FF (q, d, reset, clk);
	output logic q;
	input logic d, reset, clk;
 
	always_ff @(posedge clk) begin // Hold val until clock edge
		if (reset)
			q <= 0; // On reset, set to 0
		else
			q <= d; // Otherwise out = d
	end
endmodule 

module D_FF_testbench();

	logic q;
	logic d;
	logic reset; 
	logic clk;
	
 D_FF dut (.q, .d, .reset, .clk);
	
parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end

 // Set up the inputs to the design. Each line is a clock cycle.
 initial begin
 @(posedge clk);
 
   //Verify that the values updates and changes through the DFF.
	//No reset so the value is 0.
	d <= 0; reset <= 0; repeat(1) @(posedge clk);
	d <= 1; reset <= 0; repeat(1) @(posedge clk);
	d <= 0; reset <= 0; repeat(1) @(posedge clk);

	

 
 $stop; // End the simulation.
 end
endmodule
