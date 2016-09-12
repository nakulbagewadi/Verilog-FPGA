`timescale 1ns/1ns

/*
Truth table for 4-input majority function (2 or more inputs are logic 1, then output is asserted).

sw[6] sw[5] sw[4] sw[3] led[3]   
a     b     c     d     f
------------------------------
0     0     0     0     0
0     0     0     1     0
0     0     1     0     0
0     0     1     1     1
0     1     0     0     0
0     1     0     1     1
0     1     1     0     1
0     1     1     1     1
1     0     0     0     0
1     0     0     1     1
1     0     1     0     1
1     0     1     1     1
1     1     0     0     1
1     1     0     1     1
1     1     1     0     1
1     1     1     1     1

// instantiating using LUT4
LUT4 Majority_Func #(h'FEE8) (f,d,c,b,a);

*/

module Majority_Function(f,a,b,c,d);
	input a,b,c,d;
	output f;
   
   assign f = !((!a&!b&!c&!d) || (!a&!b&!c&d) || (!a&!b&c&!d) || (!a&b&!c&!d) || (a&!b&!c&!d));

endmodule
	

module FPGA_Majority_Function(sw,led);
   input [6:3] sw;
   output [3:3] led;

   Majority_Function MF1(led[3],sw[6],sw[5],sw[4],sw[3]);
endmodule
















