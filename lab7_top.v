//definitions: MREAD and MWRITE to match the m_cmd values for the respective operations 

`define MREAD 2'b01
`define MWRITE 2'b10

module lab8_top(KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, CLOCK_50); //top module
	input [3:0] KEY; //I/O interface with the De1-SoC
	input [9:0] SW;
	output [9:0] LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	input CLOCK_50;

wire Z, N, V;
wire [15:0] datapath_out; //C from Lab 6 became datapath_out in Lab 7

//wires declared for modifications in Lab 7
wire [15:0] read_data;
wire [7:0] read_address;
wire [7:0] write_address;
reg writemem, enabletridriv;
wire [15:0] din, dout;
wire msel;
wire [8:0] mem_addr;
wire [1:0] m_cmd;
wire [15:0] write_data;
wire halt_state_output;

//assigns read_address and write_address to the same first 8 bits of the mem_addr line as specified by Figure 2 in the lab handout 
assign read_address = mem_addr[7:0];
assign write_address = mem_addr[7:0];

RAM #(16,8) MEM(CLOCK_50, read_address, write_address, writemem, din, dout); //memory instantiation - in Von Neumann architecture, this holds both the instructions for the program and the values used by the program

tribuff maintrinst(dout, enabletridriv, read_data); //instantiation of the tri-state buffer in the CPU module 

cpu CPU(CLOCK_50, 
		~KEY[1], 
		read_data, 
		datapath_out, 
		N, V, Z, 
		mem_addr, 
		m_cmd, write_data,halt_state_output); //instantiation of the main CPU module 

  assign din = write_data; //assigns din continuously to write_data, completing that wired connection as in Figure 2 from the handout 

//hexin and hexout refer to inputs and outputs of the tristate drive used between the switches and the top 8 bits of the read_data line
wire [7:0] hexin;
wire [7:0] hexout;


reg enabletridrivone; //one single enable controls both tristate drivers used in the I/O portion of the Figure in Stage 3 
wire [7:0] switchesout; //used to connect the switches to the bottom 8 bits of read_data

assign hexin = 8'b00000000; //assigned 8 0s because only the bottom 8 bits, controlled by the switches, are relevant

assign read_data[15:8] = hexout; //assigns the top 8 bits to hexout, the output of the tristate driver in the I/O portion of the Figure in Stage 3
assign read_data[7:0] = switchesout; //assigns the bottom 8 bits to the output of the tristate driver in the I/O portion of the Figure in Stage 3

//instantiations of the tristate buffers used in conjunction with the logic described below in the I/O portion of the Figure in Stage 3
tribufftwo triinstonce(hexin, enabletridrivone, hexout);
tribufftwo triinsttwo(SW[7:0],enabletridrivone, switchesout);

reg loadledreg; //simple load to the register between the write_data line and the LEDs

vDFFE #(8) LEDINSTANCE(CLOCK_50, loadledreg, write_data[7:0], LEDR[7:0]); //instantiation of the register with load enable from the I/O portion of the Figure in Stage 3

assign msel = (mem_addr[8] == 1'b0); //continuous assignment of the msel wire to the output of an equality comparator between the 8th bit of the mem_addr line and 1'b0

assign LEDR[8]=(halt_state_output); //LED8 assignment 
always@(*) begin 

if((m_cmd == `MWRITE) && (msel == 1)) begin //this specifies the conditions to write to memory from the write_data/din line
	writemem = 1;
end else begin
	writemem = 0;
end 

if((m_cmd == `MREAD) && (msel == 1)) begin //this specifies the conditions to read from memory onto the dout/read_data line
	enabletridriv = 1;
end else begin
	enabletridriv = 0;
end 

if((m_cmd == `MREAD) && (mem_addr == 9'b101000000)) begin //combinational logic circuit 1 for Stage 3 - controls the value of read_data through the enable to the tristate drivers
	enabletridrivone = 1;
end else begin
	enabletridrivone = 0;
end 

if((m_cmd == `MWRITE) && (mem_addr == 9'b100000000)) begin //combinational logic circuit 2 for Stage 3 - controls the value of the first 8 De1-SoC LEDs through the register load enable with input write_data
	loadledreg = 1;
end else begin
	loadledreg = 0;
end

end

endmodule	

//tristate buffer module used in Stages 1 and 2
module tribuff(inp, en, outp);
	input [15:0] inp;
	input en;
	output [15:0] outp;

	assign outp = en? inp: 16'bz;

endmodule

//tristate buffer module used for I/O circuit 1 in Stage 3
module tribufftwo(inp, en, outp);
	input [7:0] inp;
	input en;
	output [7:0] outp;

	assign outp = en? inp: 8'bz;

endmodule

//memory module
module RAM(clk, read_address, write_address, write, din, dout);
	parameter data_width = 32;
	parameter addr_width = 4;
	parameter filename = "lab8fig2.txt";

	input clk;
	input [addr_width-1:0] read_address, write_address;
	input write;
	input [data_width-1:0] din;
	output [data_width-1:0] dout;
	reg [data_width-1:0] dout;

	reg[data_width-1:0] mem [2**addr_width-1:0];
	
	initial $readmemb(filename, mem);

	always@(posedge clk) begin
		if(write)
			mem[write_address] <= din;
		dout<= mem[read_address];

	end
endmodule 


