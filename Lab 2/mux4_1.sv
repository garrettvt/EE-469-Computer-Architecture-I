//Leonard Dul and Garrett Tashiro
//October 13, 2021
//EE 469
//Lab 1


//mux4_1 has 4-bit incoming and 2-bit select as inputs and returns 
//1-bit out as the output. This module implements a 4 to 1 mux by
//using hierarchical calls to bring in three mux2_1. 

`timescale 1ns/10ps

module mux4_1(incoming, select, out);		
		input logic [3:0]		incoming;
		input logic [1:0]		select;
		output logic 			out;
		
		//1-bit temp logic to hold outputs from muxy1 and mux2 to use as inputs in muxFin
		logic temp1, temp2;
		
		//Y=s1′s0′inc[3]+s1′s0inc[2]+s1s0′inc[1]+s1s0inc[0]
		
		//muxy1 takes in bits 1-0 of 4-bit incoming as well as bit 0 from 2-bit select.
		//the output from muxy1 is held by temp1 logic.
		mux2_1 muxy1(.a(incoming[0]), .b(incoming[1]), .s(select[0]), .out(temp1)); 
	   
		//muxy2 takes in bits 3-2 of 4-bit incoming as well as bit 0 from 2-bit select.
		//the output from muxy2 is held by temp1 logic.	
		mux2_1 muxy2(.a(incoming[2]), .b(incoming[3]), .s(select[0]), .out(temp2));  
		
		//muxFin takes the 1-bit outputs from muxy1 and muxy2 as uses them as inputs
		//for a and b, and it also uses select[1] as input for s, and returns a 1-bit 
		//output out.
		mux2_1 muxFin(.a(temp1), .b(temp2), .s(select[1]), .out(out));  				  
endmodule 

//mux4_1_testbench tests all possible case for expected, unexpected,
//and edgecase behavior. The testbench sets incomings bits to 4'd0 through
//4'd15 and tests all four possible combinations for selects bits.
module mux4_1_testbench();
		logic [3:0]		incoming;
		logic [1:0]		select;
		logic				out;
		
		mux4_1 dut(.incoming, .select, .out);
		
		//y = (~s)a + sb
		initial begin 
			incoming <= 4'b0000; select <= 2'b00;	#10;  //		   0
			incoming <= 4'b0000; select <= 2'b01;	#10;   
			incoming <= 4'b0000; select <= 2'b10;	#10;  
			incoming <= 4'b0000; select <= 2'b11;	#10;  
		
			incoming <= 4'b0001; select <= 2'b00;	#10;  //		   1
			incoming <= 4'b0001; select <= 2'b01;	#10;   
			incoming <= 4'b0001; select <= 2'b10;	#10;  
			incoming <= 4'b0001; select <= 2'b11;	#10;  //High --> s1s0inc[0]
			
			incoming <= 4'b0010; select <= 2'b00;	#10;  //			2
			incoming <= 4'b0010; select <= 2'b01;	#10;  
			incoming <= 4'b0010; select <= 2'b10;	#10;  //High --> s1s0′inc[1]
			incoming <= 4'b0010; select <= 2'b11;	#10;  
			
			incoming <= 4'b0011; select <= 2'b00;	#10;  //    	3
			incoming <= 4'b0011; select <= 2'b01;	#10;  
			incoming <= 4'b0011; select <= 2'b10;	#10;  
			incoming <= 4'b0011; select <= 2'b11;	#10;  
			
			incoming <= 4'b0100; select <= 2'b00;	#10;  //  		4
			incoming <= 4'b0100; select <= 2'b01;	#10;  //High --> s1′s0inc[2]
			incoming <= 4'b0100; select <= 2'b10;	#10;  
			incoming <= 4'b0100; select <= 2'b11;	#10;   
			
			incoming <= 4'b0101; select <= 2'b00;	#10;  //			5
			incoming <= 4'b0101; select <= 2'b01;	#10;  
			incoming <= 4'b0101; select <= 2'b10;	#10;  
			incoming <= 4'b0101; select <= 2'b11;	#10;  
				
			incoming <= 4'b0110; select <= 2'b00;	#10;  //			6
			incoming <= 4'b0110; select <= 2'b01;	#10;  
			incoming <= 4'b0110; select <= 2'b10;	#10;  
			incoming <= 4'b0110; select <= 2'b11;	#10;  
			
			incoming <= 4'b0111; select <= 2'b00;	#10;  //			7
			incoming <= 4'b0111; select <= 2'b01;	#10;  
			incoming <= 4'b0111; select <= 2'b10;	#10;  
			incoming <= 4'b0111; select <= 2'b11;	#10;  
			
			incoming <= 4'b1000; select <= 2'b00;	#10;  // 	   8   High --> s1′s0′inc[3]
			incoming <= 4'b1000; select <= 2'b01;	#10;  
			incoming <= 4'b1000; select <= 2'b10;	#10;  
			incoming <= 4'b1000; select <= 2'b11;	#10;  
			
			incoming <= 4'b1001; select <= 2'b00;	#10;  // 	   9
			incoming <= 4'b1001; select <= 2'b01;	#10;  
			incoming <= 4'b1001; select <= 2'b10;	#10;  
			incoming <= 4'b1001; select <= 2'b11;	#10;  
	
			incoming <= 4'b1010; select <= 2'b00;	#10;  //       10
			incoming <= 4'b1010; select <= 2'b01;	#10;  
			incoming <= 4'b1010; select <= 2'b10;	#10;  
			incoming <= 4'b1010; select <= 2'b11;	#10;  
			
			incoming <= 4'b1011; select <= 2'b00;	#10;  // 	   11
			incoming <= 4'b1011; select <= 2'b01;	#10;  
			incoming <= 4'b1011; select <= 2'b10;	#10;  
			incoming <= 4'b1011; select <= 2'b11;	#10;  
			
			incoming <= 4'b1100; select <= 2'b00;	#10;  // 	   12
			incoming <= 4'b1100; select <= 2'b01;	#10;  
			incoming <= 4'b1100; select <= 2'b10;	#10;  
			incoming <= 4'b1100; select <= 2'b11;	#10;  
			 
			incoming <= 4'b1101; select <= 2'b00;	#10;  //       13
			incoming <= 4'b1101; select <= 2'b01;	#10;  
			incoming <= 4'b1101; select <= 2'b10;	#10;  
			incoming <= 4'b1101; select <= 2'b11;	#10;  
			
			incoming <= 4'b1110; select <= 2'b00;	#10;  //       14
			incoming <= 4'b1110; select <= 2'b01;	#10;  
			incoming <= 4'b1110; select <= 2'b10;	#10;  
			incoming <= 4'b1110; select <= 2'b11;	#10;  
			
			incoming <= 4'b1111; select <= 2'b00;	#10;  // 	   15
			incoming <= 4'b1111; select <= 2'b01;	#10;  
			incoming <= 4'b1111; select <= 2'b10;	#10;  
			incoming <= 4'b1111; select <= 2'b11;	#10; 
		end
endmodule
