//Leonard Dul and Garrett Tashiro
//October 23, 2021
//EE 469
//Lab 2

`timescale 1ns/10ps

// fullAdder unit supports single bit addition operations. The unit provide a Cout signal
// based on AB+ACin+BCin. The arimethic operation of the bits are dependent on xor'ing A,B, and Cin.

module fullAdder(A, B, Cin, Cout, S);
	input logic A, B, Cin;
	output logic Cout, S;
	
	logic wire1, wire2, wire3;
	
	and #0.05 conn1(wire1, A, B);
	and #0.05 conn2(wire2, A, Cin);
	and #0.05 conn3(wire3, B, Cin);
	or  #0.05 carryCombo(Cout, wire1, wire2, wire3);
	xor #0.05 outputFinal(S, A, B, Cin);
	
endmodule

module fullAdder_testbench();
		logic A, B, Cin, Cout, S;
		
		fullAdder dut(.A, .B, .Cin, .Cout, .S);
		
		// This testbench tests every combination of A,B, and Cin.
		initial begin 
			A <= 0; B <= 0; Cin <= 0;		#10;
			A <= 0; B <= 0; Cin <= 1;		#10;
			A <= 0; B <= 1; Cin <= 0;		#10;
			A <= 0; B <= 1; Cin <= 1;		#10;
			A <= 1; B <= 0; Cin <= 0;		#10;
			A <= 1; B <= 0; Cin <= 1;		#10;
			A <= 1; B <= 1; Cin <= 0;		#10;
			A <= 1; B <= 1; Cin <= 1;		#10;

		end
endmodule
