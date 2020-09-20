/*Module: DATAPATH
Purpose: Integrate the regfile, ALU, shifter and other combinational block units like multiplexers, decoders etc. so as to establish the RISC machine. 

Inputs: 
1. vsel: selects between datapath_in and datapath_out; 
2. datapath_in: The first value we enter into thr RISC machine that needs to be operated.
3. write_num, write, read_num, clk are all defined in the regfile module.
4. input loada, loadb, loadc, loads are used for storing updated data values at different points in the cycle (such as after leaving the register) in the RISC machine.  
5. shift and ALUop are defined in their respective modules shift.v and ALU.v

Outputs: 

1. sximm8: The result of our arithmetic operation is fed into this output. 
2. Z_out: not used in this lab, but is indicative of the status of the ALU operation.  	
	a. if output of ALU operation = 16'b0,  then Z_out = 1
	b. if output = any other value, then Z_out = 0*/


module datapath (clk, // recall from Lab 4 that KEY0 is 1 when NOT pushed

                // register operand fetch stage
                readnum,
                vsel,
                loada,
                loadb,

                // computation stage (sometimes called "execute")
                shift,
                asel,
                bsel,
                ALUop,
                loadc,
                loads,

                // set when "writing back" to register file
                writenum,
                write,  

                // outputs
                Zout, Vout, Nout,
                C,

		//modification
		mdata,
		sximm8,
		sximm5,
		PC
             );				//consistent with the instantiation in lab5_top

	input [3:0] vsel; //9
	input [15:0] mdata;				//REMOVE FROM IN OUT LIST
	input [15:0] sximm8; //NOT ASSIGNED
	input [8:0] PC;					//REMOVE
	wire [15:0] data_in;
	input [15:0] sximm5; //NOT ASSIGNED

	input [2:0]  writenum;	//1
	input write;
	input clk;
	input [2:0] readnum;
	wire [15:0] data_out;

	input loada; //3
	wire [15:0] outa;

	input loadb; //3
	wire [15:0] outb; 

	input [1:0] shift; //8		//all inputs required by other module instantiations
	wire [15:0] sout; 		

	input bsel; //7
	wire [15:0] Bin; 

	input asel; //6
	wire [15:0] Ain;		//all internal signals are declared as wires.

	input [1:0] ALUop; //2
	wire [15:0] out;
	wire Z, V, N;

	input loadc; //5
	output [15:0] C; 

	input loads; //10
	output Zout, Vout, Nout;

//We follow the labelling of the blocks on the RISC machine diagram to instantiate each logic block

modifiedmux #(16) muxnine(mdata, sximm8, {7'b0, PC}, C, vsel, data_in); //9 - Multiplexer - working. 

regfile REGFILE(data_in, writenum, write, readnum, clk, data_out); //1 - working. whole regfile module developed previously is instantiated to write values onto a register and read from these registers.

vDFFEx #(16) rlea(clk, loada, data_out, outa); //3 - working - Register load enable module for load A block on RISC machine diagram (labelled 3) to update value to outa 
Mux3a #(16) muxsix(16'b0, outa, asel, Ain); //6  - working -  Multiplexer instantiated to address whether to choose data value from load A or a garbage value of 16b'0 

vDFFEx #(16) rleb(clk, loadb, data_out, outb); //4 - working - Register load enable module for load B block on RISC machine diagram (labelled 3) to update value to outb
shifter shifterinstance(outb, shift, sout); //8 - working - shifter block uses newly developed module to shift outb to the left or right in order to multiply or divide. 
Mux3a #(16) muxseven(sximm5, sout, bsel, Bin); //9 Selecting between sout (coming from shifter) or {11'b0, datapath_in[4:0]}

ALU aluinstance(Ain, Bin, ALUop, out, Z, V, N); //2 - working - doing the arithddddggxsfffddmetic operation on the two values from register

vDFFEx #(16) rlec(clk, loadc, out, C); // working - updated value to load c - will go to datapath. 
modifiedvDFFEx status(clk, loads, Z, V, N, Zout, Vout, Nout);	  // working - Z_out value updated depending on ALU result - not used in lab 5

endmodule 

module vDFFEx(clk, load, in, out);		//module defined for an RLE - seperately defined because number of inputs were changed. 
	parameter n = 1;
	input clk, load;
	input [n-1:0] in;
	output [n-1:0] out;
	reg [n-1:0] out;
	wire [n-1:0] next_out;

	assign next_out = load ? in : out;

	always @(posedge clk)
	out = next_out;
endmodule 

module Mux3a(a, b, selector, out);		//module defined for Multiplexer - seperately defined because number of inputs were changed
	parameter k = 1;
	input [k-1:0] a, b;
	input selector;
	output [k-1:0] out;
	reg [k-1:0] out;

always @(*) begin				//multiplexer choice depends on selector to choose between a and b depending on the input value on selector. 
	case(selector)
		1'b1: out = a;
		1'b0: out = b;
		default: out = {k{1'bx}};
	endcase
end

endmodule 

module modifiedmux(a, b, c, d, selector, out);		//module defined for Multiplexer - seperately defined because number of inputs were changed
	parameter k = 1;
	input [k-1:0] a, b, c, d;
	input [3:0] selector;
	output [k-1:0] out;
	reg [k-1:0] out;

always @(*) begin				//multiplexer choice depends on selector to choose between a and b depending on the input value on selector. 
	case(selector)
		4'b1000: out = a;
		4'b0100: out = b;
		4'b0010: out = c;
		4'b0001: out = d;
		default: out = {k{1'bx}};
	endcase
end

endmodule 


module modifiedvDFFEx(clk, load, Z, V, N, Zout, Vout, Nout);		//module defined for an RLE - seperately defined because number of inputs were changed. 
	input clk, load, Z, V, N;
	output Zout;
	output Vout;
	output Nout;
	reg Zout, Vout, Nout;
	wire next_outz, next_outv, next_outn;
	
	assign next_outz = load ? Z: Zout; //when load = 1, next_outz assigned the current value of Z, indicating whether the inputs are equal 
	assign next_outv = load ? V: Vout; //when load = 1, next_outv assigned the current value of V, indicating that the output of the ALU cannot be represented in 16 bits
	assign next_outn = load ? N: Nout; //when load = 1, next_outn assigned the current value of N, indicating that the output of the ALU is negative

	always @(posedge clk) begin
		Zout = next_outz; //all outputs set equal to their corresponding next_outs to update their values on the rising edge of the clock
		Vout = next_outv;
		Nout = next_outn;
	end
endmodule 


