//Leonard Dul and Garrett Tashiro
//October 13, 2021
//EE 469
//Lab 1


//mux64x32_1 has input 32-bit by 64-bit incoming, and 4-bit input
//select and returns 64-bit output out. This module creates 64 
//32:1 multiplexers.
`timescale 1ns/10ps

module mux64x32_1(incoming, select, out);		
		input logic [31:0][63:0]		incoming;  //64x32 multiplexor
		input logic [4:0]					select;    //4 going into a 
		output logic [63:0] 				out;		
		
		
		 
		logic [63:0][31:0] flipArray;
		//Variable for generate block to flipping
		genvar j, k;
		
		//Generate block for flipping incoming 32x64 to 64x32. Errors otherwise. 
		generate 
		
			for(j = 0; j < 64; j = j + 1) begin: theMuxs  //for loop for the 64-bit portion
				 
				for(k = 0; k < 32; k = k + 1) begin: theData  //for loop for 32-bit portion 
					
			//		or #0.05 (flipArray[j][k], incoming[k][j], 0);
					assign flipArray[j][k] = incoming[k][j];
				end
			end
		endgenerate
		
		//Variable for generate block for all each mux
		genvar i;
		
		generate 
			
			//Loop to create 64 mux32_1
			for(i = 0; i < 64; i = i + 1) begin: eachMux
				mux32_1 allMux(.incoming(flipArray[i][31:0]), .select(select[4:0]), .out(out[i]));
			end
		endgenerate
		
endmodule 

module mux64x32_1_testbench();
		logic [31:0][63:0]	incoming;
		logic [4:0]				select;
		logic [63:0]			out;
		
		mux64x32_1 dut(.incoming, .select, .out);
		
		integer i;
		
		initial begin
				
				for (i=0; i< 32; i=i+1) begin

					incoming[i] = i*64'h0000010204080001;
				end

				for(i = 0; i < 32; i++) begin
					select = i;		#1000;
					assert(out == incoming[i]);
				end
		end
endmodule 
