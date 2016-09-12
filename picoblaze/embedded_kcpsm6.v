//This file is created by Jagadeesh Vasudevamurthy
//Filename: embedded_kcpsm6.v
module embedded_kcpsm6(
	port_id,
	write_strobe,
	read_strobe,
	out_port,
	in_port,
	interrupt,
	interrupt_ack,
	reset,
	clk);

output[7:0] port_id;
output 	write_strobe;
output 	read_strobe;
output[7:0] out_port;
input[7:0] 	in_port;
input 	interrupt;
output 	interrupt_ack;
input 	reset;
input 	clk;

wire  [7:0] port_id;
wire   	write_strobe;
wire   	read_strobe;
wire  [7:0] out_port;
wire  [7:0] in_port;
wire   	interrupt;
wire   	interrupt_ack;
wire   	reset;
wire   	clk;
wire [11:0] 	address;
wire [17:0] instruction;
wire kcpsm6_sleep;
wire interrupt ;

// copied from /cygdrive/c/work/fpga/course/v/picoblaze/KCPSM6_Release9_30Sept14/extract/Verilog/kcpsm6_design_template.v
    kcpsm6 #(
	.interrupt_vector	(12'h3FF),
	.scratch_pad_memory_size(64),
	.hwbuild		(8'h00))
    processor (
		.address(address), 
		.instruction(instruction), 
		.bram_enable(bram_enable), 
		.in_port(in_port), 
		.out_port(out_port), 
		.port_id(port_id), 
		.write_strobe(write_strobe), 
		.k_write_strobe(k_write_strobe), 
		.read_strobe(read_strobe), 
		.interrupt(interrupt), 
		.interrupt_ack(interrupt_ack), 
		.sleep(sleep), 
		.reset(reset), 
		.clk(clk)
	) ;

 //
  // In many designs (especially your first) interrupt and sleep are not used.
  // Tie these inputs Low until you need them. 
  // 

  assign kcpsm6_sleep = 1'b0;
  assign interrupt = 1'b0;

  prog_rom program(
 	.rdl 			(rdl),
	.enable 		(bram_enable),
	.address 		(address),
	.instruction 	(instruction),
	.clk 			(clk));
endmodule

