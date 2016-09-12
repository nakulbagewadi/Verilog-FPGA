`timescale 1ns/1ns


module sum16(clk, sw, btnU, seg, an, led);
    parameter TEXT_WIDTH = 32;
    
    parameter SEGDIS = 7;           /// 7 display segments
    parameter NUM_AN = 4;           /// Each 7-segment display has 1 anode for control, total 4

	input clk, btnU;
    input [15:0] sw;
    output [0:SEGDIS-1] seg;
    output [NUM_AN-1:0] an;
	output [15:0] led;	
	
	wire[11:0] address;
	wire[17:0] instruction;
	wire [7:0] port_id, in_port, out_port;
	wire write_strobe;
	wire read_strobe;
	//reg [7:0] out_port_reg;
	reg [7:0] out_port_byte0, out_port_byte1, out_port_byte2, out_port_byte3;
	
	embedded_kcpsm6 U(port_id, write_strobe, read_strobe, out_port, in_port, interrupt, interrupt_ack, btnU, clk);
	Display_16_Text DSPLY(clk, rst, {out_port_byte1,out_port_byte0}, seg, an);
	//Scrolling_Display_16_Text #(TEXT_WIDTH) SCRLL_DSPLY(.clk(clk), .rst(btnU), .seg(seg), .an(an), 
	//                          .datain({out_port_byte3,out_port_byte2,out_port_byte1,out_port_byte0}));
	
	/// if port_id[0] = 0, read sw7 - sw0 from the in_port; otherwise read sw15 - sw8 from the in_port
	assign in_port = (port_id[0]) ? sw[15:8] : sw[7:0];
    assign led = sw;

	always @(posedge clk)
	begin
		if (write_strobe)
		begin
            case (port_id[2:0])
                3'b010:  out_port_byte0 = out_port;    
                3'b011:  out_port_byte1 = out_port;    
                3'b100:  out_port_byte2 = out_port;    
                3'b101:  out_port_byte3 = out_port;    
                default: 
                begin
                    out_port_byte0 = 8'b0;
                    out_port_byte1 = 8'b0;
                    out_port_byte2 = 8'b0;
                    out_port_byte3 = 8'b0;
                end
            endcase
        end
	end
endmodule