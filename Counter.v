`timescale 1ns/1ns

// Typical counter, counter increments every clock cycle
module Counter(clk, rst, q);
    parameter N = 8;
   
    input clk, rst;
    output [N-1:0] q;
    reg [N-1:0] q;

    always @ (posedge clk or posedge rst)
    begin
        if(rst == 1'b1) q <= 0;
        else q <= q+1;
    end   
endmodule

// Counter with Enable, counter increments when EN is asserted
module Counter_with_EN(clk, rst, q, en);
    parameter N = 8;
   
    input clk, rst, en;
    output [N-1:0] q;
    reg [N-1:0] q;

    always @ (posedge clk or posedge rst)
    begin
        if(rst == 1'b1) q <= 0;
        else if(en) q <= q+1;
    end   
endmodule

// Mod Counter with Done, compares with MAX value and asserts Done=1 when matched
module Mod_Counter(clk, rst, q, done);
    parameter N = 8;
    parameter MAX = 255;
    
    input clk, rst;
    output [N-1:0] q;
    output done;
    reg [N-1:0] q;
    reg done;
    
    always @ (posedge clk or posedge rst)
    begin
        if(rst == 1'b1)
        begin
            q <= 0;
            done <= 0;
        end
        else if(q == MAX)
        begin
            q <= 0;
            done <= 1;
        end
        else
        begin    
            q <= q+1;  
            done <= 0;
        end
    end 
endmodule

/*
// Module to generate 1 second timing
module One_Sec(clk, btnU, seg, an, led);
    parameter C_WIDTH = 35;     // 28-bit counter is needed to store count till 100,000,000
    parameter SEGDIS = 7;       // 7-segment display has width 7
    parameter NUM = 4;          // 7-segment display has 1 anode for control
    parameter CRYSTAL = 100;    // FPGA board has 100MHz crystal oscillator
    parameter NUM_SEC = 1;     // We want a '1 sec' unit delay
    parameter [C_WIDTH-1:0] STOPAT = (CRYSTAL * 1_000_000 * NUM_SEC) - 1;     // Counter will stop at 100,000,000 - 1
    
    input clk, btnU;
    output [0:SEGDIS-1] seg;
    output [NUM-1:0] an;
    output [NUM-1:0] led;
    
    wire [C_WIDTH-1:0] big_count;
    wire one_sec_done;
    wire [NUM-1:0] value_to_display;
    
    Mod_Counter #(C_WIDTH, STOPAT) MC1(clk, btnU, big_count, one_sec_done);
    Counter #(NUM) C1(clk, btnU, one_sec_done, zero_to_f);  // 4-bit counter to display 0,1,2,...,E,F
    _7SegmentDisplay SSD1(value_to_display, seg);
    
endmodule

// Counter
module Counter(clk, rst, q);
    parameter N = 8;
   
    input clk, rst;
    output [N-1:0] q;
    reg [N-1:0] q;

    always @ (posedge clk or posedge rst)
    begin
        if(rst == 1'b1) q <= 0;
        else q <= q+1;
    end   
endmodule

// Counter with enable
module Counter(clk, rst, q, en);
    parameter N = 8;
   
    input clk, rst, en;
    output [N-1:0] q;
    reg [N-1:0] q;

    always @ (posedge clk or posedge rst)
    begin
        if(rst == 1'b1) q <= 0;
        else if(en) q <= q+1;
    end   
endmodule

module Mod_Counter(clk, rst, q, done);
    parameter N = 8;
    parameter MAX = 255;
    
    input clk, rst;
    output [N-1:0] q;
    output done;
    reg [N-1:0] q;
    reg done;
    
    always @ (posedge clk or posedge rst)
    begin
        if(rst == 1'b1)
        begin
            q <= 0;
            done <= 0;
        end
        else if(q == MAX)
        begin
            q <= 0;
            done <= 1;
        end
        else
        begin    
            q <= q+1;  
            done <= 0;
        end
    end 
endmodule

module Heartbeat(clk, btnU, seg, an, led);
    parameter C_WIDTH = 28;     // 27-bit counter is needed to store count till 100,000,000
    parameter SEGDIS = 7;       // 7 display segments
    parameter NUM_AN = 4;       // Each 7-segment display has 1 anode for control, total 4
    parameter NUM = 3;          // Numbers 0...7, 3-bits
    parameter CRYSTAL = 100;    // FPGA board has 100MHz crystal oscillator
    parameter NUM_SEC = 1;      // We want a '1 sec' unit delay
    parameter [C_WIDTH-1:0] STOPAT = (CRYSTAL * 1_000_000 * NUM_SEC) - 1;     // Counter will stop at 100,000,000 - 1
    
    input clk, btnU;
    output [0:SEGDIS-1] seg;
    output [NUM_AN-1:0] an;
    output [NUM-1:0] led;
    
    wire [C_WIDTH-1:0] big_count;
    wire one_sec_done;
    wire [NUM-1:0] zero_to_7;

    assign led = zero_to_7;     // Display 0...7 in binary on led[2:0]
  
    // Instantiate a mod-counter to count 1 sec intervals
    Mod_Counter #(C_WIDTH, STOPAT) MC1 (.clk(clk), .rst(btnU), .q(big_count), .done(one_sec_done));
    // Instantiate a 3-bit counter to run 8 heartbeat patterns
    Counter #(NUM) C1 (.clk(clk), .rst(btnU), .en(one_sec_done), .q(zero_to_7));
    // Instantiate 7-segment display to display the 8 heartbeat patterns
    _7SegmentDisplay_Heartbeat SSDH1 (.Switch(zero_to_7), .Display(seg), .An(an));
    
endmodule
*/

/* Module to generate 1 minute timing
Following parameters were changed:
(1) parameter [C_WIDTH-1:0] STOPAT = (CRYSTAL * 1_000_000 * NUM_SEC) - 1;     // Counter will stop at 6,000,000,000 - 1
Reason: Default widt of integer and reg is 32-bits, so we need to explicitly specify the width for greater than
        32-bit parameters

(2) parameter C_WIDTH = 34;     // 33-bit counter is needed to store count till 6,000,000,000
Reason: To count to 6,000,000,000 we need 33-bit counter, since we define width as [C_WIDTH-1:0]

(3) parameter NUM_SEC = 60;     // We want a '1 min' unit delay
Reason: We want to have a 1 minute delay, 60 seconds


module One_Min(clk, btnU, seg, an, led);
    parameter C_WIDTH = 34;     // 33-bit counter is needed to store count till 6,000,000,000
    parameter SEGDIS = 7;       // 7-segment display has width 7
    parameter NUM = 4;          // 7-segment display has 1 anode for control
    parameter CRYSTAL = 100;    // FPGA board has 100MHz crystal oscillator
    parameter NUM_SEC = 60;     // We want a '1 min' unit delay
    parameter [C_WIDTH-1:0] STOPAT = (CRYSTAL * 1_000_000 * NUM_SEC) - 1;     // Counter will stop at 6,000,000,000 - 1
    
    input clk, btnU;
    output [0:SEGDIS-1] seg;
    output [NUM-1:0] an;
    output [NUM-1:0] led;
    
    wire [C_WIDTH-1:0] big_count;
    wire one_sec_done;
    wire [NUM-1:0] zero_to_f;
    
    assign an = 4'b0000;        // All 4 7-segment displays are ON
    assign led = zero_to_f;     // Display 0,1,2,...,E,F as binary on led[3:0]
    
    Mod_Counter #(C_WIDTH, STOPAT) MC1(clk, btnU, big_count, one_sec_done);
    Counter #(NUM) C1(clk, btnU, one_sec_done, zero_to_f);  // 4-bit counter to display 0,1,2,...,E,F
    _7SegmentDisplay SSD1(zero_to_f, seg);
    
endmodule
*/
