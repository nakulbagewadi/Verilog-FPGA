`timescale 1ns/1ns

// Main top module to implement logic
module PrimeNumbers_Top_Module(clk, btnU, seg, an);
    parameter TEXT_WIDTH = 16;
    parameter SEGDIS = 7;               // 7 display segments
    parameter NUM_AN = 4;               // Each 7-segment display has 1 anode for control, total 4
    
    input clk, btnU;
    output [0:SEGDIS-1] seg;
    output [NUM_AN-1:0] an;
    wire [TEXT_WIDTH-1:0] out;
    wire done;
    
    // instantiate prime numbers module
    // Once '.Print(done)' signal is received from the timer module; at intervals of 200ms, 
    // we display the prime number on the 7-seg display, '.Prime(out) -> '.text(out)'
    Prime_Numbers #(3, 1000, 16, 10) PRIME (.Clk(clk), .Rst(btnU), .Print(done), .Prime(out));
    // instantiate Display_16_Text_N_second module to display text at 1 sec intervals
    Display_16_Text_N_second #(1) DSTNS_1 (.clk(clk), .rst(btnU), .text(out), .seg(seg), .an(an), .done(done));
endmodule

//module Prime_Numbers(Clk, Rst, Print, WrEn, DataIn, DataOut, Done, AddrSelector, MemAddr, Prime);
module Prime_Numbers(Clk, Rst, Print, Prime);
    parameter START_AT = 3;                         // start checking for prime numbers from?
                                                    // '1' is not prime, '2' is written to the stack by default
    parameter Nth_PRIME = 1000;                     // find out the first 'N' prime numbers
    parameter DATA_WIDTH = 16;                      // Input & output data width
    parameter ADDRESS_WIDTH = 10;                   // Number of inputs
    parameter RAM_DEPTH = 1 << ADDRESS_WIDTH;       // Depth of memory
    
    parameter [2:0] check_if_prime = 'd0;
    parameter [2:0] push_to_stack = 'd1;
    parameter [2:0] go_to_next_number = 'd2;
    parameter [2:0] print_prime_numbers = 'd3;
    parameter [2:0] go_to_default = 'd7;
    
    input Clk, Rst, Print;
    output reg [DATA_WIDTH-1:0] Prime;

    wire [DATA_WIDTH-1:0] DataIn;
    reg [DATA_WIDTH-1:0] DataOut;   
    wire [ADDRESS_WIDTH-1:0] MemAddr;                   // Memory address of the RAM
    reg WrEn, AddrSelector, Done;
    reg [DATA_WIDTH-1:0] number;  
    reg [DATA_WIDTH-1:0] number_of_primes;
    reg [ADDRESS_WIDTH-1:0] TopPtr;                     // Contains address of the top of stack
    reg [ADDRESS_WIDTH-1:0] Count;                      // pointer goes from addr[0] to TopPtr to check if number is prime
    reg [2:0] state;
    
    // instantiate RAM module to implement a stack
    // data out of the prime number module is input to RAM & output data from RAM is input to prime number module
    RAM #(DATA_WIDTH, ADDRESS_WIDTH) Stack(.Clk(Clk), .WrEn(WrEn), .Addr(MemAddr), .DataIn(DataOut), .DataOut(DataIn));

    assign MemAddr = AddrSelector ? TopPtr : Count; 
    
    always @ (posedge Clk or posedge Rst)
    begin
        if(Rst)
        begin
            AddrSelector <= 1'b1;                           // MemAddr = TopPtr
            WrEn <= 1'b1;                                   // Enable writing to RAM
            Done <= 1'b0;
            TopPtr <= 0;
            DataOut <= 'd2;                                 // RAM[0]=2, on reset always..
            Count <= 1;                                     // we do not read from RAM to divide by 2
            number_of_primes <= 1;                          // '2' is the first prime number
            number <= START_AT;                             // starting number to check if prime
            state <= push_to_stack;                         // '3' is the second prime number, RAM[1]=3
        end
        else
        begin    
            case(state)
            // check if the number is prime
            check_if_prime:  
            begin
                AddrSelector <= 1'b0;                       // MemAddr = Count
                WrEn <= 1'b0;                               // disable writing to RAM
                // we only need to check if number is divisible by prime numbers less than half the number
                // eg. to check if 105 is a prime number, last prime number to divide by is 47 because 53 > (105/2 = 52)
                if((DataIn > (number >> 1)) || (Count > TopPtr))   
                begin
                    state <= push_to_stack;                 // found a prime number!
                end
                if((number % DataIn) == 0)
                begin
                    state <= go_to_next_number;             // not a prime, check the next odd number
                end
                else
                begin
                    Count <= Count + 1;                     // fetch next prime number from the RAM to divide by                    
                end                    
            end
            // the number is prime, push to the stack
            push_to_stack:  
            begin
                AddrSelector <= 1'b1;                       // MemAddr = TopPtr
                WrEn <= 1'b1;                               // Enable writing to RAM                
                TopPtr <= TopPtr + 1;
                DataOut <= number;                          // RAM[TopPtr] = number
                number_of_primes <= number_of_primes + 1;   // found another prime number
                state <= go_to_next_number;
            end
            // change/reset variables to check the next number
            go_to_next_number:
            begin
                WrEn <= 1'b0;                               // disable writing to RAM
                if(number_of_primes >= Nth_PRIME) 
                begin
                    Done <= 1'b1;                           // Done! first 'N' prime numbers found!
                    AddrSelector <= 1'b1;                   // MemAddr = TopPtr
                    TopPtr <= 0;
                    state <= print_prime_numbers;           // go to print state and output prime numbers
                end
                else
                begin
                    state <= check_if_prime;                // go to state 'check_if_prime' to check the next number
                    Done <= 1'b0;                           
                    Count <= 1;                             // we do not read from RAM[0] to divide by 2
                    number <= number + 2;                   // we only check odd numbers...
                    AddrSelector <= 1'b0;                   // MemAddr = Count
                end
            end
            print_prime_numbers:
            begin
                if(Print)
                begin
                    AddrSelector <= 1'b1;                   // MemAddr = TopPtr 
                    WrEn <= 1'b0;                           // disable writing to RAM
                    TopPtr <= TopPtr + 1;                   // print numbers from RAM[0] to RAM[TopPtr]
                    Prime <= DataIn;                        // Send 16-bit text to display
                    if(TopPtr > Count) TopPtr <= 0;         // print from RAM[0] again...
                end
            end
            default:
            begin
                AddrSelector <= 1'b0;                       // MemAddr = Count
                WrEn <= 1'b0;                               // disable writing to RAM
                Count <= 1;                                 // we do not read from RAM to divide by 2
                Done <= 1'b0;
                TopPtr <= 0;
            end
            endcase
        end
    end
endmodule


module RAM(Clk, WrEn, Addr, DataIn, DataOut);
    parameter DATA_WIDTH = 16;                      // Input & output data width
    parameter ADDRESS_WIDTH = 10;                   // Number of inputs
    parameter RAM_DEPTH = 1 << ADDRESS_WIDTH;       // Depth of memory
    
    input Clk, WrEn;
    input[ADDRESS_WIDTH-1:0] Addr;
    input[DATA_WIDTH-1:0] DataIn;
    output[DATA_WIDTH-1:0] DataOut;
    
    reg [DATA_WIDTH-1:0] Ram [RAM_DEPTH-1:0];       // define a memory
    
    assign DataOut = Ram[Addr];                     // Asynchronous read
    
    always @(posedge Clk)
    begin
        if (WrEn) Ram[Addr] <= DataIn;              // Synchronous write, if WrEn = 1
    end
endmodule


// Test bench to test the prime_number module as per the clk_freq/timing actual FPGA board..
module prime_number_tb;
    parameter START_AT = 3;                         // start checking for prime numbers from?
                                                    // '1' is not prime, '2' is written to the stack by default
    parameter Nth_PRIME = 1000;                     // find out the first 'N' prime numbers
    parameter DATA_WIDTH = 16;                      // Input & output data width
    parameter ADDRESS_WIDTH = 10;                   // Number of inputs
    parameter RAM_DEPTH = 1 << ADDRESS_WIDTH;       // Depth of memory

    reg Clk, Rst, Print;
    wire [DATA_WIDTH-1:0] Prime;  
    
    Prime_Numbers #(3, 1000, 16, 10) PRIME (Clk, Rst, Print, Prime);
    
    initial
    begin
       Clk    = 1'b0;
       Rst    = 1'b1;               // Assert Reset to initialize variables
       Print  = 1'b0; 
       #10 Rst  = 1'b0;             // Reset = 0

       #200000000 Print = 1'b1;     // Timer/Display is at 200ms intervals
       #10 Print = 1'b0;     // Timer/Display is at 200ms intervals
       #200000000 Print = 1'b1;     // Timer/Display is at 200ms intervals
       #10 Print = 1'b0;     // Timer/Display is at 200ms intervals
       #200000000 Print = 1'b1;     // Timer/Display is at 200ms intervals
       #10 Print = 1'b0;     // Timer/Display is at 200ms intervals
       #200000000 Print = 1'b1;     // Timer/Display is at 200ms intervals
       #10 Print = 1'b0;     // Timer/Display is at 200ms intervals
       #200000000 Print = 1'b1;     // Timer/Display is at 200ms intervals
       #10 Print = 1'b0;     // Timer/Display is at 200ms intervals
       #200000000 Print = 1'b1;     // Timer/Display is at 200ms intervals
       #10 Print = 1'b0;     // Timer/Display is at 200ms intervals
       #200000000 Print = 1'b1;     // Timer/Display is at 200ms intervals
       #10 Print = 1'b0;     // Timer/Display is at 200ms intervals
       #200000000 Print = 1'b1;     // Timer/Display is at 200ms intervals
       #10 Print = 1'b0;     // Timer/Display is at 200ms intervals
       #200000000 Print = 1'b1;     // Timer/Display is at 200ms intervals
       #10 Print = 1'b0;     // Timer/Display is at 200ms intervals
       #200000000 Print = 1'b1;     // Timer/Display is at 200ms intervals
       #10 Print = 1'b0;     // Timer/Display is at 200ms intervals
    end
    
    always
    begin
       #5 Clk = ~Clk;           // 100MHz clock; 1ns simulation time..
    end
endmodule



