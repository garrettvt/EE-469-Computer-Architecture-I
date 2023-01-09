//Leonard Dul and Garrett Tashiro
//October 13, 2021
//EE 469
//Lab 1


//mux32_1 has 32-bit incoming, and 4-bit select as inputs and
//returns 1-bit out as output. This module taks in inputs from
//mux64x31_1, and uses hierarcy to call two mux16_1 and one
//mux2_1 module to take in 32 inputs and produce one output.

//timecale for gate preimitives 
`timescale 1ns/10ps
	
module mux32_1(incoming, select, out);		
		input logic [31:0]		incoming;
		input logic [4:0]			select;
		output logic 				out;		
		
		
		//two 1-bit temp logic's to hold the outputs from each of the 16:1 muultiplexers
		logic temp1, temp2;
		
		//muxy1 to take bits 15-0 from the 32-bit input incoming, and bits 3-0
		//from select and returns 1-bit temp1 as an output. This implements half 
		//of a 32 to 1 mux.
		mux16_1 muxy1(.incoming(incoming[15:0]), .select(select[3:0]), .out(temp1));
		
		//muxy2 to take bits 31-16 from the 32-bit input incoming, and bits 3-0
		//from select and returns 1-bit temp2 as an output. This implements half 
		//of a 32 to 1 mux.
		mux16_1 muxy2(.incoming(incoming[31:16]), .select(select[3:0]), .out(temp2));
		
		//muxyFinal takes 1-bit temp1 and temp2 as inputs and returns 1-bit 
		//out as an output to fully implement a 32 to 1 mux.
		mux2_1 muxyFinal(.a(temp1), .b(temp2), .s(select[4]), .out(out));
endmodule 

//mux32_1_testbench tests a few cases that will test high for the 4 to 1
//mux, as well as two for loops to test two values for incoming and they
//check over all values for select for each.
module mux32_1_testbench();
		logic [31:0]	incoming;
		logic [4:0]		select;
		logic 			out;
		
		mux32_1 dut(.incoming, .select, .out);
		
		integer i;
		
		initial begin
				incoming = 32'd286331153; select = 5'b00111; #10;
				select = 5'b10111; #10;
				
				incoming = 32'd572662306; select = 5'b00110; #10;
				select = 5'b10110; #10;
				
				incoming = 32'd1145324612; select = 5'b00101; #10;
				select = 5'b10101; #10;
				
				incoming = 32'd2290649224; select = 5'b00100; #10;
				select = 5'b10100; #10;
				
				
				incoming = 32'd1431655765;		#10;
				for(i = 0; i < 32; i = i + 1) begin
					select = i;						#10;
					assert(incoming[i] == out);
				end
				
				incoming = 32'd2863311530;		#10;
				for(i = 0; i < 32; i = i + 1) begin
					select = i;						#10;
				end
		end
endmodule 