`timescale 1ns/1ns

// Main top module to implement logic
module LFSR_Top_Module(clk, btnU, seg, an);
    parameter TEXT_WIDTH = 16;
    parameter SEGDIS = 7;               // 7 display segments
    parameter NUM_AN = 4;               // Each 7-segment display has 1 anode for control, total 4
    
    input clk, btnU;
    output [0:SEGDIS-1] seg;
    output [NUM_AN-1:0] an;
    wire [TEXT_WIDTH-1:0] out;
    wire done;
   
    // instantiate LFSR module
    LFSR #(13,0,2,3,12) LSFR_1 (.en(done), .clk(clk), .rst(btnU), .right_shift_lfsr(out));
    // instantiate Display_16_Text_N_second module to display text at 1 sec intervals
    Display_16_Text_N_second #(1) DSTNS_1 (.clk(clk), .rst(btnU), .text(out), .seg(seg), .an(an), .done(done));
endmodule

module LFSR (en, clk, rst, right_shift_lfsr);
    parameter N = 16;               // No. of LFSR bits
    parameter TAP_BIT0 = 0;
    parameter TAP_BIT1 = 1;
    parameter TAP_BIT2 = 2;
    parameter TAP_BIT3 = 3;
    parameter INIT = 4'h0001;       // Initialization value of LFSR upon reset
    
    input en, clk, rst;
    output reg [N-1:0] right_shift_lfsr;
    wire d;  
    
    assign d = right_shift_lfsr[TAP_BIT3]^right_shift_lfsr[TAP_BIT2]^right_shift_lfsr[TAP_BIT1]^right_shift_lfsr[TAP_BIT0];
    
    always @(posedge clk or posedge rst)
    if(rst)
    begin
         right_shift_lfsr <= INIT;
    end
    else if(en)
    begin
        right_shift_lfsr <= {d, right_shift_lfsr[N-1:1]};
    end
endmodule

/*
module LFSR_Test_Module (en, clk, rst, right_shift_lfsr);
    parameter N = 16;               // No. of LFSR bits
    parameter TAP_BIT0 = 0;
    parameter TAP_BIT1 = 2;
    //parameter TAP_BIT2 = 2;
    //parameter TAP_BIT3 = 3;
    parameter INIT = 4'h0001;       // Initialization value of LFSR upon reset
    
    input en, clk, rst;
    output reg [N-1:0] right_shift_lfsr;
    wire d;  
    
    assign d = right_shift_lfsr[TAP_BIT1]^right_shift_lfsr[TAP_BIT0];
    
    always @(posedge clk or posedge rst)
    if(rst)
    begin
         right_shift_lfsr <= INIT;
    end
    else if(en)
    begin
        right_shift_lfsr <= {d, right_shift_lfsr[N-1:1]};
    end
endmodule
*/






