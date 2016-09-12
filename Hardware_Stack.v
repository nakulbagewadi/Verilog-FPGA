`timescale 1ns/1ns

/* Stack module logic
   Operations possible on this Stack:
   PUSH: Push value in the stack.
   POP:  Pop value on top of the stack.
   TOP:  Only Read value on top of the stack (Not a Pop).
   At one time only one operation can be performed!
   If one or more control signals from amongst Push/Pop/Top are high, no action will take place!
   If we try to Push when the stack is Full, data will not be overwritten, but Error will be asserted.
   If we try to Pop or Top from an Empty stack, DataOut will hold the last value & Error will be asserted.
*/
module HardwareStack(Ptr,DataIn,DataOut,Full,Empty,Error,Push,Pop,Top,Clk,Reset,Enable);
   parameter WIDTH = 8;                            // Data bits
   parameter ADDRESS_BITS = 10;
   parameter DEPTH = 1 << ADDRESS_BITS;            // Depth of the stack is 2 ^ No. of address bits
   
   input Push, Pop, Top, Clk, Reset, Enable;
   input [WIDTH-1:0] DataIn;
   
   output Full, Empty, Error;
   output [WIDTH-1:0] DataOut;
   output [ADDRESS_BITS-1:0] Ptr;                  // Pointer will contain the address of the stack element to be used
   
   reg Full, Empty, Error;
   reg [WIDTH-1:0] DataOut;
   
   reg [ADDRESS_BITS-1:0] Ptr;                     // Pointer will contain the address of the stack element to be used
   reg [WIDTH-1:0] TopReg;                         // Contains top of stack data
   reg [WIDTH-1:0] Stack [DEPTH-1:0];              // Stack
   
   always @ (posedge Clk or posedge Reset)
   begin
      if(Reset)                                    // Initialize all outputs
      begin
         Ptr <= 2'b0;
         Full <= 1'b0;
         Empty <= 1'b1;
         Error <= 1'b0;
      end
      else if(Enable)
      begin
         if(Push && !Pop && !Top)                  // Push data into the stack, only if stack is not full
         begin
            if(Empty)
            begin
               Stack[Ptr] <= DataIn;
               TopReg <= DataIn;                   // Store data at top of stack
               Empty <= 1'b0;
               Error <= 1'b0;
            end
            else if(Full)                          // Trying to Push a value on top of a full stack
            begin                                  // Do not overwrite data on top, existing top of stack will not change
               Error <= 1'b1;                      // Error!
            end
            else
            begin
               Stack[Ptr+1] <= DataIn;             
               TopReg <= DataIn;                   // Store data at top of stack
               if(Ptr == DEPTH-2) Full <= 1'b1;    // If the stack is full, give Full indication
               Ptr <= Ptr + 1;
               Empty <= 1'b0;
               Error <= 1'b0;
            end
         end
         else if(Pop && !Push && !Top)             // Pop top of stack, only if stack is not empty
         begin
            if(!Empty || Full)
            begin
               DataOut <= Stack[Ptr];
               TopReg <= Stack[Ptr-1];             // Store data at top of stack
               Full <= 1'b0;
               Error <= 1'b0;
               if(Ptr == 0) Empty <= 1'b1;         // If stack becomes empty, give Empty indication
               else Ptr <= Ptr - 1;
            end
            else if(Empty)                         // Trying to Pop a value from an empty stack
            begin                                  // For an already empty stack, DataOut will hold last value
               Error <= 1'b1;                      // Error!
            end
         end
         else if(Top && !Push && !Pop)             // Read out the value at Top of stack, only if it is not Empty
         begin
            if(!Empty) 
            begin
               DataOut <= TopReg;                  // Show data at top of stack
            end
            else                                   // Trying to read top of stack from an empty stack
            begin                                  // For an already empty stack, DataOut will hold last value
               Error <= 1'b1;                      // Error!
            end
         end
      end
   end
endmodule   


// Test bench for Stack
module HardwareStack_tb;
   parameter WIDTH = 8;                            // Data bits
   parameter ADDRESS_BITS = 10;
   parameter DEPTH = 1 << ADDRESS_BITS;            // Depth of the stack is 2 ^ No. of address bits
   
   reg Push, Pop, Top, Clk, Reset, Enable;
   reg [WIDTH-1:0] DataIn;
   
   wire Full, Empty, Error;
   wire [WIDTH-1:0] DataOut;
   wire [ADDRESS_BITS-1:0] Ptr;
   
   // module instantiation
   HardwareStack STACK (Ptr,DataIn,DataOut,Full,Empty,Error,Push,Pop,Top,Clk,Reset,Enable);

   reg [10:0] i;
   
   initial
   begin
      Clk    = 1'b0;
      Reset  = 1'b1;          // Assert Reset to initialize variables
      Enable = 1'b0; 
      Push   = 1'b0;
      Pop    = 1'b0;
      Top    = 1'b0;
      DataIn = 8'd0;
      
      #10 Reset  = 1'b0;      // Reset = 0
      Enable = 1'b1;          // Enable

      #5 Top = 1'b1;          // Check value at top of stack
      #50 Top = 1'b0;
      
      #5 Pop = 1'b1;          // Pop values from the stack
      #50 Pop = 1'b0;

      #5 Push = 1'b1;         // Push values on the stack
      DataIn = 8'd0;
      
      for(i=0; i <= (DEPTH+6); i=i+1)
      begin
         #50 DataIn = DataIn + 1;
      end
      #50 Push = 1'b0;
      
      #5 Top = 1'b1;          // Check value at top of stack
      #50 Top = 1'b0;

      #5 Pop = 1'b1;          // Pop values from the stack
      
      for(i=0; i <= (DEPTH+6); i=i+1)
      begin
         #50 Pop = 1'b1;      // Pop values from the stack
      end
      #50 Pop = 1'b0;

      #5 Top = 1'b1;          // Check value at top of stack
      #50 Top = 1'b0;

      #50 Push = 1'b1;        // Push values on the stack
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
      #50 Push = 1'b0;

      #5 Top = 1'b1;          // Check value at top of stack
      #50 Top = 1'b0;

      #5 Pop = 1'b1;          // Pop values from the stack
      #200 Pop = 1'b0;

      #5 Top = 1'b1;          // Check value at top of stack
      #50 Top = 1'b0;

      #5 Pop = 1'b1;          // Pop values from the stack
      #200 Pop = 1'b0;

      #5 Push = 1'b1;         // Push values on the stack 
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
      #50 Push = 1'b0;     

      #5 Top = 1'b1;          // Check value at top of stack
      #50 Top = 1'b0;

      #5 Pop = 1'b1;          // Pop values from the stack
      #200 Pop = 1'b0;

      #5 Top = 1'b1;          // Check value at top of stack
      #50 Top = 1'b0;
      
      #5 Pop = 1'b1;          // Pop values from the stack
      #5000 Pop = 1'b0;
   end
   
   always
   begin
      #25 Clk = ~Clk;
   end
   
   always @ (*)
   begin
      if(Error)
      begin
         if(Full) $display("Error: Trying to push into a full stack @ time = %0d ns", $time);
         else if(Empty) $display("Error: Trying to pop from an empty stack @ time = %0d ns", $time);
      end
   end
endmodule

/* Waveforms were observed & Errors as printed out from the test bench
# Error: Trying to pop from an empty stack @ time = 25 ns
# Error: Trying to push into a full stack @ time = 51325 ns
# Error: Trying to pop from an empty stack @ time = 103025 ns
# Error: Trying to pop from an empty stack @ time = 107675 ns
*/

//--------------------------------------------------------------------------------------------//

/* Test bench for 16 depth stack.
// Test bench for Stack
module HardwareStack_tb;
   parameter WIDTH = 8;                   // Data bits
   parameter ADDRESS_BITS = 4;
   parameter DEPTH = 1 << ADDRESS_BITS;   // Depth of the stack is 2 ^ No. of address bits
   
   reg Push, Pop, Top, Clk, Reset, Enable;
   reg [WIDTH-1:0] DataIn;
   
   wire Full, Empty, Error;
   wire [WIDTH-1:0] DataOut;
   wire [ADDRESS_BITS-1:0] Ptr;
   
   // module instantiation
   HardwareStack STACK (Ptr,DataIn,DataOut,Full,Empty,Error,Push,Pop,Top,Clk,Reset,Enable);

   initial
   begin
      Clk    = 1'b0;
      Reset  = 1'b1;          // Assert Reset to initialize variables
      Enable = 1'b0; 
      Push   = 1'b0;
      Pop    = 1'b0;
      Top    = 1'b0;
      DataIn = 8'd0;
      
      #10 Reset  = 1'b0;      // Reset = 0
      Enable = 1'b1;          // Enable

      #5 Top = 1'b1;          // Check value at top of stack
      #50 Top = 1'b0;
      
      #5 Pop = 1'b1;          // Pop values from the stack
      #50 Pop = 1'b0;

      Push = 1'b1;            // Push values on the stack
      DataIn = 8'd10;
      #50 DataIn = 8'd20;
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
      //#50 DataIn = 8'd96;
      //#50 DataIn = 8'd97;
      //#50 DataIn = 8'd98;
      //#50 DataIn = 8'd99;
      #50 Push = 1'b0;

      #5 Top = 1'b1;          // Check value at top of stack
      #50 Top = 1'b0;

      #5 Pop = 1'b1;          // Pop values from the stack
      #1000 Pop = 1'b0;

      #5 Top = 1'b1;          // Check value at top of stack
      #50 Top = 1'b0;

      #5 Push = 1'b1;         // Push values on the stack 
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
      #50 Push = 1'b0;     

      #5 Top = 1'b1;          // Check value at top of stack
      #50 Top = 1'b0;

      #5 Pop = 1'b1;          // Pop values from the stack
      #300 Pop = 1'b0;

      #5 Top = 1'b1;          // Check value at top of stack
      #50 Top = 1'b0;

      #5 Push = 1'b1;         // Push values on the stack 
      DataIn = 8'd180;
      #50 DataIn = 8'd190;
      #50 DataIn = 8'd200;
      #50 Push = 1'b0;     
            
      #5 Top = 1'b1;          // Check value at top of stack
      #50 Top = 1'b0;
      
      #5 Pop = 1'b1;          // Pop values from the stack
   end
   
   always
   begin
      #25 Clk = ~Clk;
   end
endmodule
*/