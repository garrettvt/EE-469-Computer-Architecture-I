//Leonard Dul and Garrett Tashiro
//October 13, 2021
//EE 469
//Lab 1

//mux2_1 is a 2 to 1 mux that has 1-bit inputs a, b, 
//and s (enable/select) and returns 1-bit output out.
//Gate primitives are used to compute NOT, AND, and OR. 

//`timescale time_unit base / precision base
`timescale 1ns/10ps

module mux2_1(a, b, s, out);
		input logic		a, b, s;
		output logic	out;
		
		//Follow the equation
		//Out = (~S)A + SB
		//temp logic to hold outputs from gate primitives not and and
		logic notS, temp1, temp2;  
		
		//gate primitive not for ~s
		//gate primitive and for ~sa and sb
		//gate primitive or for temp1 OR temp2 to get out
		not #0.05 aintThis(notS,  s);
		and #0.05 andNot(temp1, notS, a);     
		and #0.05 andThem(temp2, s, b);
		or  #0.05 orThem(out, temp1, temp2);
endmodule

//mux2_1_testbench tests all eight possible cases for expected,
//unexpected, and edgcase behavior. This testbench is setup like 
//a truth table to test when each input is high, or low with all
//other inputs when they are high, or low.		
module mux2_1_testbench();
		logic a, b, s, out;
		
		mux2_1 dut(.a, .b, .s, .out);
		
		initial begin 
			a <= 0; b <= 0; s <= 0;		#10;
			a <= 0; b <= 0; s <= 1;		#10;
			a <= 0; b <= 1; s <= 0;		#10;
			a <= 0; b <= 1; s <= 1;		#10;
			a <= 1; b <= 0; s <= 0;		#10;
			a <= 1; b <= 0; s <= 1;		#10;
			a <= 1; b <= 1; s <= 0;		#10;
			a <= 1; b <= 1; s <= 1;		#10;
		end
endmodule  