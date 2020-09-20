/*

Module: shifter
Purpose: to either multiply or divide a binary number by two

Inputs: 
1. in (16 bit binary) - binary input number to be manipulated  
2. shift (2 bit binary) - this specifices the operation to be performed on the binary input 'in' as follows:
	a. if shift = 00, the input remains unchanged
	b. if shift = 01, the values of each index of the input are shifted one to the left, causing the whole value to be multipled by two (e.g. 16'b0...01 = 1 becomes 16'b0...10 = 2)
	c. if shift = 10 the values of each index of the input are shifted one to the right AND the most significant bit (15th index) of the output always equals zero, causing the whole value to be divided by two (e.g. 16'b0...10 = 2 becaomes 16'b0...01 = 1)
	d. if shift = 11, the values of each index of the input are shifted one to the right AND the most significant bit (15th index) of the output remains unchanged

Outputs:
1. sout (16 bit binary) - result of manipulating the input according to one of the operations above 

*/

//i/o specified in header
module shifter(in, shift, sout);
	input [15:0] in; 
	input [1:0] shift; 
	output reg [15:0] sout;

always @(*) begin
//Cases specified in header
case(shift)

//Case 2a.
2'b00: begin
sout = in; 
end

//Case 2b.
2'b01: begin
sout[0] = 0;
sout[1] = in[0];
sout[2] = in[1];
sout[3] = in[2];
sout[4] = in[3];
sout[5] = in[4];
sout[6] = in[5];
sout[7] = in[6];
sout[8] = in[7];
sout[9] = in[8];
sout[10] = in[9];
sout[11] = in[10];
sout[12] = in[11];
sout[13] = in[12];
sout[14] = in[13];
sout[15] = in[14];

end

//Case 2c.
2'b10: begin
sout[0] = in[1];
sout[1] = in[2];
sout[2] = in[3];
sout[3] = in[4];
sout[4] = in[5];
sout[5] = in[6];
sout[6] = in[7];
sout[7] = in[8];
sout[8] = in[9];
sout[9] = in[10];
sout[10] = in[11];
sout[11] = in[12];
sout[12] = in[13];
sout[13] = in[14];
sout[14] = in[15];
sout[15] = 0;
end

//Case 2d.
2'b11: begin
sout[0] = in[1];
sout[1] = in[2];
sout[2] = in[3];
sout[3] = in[4];
sout[4] = in[5];
sout[5] = in[6];
sout[6] = in[7];
sout[7] = in[8];
sout[8] = in[9];
sout[9] = in[10];
sout[10] = in[11];
sout[11] = in[12];
sout[12] = in[13];
sout[13] = in[14];
sout[14] = in[15];
sout[15] = in[15];
end

default: sout = 16'bxxxxxxxxxxxxxxxx; //default case sets all 16 bits of the output to unspecified binary

endcase

end 

endmodule 
