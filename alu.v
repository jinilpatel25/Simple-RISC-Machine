/*

Module: ALU
Purpose: the purpose of the Arithmetic Logic Unit (ALU) is to perform four standard operations - addition, subtraction, bitwise AND (Boolean logic) and bitwise NOT (Boolean logic)

Inputs:
1. Ain (16 bit binary) - input A
2. Bin (16 bit binary) - input B
3.  ALUop (2 bit binary) - this specifices the ALU operation we want to perform using inputs A and B:
	a. if ALUop = 00, we add inputs A and B
	b. if ALUop = 01, we subtract input B from input A
	c. if ALUop = 10, we bitwise AND inputs A and B
	d. if ALUop = 11, we bitwise NOT input B

Outputs:
1. out (16 bit binary) - output of the ALU after specified operation has been performed on inputs A and B 
2. Z, V, N (1 bit binary) - signals to indicate the status of the result of the ALU:
	a. if out = 16'b0,  then Z = 1 (inputs to ALU are equal) 
	b. if out[15] == 1, then N = 1 (output of ALU is negative)
	c. if {~(Ain[15] && Bin[15]),(Ain[15] && Bin[15])} == 2'b01), then V = 1 (output of ALU cannot be represented in 16 bits)

*/


//i/o described in header
module ALU(Ain, Bin, ALUop, out, Z, V, N);
	input [15:0] Ain, Bin;
	input [1:0] ALUop;
	output [15:0] out;
	output Z;
	output V;
	output N;

	reg [15:0] out;
	reg Z, V, N;

always @(*) begin

//cases specified in header
case(ALUop)
	2'b00: out = Ain + Bin; //case 3a.
	2'b01: out = Ain - Bin; //case 3b.
	2'b10: out = Ain & Bin; //case 3c.
	2'b11: out = ~(Bin); //case 3d.
	default: out = 16'bxxxxxxxxxxxxxxxx;  //default case sets all 16 bits of the output to unspecified binary
endcase

//condition explained in header 

if(out == 0) begin //zero condition
	Z = 1;
	V = 0;
	N = 0;
end else if ( {~(Ain[15] && Bin[15]),(Ain[15] && Bin[15])} == 2'b01) begin //overflow condition
	Z = 0;
	V = 1;
	N = 0;
end else if (out[15] == 1) begin //negative condition
	Z = 0;
	V = 0;
	N = 1;
end else begin 
	Z = 0;
	V = 0;
	N = 0;
end
end
endmodule 
