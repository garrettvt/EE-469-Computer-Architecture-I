//Leonard Dul and Garrett Tashiro
//November 04, 2021
//EE 469
//Lab 3

`timescale 1ns/10ps

//lowerDataStim is the testbench for our upper level module.
//This testbench uses a clk and a reset. The test sets reset high
//for one clock cycle, then low for 500.

module lowerDataStim();

	logic clk, reset;
	
	lowerData dut (.*);
	
	initial $timeformat(-9,2,"ns",10);

 // Set up a simulated clock.
 parameter CLOCK_PERIOD=10000;
 initial begin
 clk <= 0;
 forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
 end

 //integer i
 initial begin
 //repeat(1) @(posedge clk);
 reset <= 1; repeat(1) @(posedge clk);
 reset <= 0; repeat(50) @(posedge clk);
 $stop; // End the simulation.
 end 
endmodule	
	
