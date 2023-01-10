//Leonard Dul and Garrett Tashiro
//October 13, 2021
//EE 469
//Lab 1


//mux16_1 has 16-bit incoming, 4-bit select as inputs and returns
//1-bit out as the output. This module uses two mux8_1 and one
//mux4_1 using hierarchical calls to implement a 16 to 1 mux.
 
`timescale 1ns/10ps

module mux16_1(incoming, select, out);		
		input logic [15:0]	incoming;
		input logic [3:0]		select;
		output logic 			out;
		
		//two 1-bit temp logic's to hold outputs from both mux8_1
		logic temp1, temp2;
		
		//muxy1 takes bits 7-0 from 16-bit input incoming, and bits 2-0 from
	   //input select and returns a 1-bit output to temp1.
		mux8_1 muxy1(.incoming(incoming[7:0]), .select(select[2:0]), .out(temp1));
		
		//muxy2 takes bits 15-8 from 16-bit input incoming, and bits 2-0 from
	   //input select and returns a 1-bit output to temp2.
		mux8_1 muxy2(.incoming(incoming[15:8]), .select(select[2:0]), .out(temp2));
		
		//muxyFinal takes 1-bit temp1 and temp2 as inputs and returns 1-bit 
		//out as an output to fully implement a 16 to 1 mux.
		mux2_1 muxyFinal(.a(temp1), .b(temp2), .s(select[3]), .out(out));
endmodule 

//mux16_1_testbench tests four different instances for four values
//for incoming in which should output high. Also checks for everything
//zeroed out. There is also for loop tests which tests all values for
//select for a value of incoming.
module mux16_1_testbench();
		logic [15:0]	incoming;
		logic [3:0]		select;
		logic 			out;
		
		mux16_1 dut(.incoming, .select, .out);
		
		integer i;
		
		initial begin
				incoming = 16'b0000000000000000; select= 4'b0000;	#10;
								
				incoming = 16'b0001000100010001; select= 4'b1111;	#10;
				incoming = 16'b0001000100010001; select= 4'b0111;	#10;   
				incoming = 16'b0001000100010001; select= 4'b1011;	#10;
				incoming = 16'b0001000100010001; select= 4'b0011;	#10;  
				
				
				incoming = 16'b0000000000000000; select= 4'b0000;	#10;
				
				incoming = 16'b0010001000100010; select= 4'b0110;	#10;
				incoming = 16'b0010001000100010; select= 4'b0010;	#10;
				incoming = 16'b0010001000100010; select= 4'b1110;	#10;
				incoming = 16'b0010001000100010; select= 4'b1010;	#10;
				
				
				incoming = 16'b0000000000000000; select= 4'b0000;	#10;
				
				incoming = 16'b0100010001000100; select= 4'b0101;	#10;
				incoming = 16'b0100010001000100; select= 4'b0001;	#10;
				incoming = 16'b0100010001000100; select= 4'b1101;	#10;
				incoming = 16'b0100010001000100; select= 4'b1001;	#10;
				
				incoming = 16'b0000000000000000; select= 4'b0000;	#10;

				incoming = 16'b1000100010001000; select= 4'b0100;	#10;
				incoming = 16'b1000100010001000; select= 4'b0000;	#10;
				incoming = 16'b1000100010001000; select= 4'b1100;	#10;
				incoming = 16'b1000100010001000; select= 4'b1000;	#10;
				
				
				incoming = 16'd21845;		#10;
				
				for(i = 0; i < 16; i = i + 1) begin
					select = i;					#10;
				end
		end
endmodule
