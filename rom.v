`timescale 1ns/1ns

module ROM(in,out);
	parameter N = 3;
	parameter O = 14; //9999
	
	input [N-1:0] in;
	output reg [O-1:0] out;
	
	always @(in)
	begin
    case (in)
        0: out = 1;
        1: out = 17;
        2: out = 23;
        3: out = 57;
        4: out = 234;
        5: out = 9;
        6: out = 4878;
        7: out = 9999;
        default: out = 9998;
    endcase
	end
endmodule