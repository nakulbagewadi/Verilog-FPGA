`timescale 1ns/1ns

/* 
   FIFO SRL (Queue) logic
   Operations possible on this FIFO ->
   Enque: Put value into the FIFO
   Deque: Take out value from the FIFO
   At one time only one operation can be performed!
   If one or more control signals are asserted at the same time, no action will take place!
   If we try to Enque when the FIFO is Full, data will not be overwritten, but Error will be asserted.
   If we try to Deque from an Empty FIFO, DataOut will hold the last value & Error will be asserted.
*/

// For Vivado to infer a SRL, we cannot have async reset.
module FIFO_SRL(DataIn,DataOut,Full,Empty,Error,Enque,Deque,Clk,Reset);
    parameter DATA_WIDTH = 1;                            // Data bits
    parameter ADDRESS_WIDTH = 8;
    parameter FIFO_DEPTH = 1 << ADDRESS_WIDTH;           // Depth of the FIFO is 2 ^ No. of address bits
   
    input Enque, Deque, Clk, Reset;
    input [DATA_WIDTH-1:0] DataIn;
   
    output Full, Empty;
    output Error;
    output [DATA_WIDTH-1:0] DataOut;
    reg Error;
    reg [DATA_WIDTH-1:0] DataOut;
   
    reg [ADDRESS_WIDTH-1:0] RD_Ptr;                // Pointer will point to the first element of the FIFO
    reg [DATA_WIDTH-1:0] FIFO_Counter;   
   
    reg [DATA_WIDTH-1:0] FIFO [FIFO_DEPTH-1:0];    // FIFO as RAM
    integer i;
   
    assign Full = (FIFO_Counter == FIFO_DEPTH);
    assign Empty = (FIFO_Counter == 0);
   
    always @ (posedge Clk)
    begin
        if(Reset)      
        begin
            RD_Ptr <= 0;
            Error <= 1'b0;
            FIFO_Counter <= 0;
        end
        else
        begin
            if(Enque && !Deque)                         // [WRITE] Enque data into the FIFO, only if FIFO is not full
            begin
                if(Full)                                // Trying to Enque a value on top of a full FIFO
                begin                                   // Do not overwrite data on top, existing top of FIFO will not change
                    Error <= 1'b1;                      // Error!
                    FIFO_Counter <= FIFO_Counter;
                end
                else
                begin
                    for(i=FIFO_DEPTH-1; i>0; i=i-1)
                    begin
                        FIFO[i] <= FIFO[i-1];
                    end
                    FIFO[0] <= DataIn;
                    if(!Empty) RD_Ptr <= RD_Ptr + 1;
                    else       RD_Ptr <= RD_Ptr;
                    FIFO_Counter <= FIFO_Counter + 1;
                end
            end
            else if(Deque && !Enque)                    // [READ] Deque from top of FIFO, only if FIFO is not empty
            begin
                if(Empty)                               // Trying to Deque from an empty FIFO
                begin                                   // For an already empty FIFO, DataOut will hold last value or garbage initially
                    Error <= 1'b1;                      // Error!
                    FIFO_Counter <= FIFO_Counter;
                end
                else
                begin
                    DataOut <= FIFO[RD_Ptr];
                    if(FIFO_Counter != 1) RD_Ptr <= RD_Ptr - 1;
                    else                  RD_Ptr <= RD_Ptr;
                    FIFO_Counter <= FIFO_Counter - 1;
                    Error <= 1'b0;
                end   
            end
        end
    end
endmodule   

/*
// Test bench for Queue
module FIFO_SRL_tb;
   parameter DATA_WIDTH = 1;                            // Data bits
   parameter ADDRESS_WIDTH = 8;
   parameter FIFO_DEPTH = 1 << ADDRESS_WIDTH;           // Depth of the FIFO is 2 ^ No. of address bits
   
   reg Enque, Deque, Clk, Reset;
   reg [WIDTH-1:0] DataIn;
   
   wire Full, Empty, Error;
   wire [ADDRESS_WIDTH-1:0] DataOut;
   wire [ADDRESS_WIDTH-1:0] RD_Ptr;
   
   // module instantiation
   FIFO_SRL Queue (DataIn,DataOut,Full,Empty,Error,Enque,Deque,Clk,Reset);

   reg [10:0] i;
   
   initial
   begin
      Clk    = 1'b0;
      Reset = 1'b1;             // Assert Reset
      Enque  = 1'b0;
      Deque  = 1'b0;
      DataIn = 8'd0;
      
      #10 Reset = 1'b0;        // Remove Reset condition

      #5 Deque = 1'b1;          // Deque values from the FIFO
      #50 Deque = 1'b0;

      #5 Enque = 1'b1;          // Enque values into the FIFO
      DataIn = 8'd0;
      
      for(i=0; i <= (FIFO_DEPTH+2); i=i+1)
      begin
         #50 DataIn = DataIn + 1;   // Enque values into the FIFO
      end
      #50 Enque = 1'b0;

      #5 Deque = 1'b1;          // Deque values from the FIFO
      
      for(i=0; i <= (FIFO_DEPTH+2); i=i+1)
      begin
         #50 Deque = 1'b1;      // Deque values from the FIFO
      end
      #50 Deque = 1'b0;

      #50 Enque = 1'b1;         // Enque values into the FIFO
      DataIn = 8'd20;
      #50 DataIn = 8'd30;
      #50 DataIn = 8'd40;
      #50 DataIn = 8'd50;
      #50 DataIn = 8'd60;
      #50 DataIn = 8'd70;
      #50 DataIn = 8'd80;
      #50 DataIn = 8'd90;
      #50 DataIn = 8'd91;
      #50 DataIn = 8'd92;
      #50 DataIn = 8'd93;
      #50 DataIn = 8'd94;
      #50 DataIn = 8'd95;
      #50 DataIn = 8'd96;
      #50 DataIn = 8'd97;
      #50 DataIn = 8'd98;
      #50 DataIn = 8'd99;
      #50 DataIn = 8'd100;
      #50 Enque = 1'b0;

      #5 Deque = 1'b1;          // Deque values from the FIFO
      #400 Deque = 1'b0;

      #5 Enque = 1'b1;          // Enque values into the FIFO 
      DataIn = 8'd150;
      #50 DataIn = 8'd151;
      #50 DataIn = 8'd152;
      #50 DataIn = 8'd153;
      #50 DataIn = 8'd154;
      #50 DataIn = 8'd155;
      #50 DataIn = 8'd156;
      #50 DataIn = 8'd157;
      #50 DataIn = 8'd158;
      #50 DataIn = 8'd159;
      #50 DataIn = 8'd160;
      #50 DataIn = 8'd161;
      #50 DataIn = 8'd162;
      #50 DataIn = 8'd163;
      #50 DataIn = 8'd164;
      #50 DataIn = 8'd165;
      #50 DataIn = 8'd166;
      #50 DataIn = 8'd167;
      #50 DataIn = 8'd168;
      #50 DataIn = 8'd169;
      #50 DataIn = 8'd170;  
      #50 Enque = 1'b0;     

      #5 Deque = 1'b1;          // Deque values from the FIFO
      #500 Deque = 1'b0;
   end
   
   always
   begin
      #25 Clk = ~Clk;
   end
   
   always @ (*)
   begin
      if(Error)
      begin
         if(Full) $display("Error: Trying to Enque into a full FIFO @ time = %0d ns", $time);
         else if(Empty) $display("Error: Trying to Deque from an empty FIFO @ time = %0d ns", $time);
      end
   end
endmodule

/*
   always @ (posedge Clk or posedge Reset)
   begin
      if(Reset)                                    // Initialize all outputs
      begin
         WR_Ptr <= 0;
         RD_Ptr <= 0;
         FIFO_Counter <= 0;
         Error <= 1'b0;
      end
      else if(Enable)
      begin
         if(Enque && !Deque)                       // [WRITE] Enque data into the FIFO, only if FIFO is not full
         begin
            if(Full)                               // Trying to Enque a value on top of a full FIFO
            begin                                  // Do not overwrite data on top, existing top of FIFO will not change
               Error <= 1'b1;                      // Error!
               FIFO_Counter <= FIFO_Counter;
            end
            else
            begin
               FIFO[WR_Ptr] <= DataIn;
               WR_Ptr <= WR_Ptr + 1;
               FIFO_Counter <= FIFO_Counter + 1;
            end
         end
         else if(Deque && !Enque)                 // [READ] Deque from top of FIFO, only if FIFO is not empty
         begin
            if(Empty)                              // Trying to Deque from an empty FIFO
            begin                                  // For an already empty FIFO, DataOut will hold last value or garbage initially
               Error <= 1'b1;                      // Error!
               FIFO_Counter <= FIFO_Counter;
            end
            else
            begin
               DataOut <= FIFO[RD_Ptr];
               RD_Ptr <= RD_Ptr + 1;
               FIFO_Counter <= FIFO_Counter - 1;
               Error <= 1'b0;
            end   
         end
      end
   end
*/