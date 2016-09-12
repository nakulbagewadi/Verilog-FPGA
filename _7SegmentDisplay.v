`timescale 1ns/1ns

/************** do not change modules below this line **************/
// Refresh display at intervals of 'N' seconds
module Display_16_Text_N_second(clk, rst, seg, an, text, done);
    parameter NUM_SEC = 1;
    parameter C_WIDTH = 35;
    parameter TEXT_WIDTH = 16;
    parameter SEGDIS = 7;           // 7 display segments
    parameter NUM_AN = 4;           // Each 7-segment display has 1 anode for control, total 4
    parameter CRYSTAL = 100;
    parameter [C_WIDTH-1:0] STOPAT = (CRYSTAL * 1_000_000 * NUM_SEC)- 1;
        
    input clk, rst;
    input [TEXT_WIDTH-1:0] text;
    output [0:SEGDIS-1] seg;
    output [NUM_AN-1:0] an;
    output done;
    wire [C_WIDTH-1:0] big_count;

    // Instantiate mod-counter to count 'N' sec intervals
    Mod_Counter #(C_WIDTH, STOPAT) MC_1 (.clk(clk), .rst(rst), .q(big_count), .done(done));
    // Instantiate module to display 16-bit text on 7-segment display
    Display_16_Text #(C_WIDTH) DST_1 (.clk(clk), .rst(rst), .text(text), .seg(seg), .an(an));

endmodule

module Display_16_Text(clk, rst, text, seg, an);
    parameter C_WIDTH = 35;
    parameter TEXT_WIDTH = 16;
    
    parameter SEGDIS = 7;               // 7 display segments
    parameter NUM_AN = 4;               // Each 7-segment display has 1 anode for control, total 4
    parameter NUM = 4;                  // Numbers 0...F, 4-bits
    parameter SEL_WIDTH = 2;
    parameter DISPLAY_FREQ_BIT = 20;	// Counter[20] & Counter[19] toggling will be used as display change frequency
    
    input clk, rst;
    input [TEXT_WIDTH-1:0] text;
    output [0:SEGDIS-1] seg;
    output [NUM_AN-1:0] an;

    wire [SEL_WIDTH-1:0] select_lines;
    wire [NUM-1:0] value_to_display;
    wire [C_WIDTH-1:0] big_count;
  
    // Select lines of decoder are counter bits [20:19]
  	assign select_lines = {big_count[DISPLAY_FREQ_BIT],big_count[DISPLAY_FREQ_BIT-1]};

    Counter #(C_WIDTH) C_1 (.clk(clk), .rst(rst), .q(big_count));
    // Instantiate decoder to time multiplex the 4 anodes to display a character at one time
    Decoder D_1 (.text_to_display(text), .sel(select_lines), .anode(an), .value(value_to_display));
    // Instantiate 7-segment display to display numbers 
    _7SegmentDisplay SSD_1 (.Value_to_Display(value_to_display), .Display(seg));
    
endmodule

module Hex_2_Bcd(hex, bcd, quo);
    parameter TEXT_WIDTH = 16;
    
    input [TEXT_WIDTH-1:0] hex;
    output [TEXT_WIDTH-1:0] quo;
    output [3:0] bcd;
    
    assign bcd = hex%10;
    assign quo = hex/10;   

endmodule

module Decoder(text_to_display, sel, anode, value);
	parameter TEXT_WIDTH = 16;
	
	input [TEXT_WIDTH-1:0] text_to_display;
	input [1:0] sel;
	output reg [3:0] anode;
	output reg [3:0] value;
    
    wire [3:0] text_to_display_dec_3_0;
    wire [3:0] text_to_display_dec_7_4;
    wire [3:0] text_to_display_dec_11_8;
    wire [3:0] text_to_display_dec_15_12;
    wire [TEXT_WIDTH-1:0] text_to_display_q1;
    wire [TEXT_WIDTH-1:0] text_to_display_q2;
    wire [TEXT_WIDTH-1:0] text_to_display_q3;
    wire [TEXT_WIDTH-1:0] text_to_display_q4;
    
    Hex_2_Bcd H2B_1 (.hex(text_to_display),    .bcd(text_to_display_dec_3_0),   .quo(text_to_display_q1));
    Hex_2_Bcd H2B_2 (.hex(text_to_display_q1), .bcd(text_to_display_dec_7_4),   .quo(text_to_display_q2));
    Hex_2_Bcd H2B_3 (.hex(text_to_display_q2), .bcd(text_to_display_dec_11_8),  .quo(text_to_display_q3));
    Hex_2_Bcd H2B_4 (.hex(text_to_display_q3), .bcd(text_to_display_dec_15_12), .quo(text_to_display_q4));
    
	always @ (*)
	begin 
		case(sel)
		0:  begin
				anode <= 4'b1110;					          // - - - 0
				//value <= text_to_display_dec[3:0];		  // display LSB
				value <= text_to_display_dec_3_0;		     // display LSB
			end
		1:	begin
				anode <= 4'b1101;					      // - - 1 -
				//value <= text_to_display_dec[7:4];
				value <= text_to_display_dec_7_4;
			end
		2:  begin
				anode <= 4'b1011;					      // - 2 - -
				//value <= text_to_display_dec[11:8];
				value <= text_to_display_dec_11_8;
			end
		3:	begin
				anode <= 4'b0111;					    // 3 - - -
				//value <= text_to_display_dec[15:12];	// display MSB
				value <= text_to_display_dec_15_12;     // display MSB
			end
		default: begin
					anode <= 4'b1111;				      // - - - -
					value <= 4'b0;					      // nothing will be displayed
				 end
		endcase
	end
endmodule

module _7SegmentDisplay(Value_to_Display, Display);
    input [3:0] Value_to_Display;
    output [6:0] Display;
    reg [6:0] Display;
    
    always @ (*)
    begin
        case(Value_to_Display)
        0:  Display = 7'b0000001;
        1:  Display = 7'b1001111;
        2:  Display = 7'b0010010;
        3:  Display = 7'b0000110;
        4:  Display = 7'b1001100;
        5:  Display = 7'b0100100;
        6:  Display = 7'b0100000;
        7:  Display = 7'b0001111;
        8:  Display = 7'b0000000;
        9:  Display = 7'b0000100;
        10: Display = 7'b0001000;
        11: Display = 7'b1100000;
        12: Display = 7'b0110001;
        13: Display = 7'b1000010;
        14: Display = 7'b0110000;
        15: Display = 7'b0111000; 
        default: Display = 7'b011011;
        endcase
    end
endmodule

/*
// heartbeat pattern
module _7SegmentDisplay_Heartbeat(Switch, Display, An);
    input [2:0] Switch;
    output [6:0] Display;
    output [6:0] An;
    reg [6:0] Display;
    reg [6:0] An;
        
    always @ (*)
    begin
        case(Switch)
        0:  begin
                An = 4'b0111;               // 3 - - - 
                Display = 7'b0011100;       // abcdefg
            end
        1:  begin
                An = 4'b1011;               // - 2 - -
                Display = 7'b0011100;       // abcdefg
            end
        2:  begin
                An = 4'b1101;               // - - 1 -
                Display = 7'b0011100;       // abcdefg
            end
        3:  begin
                An = 4'b1110;               // - - - 0
                Display = 7'b0011100;       // abcdefg
            end
        4:  begin
                An = 4'b1110;               // - - - 0 
                Display = 7'b1100010;       // abcdefg
            end    
        5:  begin
                An = 4'b1101;               // - - 1 -
                Display = 7'b1100010;       // abcdefg
            end
        6:  begin
                An = 4'b1011;               // - 2 - -
                Display = 7'b1100010;       // abcdefg
            end
        7:  begin
                An = 4'b0111;               // 3 - - -
                Display = 7'b1100010;       // abcdefg
            end
        default: begin 
                    An = 4'b0000;           // 3 2 1 0 
                    Display = 7'b1001001;   // abcdefg
                 end
        endcase
    end
endmodule

// test display
module Test_Display(clk, btnU, seg, an);
    parameter SEGDIS = 7;       // 7 display segments
    parameter NUM_AN = 4;       // Each 7-segment display has 1 anode for control, total 4
    parameter TEXT_WIDTH = 16;
    parameter TEXT = 16'hABCD;
    
    input clk, btnU;
    output [0:SEGDIS-1] seg;
    output [NUM_AN-1:0] an;
    wire [TEXT_WIDTH-1:0] text;
    
    assign text = TEXT;
    
    // instantiate Display_16_Text module
	Display_16_Text DST1 (.clk(clk), .rst(btnU), .text(text), .seg(seg), .an(an));
	
endmodule

module FPGA_7SegmentDisplay(sw, seg, an);
    input [3:0] sw;
    output [0:6] seg;
    output [3:0] an;
    
    assign an = 4'b0000;    // 0 = ON, 1 = OFF
    _7SegmentDisplay SSD(.Switch(sw), .Display(seg));
    
endmodule  

// Displays the contents of ROM module
module ROM_Display(clk, btnU, seg, an);
    parameter C_WIDTH = 35;
    parameter TEXT_WIDTH = 16;
    parameter SEGDIS = 7;       // 7 display segments
    parameter NUM_AN = 4;       // Each 7-segment display has 1 anode for control, total 4
        
    input clk, btnU;
    output [0:SEGDIS-1] seg;
    output [NUM_AN-1:0] an;
    
    wire [TEXT_WIDTH-1:0] text;
    wire [NUM_AN-2:0] q_counter;
    wire done;
    
    // instantiate ROM
    ROM R1 (.in(q_counter), .out(text));
    // instantiate counter
    Counter_with_EN #(NUM_AN-1) CEN1 (.clk(clk), .rst(btnU), .q(q_counter), .en(done));
    // instantiate Display_16_Text module
	Display_16_Text_N_second #(C_WIDTH) DSTNS1 (.clk(clk), .rst(btnU), .text(text), .seg(seg), .an(an), .done(done));
	
endmodule


module Display_NoOfONSwitches(sw, clk, btnU, seg, an);
    parameter C_WIDTH = 35;
    parameter TEXT_WIDTH = 16;
    parameter SEGDIS = 7;       // 7 display segments
    parameter NUM_AN = 4;       // Each 7-segment display has 1 anode for control, total 4
        
    input clk, btnU;
    input [15:0] sw;
    output [0:SEGDIS-1] seg;
    output [NUM_AN-1:0] an;
    
    wire [TEXT_WIDTH-1:0] text;
    wire [NUM_AN-2:0] q_counter;
    wire done;
    
    // instantiate module to find out how many switches are ON
    NoOfONSwitches NOS1 (.clk(clk), .rst(btnU), .Switch(sw), .No(text));
    // instantiate counter
    Counter_with_EN #(NUM_AN-1) CEN1 (.clk(clk), .rst(btnU), .q(q_counter), .en(done));
    // instantiate Display_16_Text module
    Display_16_Text_N_second #(C_WIDTH) DSTNS1 (.clk(clk), .rst(btnU), .text(text), .seg(seg), .an(an), .done(done));
endmodule

// Finds number of switches that are ON
module NoOfONSwitches(clk, rst, Switch, No);
    parameter TEXT_WIDTH = 16;
    
    input clk, rst;
    input [15:0] Switch;
    output [TEXT_WIDTH-1:0] No;
    
    assign No = Switch[0]+Switch[1]+Switch[2]+Switch[3]+Switch[4]+Switch[5]+Switch[6]+Switch[7]+
                Switch[8]+Switch[9]+Switch[10]+Switch[11]+Switch[12]+Switch[13]+Switch[14]+Switch[15];
endmodule  
*/
