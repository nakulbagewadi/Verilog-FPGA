`timescale 1ns/1ns

// Problem 3.9.4 is a Priority Encoder
module Priority_Encoder(Switch, Led);
	input [7:0] Switch;
	output [7:0] Led;
	reg [7:0] Led;
	
	always @ (Switch)
	begin
	  casex(Switch)
        8'b1xxxxxxx:   Led = 8'b10000000;
        8'b01xxxxxx:   Led = 8'b01000000;
        8'b001xxxxx:   Led = 8'b00100000;
	     8'b0001xxxx:   Led = 8'b00010000;
        8'b00001xxx:   Led = 8'b00001000;
        8'b000001xx:   Led = 8'b00000100;
        8'b0000001x:   Led = 8'b00000010;
        8'b00000001:   Led = 8'b00000001;
	     default:       Led = 8'b00000000;
	  endcase
	end
endmodule

module FPGA_Priority_Encoder(sw,led);
   input [7:0] sw;
   output [7:0] led;

   Priority_Encoder PE1(sw, led);
endmodule