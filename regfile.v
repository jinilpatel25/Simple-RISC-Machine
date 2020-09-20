module regfile(data_in,writenum,write,readnum,clk,data_out);

	input [15:0] data_in;
	input [2:0] writenum, readnum;
	input write;
	input clk;
	output [15:0] data_out;

	wire [7:0] topdecoderoutput;
	wire [7:0] bottomdecoderoutput;
	wire [15:0] R0;
	wire [15:0] R1;
	wire [15:0] R2;
	wire [15:0] R3;
	wire [15:0] R4;
	wire [15:0] R5;
	wire [15:0] R6;
	wire [15:0] R7;

/*Instantiation #1: Top decoder

Inputs:
1. writenum (local, 3 bit binary): the number of the register we want to write our value to

Outputs:
1. topdecoderoutput (8 bit one hot): the number of the register we want to write out value to in one hot code

*/

decoder #(3,8) topinstance(writenum, topdecoderoutput);

/*Instantation Set #3: all registers

Inputs:
1. clk (local, 1 bit binary): clock signal
2. topload(zero - eight) (#2, 1 bit binary each): load provided to each register load enable circuit (controlling whether or not the value is written to that register)
3. data_in (local, 16 bit binary): the 16 bit input value to store in the relevant register

Outputs:
1. R (0 through 7) (16 bit binary): depending on the load, may store the value on the next rising edge of the clock 

*/

vDFFE #(16) regzero(clk, (topdecoderoutput[0] && write), data_in, R0);
vDFFE #(16) regone(clk, (topdecoderoutput[1] && write), data_in, R1);
vDFFE #(16) regtwo(clk, (topdecoderoutput[2] && write), data_in, R2);
vDFFE #(16) regthree(clk, (topdecoderoutput[3] && write), data_in, R3);
vDFFE #(16) regfour(clk, (topdecoderoutput[4] && write), data_in, R4);
vDFFE #(16) regfive(clk, (topdecoderoutput[5] && write), data_in, R5);
vDFFE #(16) regsix(clk, (topdecoderoutput[6] && write), data_in, R6);
vDFFE #(16) regseven(clk, (topdecoderoutput[7] && write), data_in, R7);

/* Instantiation #4: Lower decoder

Inputs: 
1. readnum (local, 3 bit binary): number of the register storing the value we care about 

Outputs:
1. bottomdecoderoutput (8 bit one hot): register number in one hot code

*/

decoder #(3,8) bottominstance(readnum, bottomdecoderoutput);

/*Instantiation #5: Lower multiplexer

Inputs:
1. all registers (#3, 16 bit binary)
2. bottomdecoderoutput (#4, 8 bit one hot): the register number from which the storedvalue must be copied to data_out, in one hot code (essentially the select)

Outputs: 

1. data_out (16 bit binary): the output value based on the bottomdecoderoutput 

*/

Mux8a #(16) bottommux(R7,R6,R5,R4,R3,R2,R1,R0, bottomdecoderoutput, data_out);


endmodule 

//decoder module  

module decoder(a,b);
 parameter n = 2;
 parameter m = 4;
 
 input [n-1:0] a;
 output [m-1:0] b;
 wire [m-1:0] b = 1 << a;
endmodule

//multiplexer module

module Mux8a(regseven,regsix,regfive,regfour,regthree,regtwo,regone,regzero, decoderoutput, data_out);
	parameter k = 1;
	input [k-1:0] regseven,regsix,regfive,regfour,regthree,regtwo,regone,regzero;
	input [7:0] decoderoutput;
	output [k-1:0] data_out;
	reg [k-1:0] data_out;

always @(*) begin
	case(decoderoutput)
		8'b00000001: data_out = regzero;
		8'b00000010: data_out = regone;
		8'b00000100: data_out = regtwo;
		8'b00001000: data_out = regthree;
		8'b00010000: data_out = regfour;
		8'b00100000: data_out = regfive;
		8'b01000000: data_out = regsix;
		8'b10000000: data_out = regseven;
		default: data_out = {k{1'bx}};
	endcase
end

endmodule 

//register load enabled module 
		
module vDFFE(clk, load, in, storedval);
	parameter n = 1;
	input clk, load;
	input [n-1:0] in;
	output [n-1:0] storedval;
	reg [n-1:0] storedval;
	wire [n-1:0] next_out;

	assign next_out = load ? in : storedval;

	always @(posedge clk)
	storedval = next_out;
endmodule 

