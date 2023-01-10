//Leonard Dul and Garrett Tashiro
//November 28, 2021
//lab 4

`timescale 1ns/10ps 

//forwarding_Unit has 5 bit addrA, addrB, destReg_ALU, destReg_dataMem, 1-bit
//regWE_ALU, and regWE_dataMem and returns 1-bit control_Da1, control_Da2, 
//control_Db1, and control_Db2 as outputs. This module is the control logic for
//the forwarding unit. The module checks to see if the address of Da, or Db
//are equal to the address from the ALU, or Data Mem stages in the processor. 
//The module checks to see if addresses are the same, and if the value has write 
//enabled. 
module forwarding_Unit(addrA, addrB, destReg_ALU, regWE_ALU, destReg_dataMem, regWE_dataMem, control_Da1, control_Da2, control_Db1, control_Db2);
		input logic [4:0] 	addrA, addrB, destReg_ALU, destReg_dataMem;
		input logic 			regWE_ALU, regWE_dataMem;
		output logic			control_Da1, control_Da2, control_Db1, control_Db2;
		
		//This always_comb has case statements for addrA and addrB.
		//Each case has the logic for testing if the Rd value in dataMem
		//or Rd value in ALU are equal, and then checks if write enable
		//is 1 for either, and depending on the tests will determine if 
		//the values for controlling muxes that are passed as outputs
		//and these will decide if a value if forwarded or not. 
		always_comb begin
			case(addrA) 
				destReg_ALU: begin
				
					//if alu is trying to write
					if(regWE_ALU) begin
						if(destReg_ALU == 5'd31) begin
							control_Da1 = 1'b0;
							control_Da2 = 1'b0;
						end
						
						else begin
							control_Da1 = 1'b0;
							control_Da2 = 1'b1;
						end
					end
					
					//if alu is not trying to write, but destReg_ALU and destReg_dataMem are equal
					else if(destReg_ALU == destReg_dataMem) begin
						if(regWE_dataMem) begin
							if(destReg_dataMem == 5'd31) begin
								control_Da1 = 1'b0;
								control_Da2 = 1'b0;
							end
							
							else begin 
								control_Da1 = 1'b1;
								control_Da2 = 1'b1;
							end
						end
						
						else begin
							control_Da1 = 1'b0;
							control_Da2 = 1'b0;
						end
					end
						
					else begin
						control_Da1 = 1'b0;
						control_Da2 = 1'b0;
					end
				end
				
				destReg_dataMem: begin
					if(regWE_dataMem) begin
						if(destReg_dataMem == 5'd31) begin
							control_Da1 = 1'b0;
							control_Da2 = 1'b0;
						end
						
						else begin 
							control_Da1 = 1'b1;
							control_Da2 = 1'b1;
						end
					end
					
					else begin
						control_Da1 = 1'b0;
						control_Da2 = 1'b0;
					end
				end
				
				default: begin
						control_Da1 = 1'b0;
						control_Da2 = 1'b0;
				end
			endcase
			
			case(addrB) 
				destReg_ALU: begin
				
					//if alu is trying to write
					if(regWE_ALU) begin
						if(destReg_ALU == 5'd31) begin
							control_Db1 = 1'b0;
							control_Db2 = 1'b0;
						end
						
						else begin
							control_Db1 = 1'b0;
							control_Db2 = 1'b1;
						end
					end
					
					//if alu is not trying to write, but destReg_ALU and destReg_dataMem are equal
					else if(destReg_ALU == destReg_dataMem) begin
						if(regWE_dataMem) begin
							if(destReg_dataMem == 5'd31) begin
								control_Db1 = 1'b0;
								control_Db2 = 1'b0;
							end
							
							else begin 
								control_Db1 = 1'b1;
								control_Db2 = 1'b1;
							end
						end
						
						else begin
							control_Db1 = 1'b0;
							control_Db2 = 1'b0;
						end
					end
						
					else begin
						control_Db1 = 1'b0;
						control_Db2 = 1'b0;
					end
				end
				
				destReg_dataMem: begin
					if(regWE_dataMem) begin
						if(destReg_dataMem == 5'd31) begin
							control_Db1 = 1'b0;
							control_Db2 = 1'b0;
						end
						
						else begin 
							control_Db1 = 1'b1;
							control_Db2 = 1'b1;
						end
					end
					
					else begin
						control_Db1 = 1'b0;
						control_Db2 = 1'b0;
					end
				end
				
				default: begin
						control_Db1 = 1'b0;
						control_Db2 = 1'b0;
				end
			endcase
		end
endmodule 


//forwarding_Unit_testbench tests for expected and unexpected 
//behavior. The first tets are to check all values against 
//addrA. Rd for ALU is first set to be equal, then the write enables
//are changed to have all four options to check for correct outputs.
//The next set of tests check values against addrB. the Rd values and 
//write enables are all cycled just like for the tests for addrA to
//check for the coret outputs.
module forwarding_Unit_testbench();
		logic [4:0]		addrA, addrB, destReg_ALU, destReg_dataMem;
		logic 			regWE_ALU, regWE_dataMem, control_Da1, control_Da2, control_Db1, control_Db2;
		
		forwarding_Unit dut(.*);
		
		initial begin
			addrA = 5'd0; addrB = 5'd0; destReg_ALU = 5'd0; destReg_dataMem = 5'd0; regWE_ALU = 1'b0; regWE_dataMem = 1'b0; 	#10;
			
			//addrA and destReg_ALU are equal while destReg_dataMem is different. 
			//Run through all options for write enables. 
			addrA = 5'd3;						#10;
			destReg_ALU = 5'd3;					#10;
			regWE_ALU = 1'b1;						#10;
			regWE_dataMem = 1'b1;						#10;
			regWE_ALU = 1'b0;						#10;
			regWE_dataMem = 1'b0;						#10;
			
			destReg_ALU = 5'd0;					#10;
			
			//addrA and destReg_dataMem are equal while destReg_ALU is different. 
			//Run through all options for write enables. 
			destReg_dataMem = 5'd3;				#10;
			regWE_ALU = 1'b1;						#10;
			regWE_dataMem = 1'b1;						#10;
			regWE_ALU = 1'b0;						#10;
			regWE_dataMem = 1'b0;						#10;
			
			
			//addrA, destReg_ALU, and dest_datMem are all equal. 
			//Run through all options for write enables.
			addrA = 5'd10; destReg_ALU = 5'd10; destReg_dataMem = 5'd10;		#10;
			regWE_ALU = 1'b1;						#10;
													#10;
			regWE_dataMem = 1'b1;						#10;
													#10;
			regWE_ALU = 1'b0;						#10;
													#10;
			regWE_dataMem = 1'b0;						#10;
			
			/******************** TEST FOR X31 ********************/
			//Check to see if just the value for addrA is taken
			addrA = 5'd31; destReg_ALU = 5'd31; 	#10;
			regWE_ALU = 1'b1;						#10;
			regWE_dataMem = 1'b1;						#10;
			regWE_ALU = 1'b0;						#10;
			regWE_dataMem = 1'b0;						#10;
			destReg_ALU = 5'd0; 				   #10;
			
			destReg_dataMem = 5'd31;		   #10;
			regWE_ALU = 1'b1;						#10;
			regWE_dataMem = 1'b1;						#10;
			regWE_ALU = 1'b0;						#10;
			regWE_dataMem = 1'b0;						#10;
			
			addrA = 5'd31; destReg_ALU = 5'd31; destReg_dataMem = 5'd31;	#10;
			regWE_ALU = 1'b1;						#10;
			regWE_dataMem = 1'b1;						#10;
			regWE_ALU = 1'b0;						#10;
			regWE_dataMem = 1'b0;						#10;
			
			
			
			
			
			
			addrA = 5'd0; addrB = 5'd0; destReg_ALU = 5'd0; destReg_dataMem = 5'd0; regWE_ALU = 1'b0; regWE_dataMem = 1'b0; 	#10;
			
			//addrB and destReg_ALU are equal while destReg_dataMem is different. 
			//Run through all options for write enables. 
			addrB = 5'd3;						#10;
			destReg_ALU = 5'd3;					#10;
			regWE_ALU = 1'b1;						#10;
			regWE_dataMem = 1'b1;						#10;
			regWE_ALU = 1'b0;						#10;
			regWE_dataMem = 1'b0;						#10;
			
			destReg_ALU = 5'd0;					#10;
			
			//addrB and destReg_dataMem are equal while destReg_ALU is different. 
			//Run through all options for write enables. 
			destReg_dataMem = 5'd3;				#10;
			regWE_ALU = 1'b1;						#10;
			regWE_dataMem = 1'b1;						#10;
			regWE_ALU = 1'b0;						#10;
			regWE_dataMem = 1'b0;						#10;
			
			
			//addrB, destReg_ALU, and dest_datMem are all equal. 
			//Run through all options for write enables.
			addrB = 5'd10; destReg_ALU = 5'd10; destReg_dataMem = 5'd10;		#10;
			regWE_ALU = 1'b1;						#10;
													#10;
			regWE_dataMem = 1'b1;						#10;
													#10;
			regWE_ALU = 1'b0;						#10;
													#10;
			regWE_dataMem = 1'b0;						#10;
			
			/******************** TEST FOR X31 ********************/
			//Check to see if just the value for addrB is taken
			addrB = 5'd31; destReg_ALU = 5'd31; 	#10;
			regWE_ALU = 1'b1;						#10;
			regWE_dataMem = 1'b1;						#10;
			regWE_ALU = 1'b0;						#10;
			regWE_dataMem = 1'b0;						#10;
			destReg_ALU = 5'd0; 				   #10;
			
			destReg_dataMem = 5'd31;		   #10;
			regWE_ALU = 1'b1;						#10;
			regWE_dataMem = 1'b1;						#10;
			regWE_ALU = 1'b0;						#10;
			regWE_dataMem = 1'b0;						#10;
			
			addrB = 5'd31; destReg_ALU = 5'd31; destReg_dataMem = 5'd31;	#10;
			regWE_ALU = 1'b1;						#10;
			regWE_dataMem = 1'b1;						#10;
			regWE_ALU = 1'b0;						#10;
			regWE_dataMem = 1'b0;						#10;
		end
endmodule 
