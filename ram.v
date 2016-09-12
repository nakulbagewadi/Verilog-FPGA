`timescale 1ns/1ns

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