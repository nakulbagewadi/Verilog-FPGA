`timescale 1ns/1ns

// Main top module to implement logic
module Algorithm_Top_Module(clk, btnU, seg, an);
    parameter C_WIDTH = 35;
    parameter TEXT_WIDTH = 16;
    parameter SEGDIS = 7;               // 7 display segments
    parameter NUM_AN = 4;               // Each 7-segment display has 1 anode for control, total 4
    parameter COLLATZ_SEED = 27;        // Starting value for Collatz conjecture
    parameter START_STOPWATCH_AT = 0;   // Beginning time for stop watch
    parameter FIBONACCI_SEED_0 = 0;     // first number in Fibonacci series
    parameter FIBONACCI_SEED_1 = 1;     // second number in Fibonacci series
    
    input clk, btnU;
    output [0:SEGDIS-1] seg;
    output [NUM_AN-1:0] an;
    
    wire [TEXT_WIDTH-1:0] text;
    wire [TEXT_WIDTH-1:0] out;
    wire done;
    reg [TEXT_WIDTH-1:0] number;
/*  // uncomment for stop watch and collatz, comment out for fibonacci
    always @(posedge clk or posedge btnU)
    begin
        if (btnU)                           // reset
            number = COLLATZ_SEED;
        else if (done)                      // 'N' second interval over
            number = out;
    end
*/    
    // instantiate Stop watch module
    //StopWatch #(9959) STPWCH_1 (.In(number), .Out(out));                  // Problem 4.8.6
    // instantiate Fibonacci Series module
    Fibonacci_Series FBS_1 (.Out(out), .En(done), .Clk(clk), .Rst(btnU));  // Problem 4.8.5
    // instantiate Collatz Conjecture module
    //Collatz_Conjecture #(COLLATZ_SEED) CC_1 (.In(number), .Out(out));     // Problem 4.8.4
    // instantiate Display_16_Text_N_second module to display text at 1 sec intervals
    Display_16_Text_N_second #(1) DSTNS_1 (.clk(clk), .rst(btnU), .text(out), .seg(seg), .an(an), .done(done));
endmodule

// In the Fibonacci sequence of numbers, each number is the sum of the previous two numbers.
module Fibonacci_Series(Out, En, Clk, Rst);
    parameter SEED_0 = 0;
    parameter SEED_1 = 1;
    parameter NUMBER_WIDTH = 16;
    
    input Clk, Rst, En;
    //input [NUMBER_WIDTH-1:0] In;
    output reg [NUMBER_WIDTH-1:0] Out;
    
    reg [NUMBER_WIDTH-1:0] Out_n_1;
    
    always @ (posedge Clk or posedge Rst)
    begin
        if(Rst)
        begin
            Out <= SEED_1;
            Out_n_1 <= SEED_0;
        end
        else if(En)
        begin
            Out <= Out_n_1 + Out;
            Out_n_1 <= Out;
        end
    end
endmodule

// If the number is even, divide it by two.
// If the number is odd, triple it and add one.
module Collatz_Conjecture(In, Out);
    parameter SEED = 1;
    parameter NUMBER_WIDTH = 16;
    
    input [NUMBER_WIDTH-1:0] In;
    output reg [NUMBER_WIDTH-1:0] Out;
    reg first_time_done;
    
    always @ (In)
    begin
        if((In == SEED) && (first_time_done != 1'b1))
        begin
            Out = In;
            first_time_done = 1'b1;
        end
        else if(In <= 1)           // if number = 1
        begin
            Out = 1;
        end
        else if(In % 2)            // odd number
        begin
            Out = 3*In + 1;
        end
        else                       // even number
        begin
            Out = In/2;
        end
    end
endmodule

// Stop watch counts from 00.00 to 99.59 before resetting back to 00.00
module StopWatch(In, Out);
    parameter RESET_WHEN = 9959;        // Reset to '00.00' after reaching '99.59'
    parameter NUMBER_WIDTH = 16;
    
    input [NUMBER_WIDTH-1:0] In;
    output reg [NUMBER_WIDTH-1:0] Out;
    
    always @ (In)                   // we enter this loop after every 1 sec.
    begin
        if((In % 100) >= 59)        // 60 seconds over, increment by 1 minute
        begin
            Out = (((In / 100) + 1) * 100);
        end
        else if (In >= RESET_WHEN)  // when stop watch reaches the max. time, reset
        begin
            Out = 0;            
        end
        else                        // otherwise, increment by 1 sec
        begin
            Out = In + 1;            
        end
    end    
endmodule