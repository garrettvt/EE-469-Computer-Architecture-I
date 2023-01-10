//Leonard Dul and Garrett Tashiro
//October 13, 2021
//EE 469
//Lab 1


//mux8_1 takes 8-bit incoming, 3-bit select as inputs and returns
//1-bit out as the output. This module uses hierarchical calls for
//two mux4_1 and one mux2_1 to implement an 8 to 1 mux. 
`timescale 1ns/10ps

module mux8_1(incoming, select, out);		
		input logic [7:0]		incoming;
		input logic [2:0]		select;
		output logic 			out;
		
		//1-bit temp logic to hold outputs from both mux4_1
		logic temp1, temp2;
		
		//muxy1 takes in bits 3-0 or 8-bit incoming, bits 1-0 of 3-bit select
		//as inputs and has temp1 take the output of the 4 to 1 mux. 
		mux4_1 muxy1(.incoming(incoming[3:0]), .select(select[1:0]), .out(temp1)); 
	
		//muxy2 takes in bits 7-4 or 8-bit incoming, bits 1-0 of 3-bit select
		//as inputs and has temp2 take the output of the 4 to 1 mux.
		mux4_1 muxy2(.incoming(incoming[7:4]), .select(select[1:0]), .out(temp2));
		
		//muxyFinal takes 1-bit temp1 and temp2, and bit 2 of 3-bit select as
		//inputs and returns 1-bit out as an output.
		mux2_1 muxyFinal(.a(temp1), .b(temp2), .s(select[2]), .out(out));
endmodule 

//mux8_1_testbench tests all possible inputs select for eight different
//input values for incoming, as well as different tests for high values
module mux8_1_testbench();
		logic [7:0]		incoming;
		logic [2:0]		select;
		logic 			out;
		
		mux8_1 dut(.incoming, .select, .out);
		
		initial begin
			incoming = 8'd204; select = 3'b000;		#10;  //8'b11001100
			select = 3'b001;								#10;
		   select = 3'b010;								#10;
			select = 3'b011;								#10;
			select = 3'b100;								#10;
			select = 3'b101;								#10;
			select = 3'b110;								#10;
			select = 3'b111;								#10;
			incoming = 8'd51; select = 3'b000;		#10;  //8'b00110011
			select = 3'b001;								#10;
		   select = 3'b010;								#10;
			select = 3'b011;								#10;
			select = 3'b100;								#10;
			select = 3'b101;								#10;
			select = 3'b110;								#10;
			select = 3'b111;								#10;
			incoming = 8'd240; select = 3'b000;		#10;  //8'b11110000
			select = 3'b001;								#10;
		   select = 3'b010;								#10;
			select = 3'b011;								#10;
			select = 3'b100;								#10;
			select = 3'b101;								#10;
			select = 3'b110;								#10;
			select = 3'b111;								#10;
			incoming = 8'd15; select = 3'b000;		#10;  //8'b00001111
			select = 3'b001;								#10;
		   select = 3'b010;								#10;
			select = 3'b011;								#10;
			select = 3'b100;								#10;
			select = 3'b101;								#10;
			select = 3'b110;								#10;
			select = 3'b111;								#10;
			incoming = 8'd0; select = 3'b000;		#10;  //8'b00000000
			select = 3'b001;								#10;
		   select = 3'b010;								#10;
			select = 3'b011;								#10;
			select = 3'b100;								#10;
			select = 3'b101;								#10;
			select = 3'b110;								#10;
			select = 3'b111;								#10;
			incoming = 8'd255; select = 3'b000;		#10;  //8'b11111111
			select = 3'b001;								#10;
		   select = 3'b010;								#10;
			select = 3'b011;								#10;
			select = 3'b100;								#10;
			select = 3'b101;								#10;
			select = 3'b110;								#10;
			select = 3'b111;								#10;
			incoming = 8'd170; select = 3'b000;		#10;  //8'b10101010
			select = 3'b001;								#10;
		   select = 3'b010;								#10;
			select = 3'b011;								#10;
			select = 3'b100;								#10;
			select = 3'b101;								#10;
			select = 3'b110;								#10;
			select = 3'b111;								#10;
			incoming = 8'd85; select = 3'b000;		#10;  //8'b01010101
			select = 3'b001;								#10;
		   select = 3'b010;								#10;
			select = 3'b011;								#10;
			select = 3'b100;								#10;
			select = 3'b101;								#10;
			select = 3'b110;								#10;
			select = 3'b111;								#10;
			incoming = 8'b00000000; select = 3'b000;		#10;  //zero out
			incoming = 8'b00010001; select = 3'b111;		#10;  //High in 4:1 mux --> s1s0inc[0]
			incoming = 8'b00010001; select = 3'b011;		#10;  //High
			incoming = 8'b00000000; select = 3'b000;		#10;
			
			incoming = 8'b00100010; select = 3'b000;		#10;
			incoming = 8'b00100010; select = 3'b010;		#10;  //High
			incoming = 8'b00100010; select = 3'b110;		#10;  //High
			incoming = 8'b00100010; select = 3'b111;		#10;
			
			incoming = 8'b00000000; select = 3'b000;		#10;  //zero out
			incoming = 8'b01000100; select = 3'b101;		#10;
			incoming = 8'b01000100; select = 3'b001;		#10;

			incoming = 8'b00000000; select = 3'b000;		#10;  //zero out
			incoming = 8'b10001000; select = 3'b100;		#10;
			incoming = 8'b10001000; select = 3'b000;		#10;
		end
endmodule
