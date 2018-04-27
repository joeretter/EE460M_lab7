module determine_output_based_on_switch_input(sys_clk, sw2, sw1, sw0, btnl, btnr, reg_2, reg_3, bcd3, bcd2, bcd1, bcd0);
input sys_clk, sw2, sw1, sw0, btnl, btnr;
input [31:0] reg_2, reg_3;
output [4:0] bcd3, bcd2, bcd1, bcd0;

reg [15:0] reg_bits_to_display;
wire [4:0] switches;
wire btnl_debounced, btnr_debounced;

debounce btnl_debouncer(sys_clk, btnl, btnl_debounced);
debounce btnr_debouncer(sys_clk, btnr, btnr_debounced);
convert_16bits_to_4hex converter(reg_bits_to_display, bcd3, bcd2, bcd1, bcd0);

assign switches = {sw2, sw1, sw0, btnl_debounced, btnr_debounced};

always @(*)
begin
	case(switches)
		5'b00000 : reg_bits_to_display = reg_2[15:0];
		5'b00001 : reg_bits_to_display = reg_2[31:16];
		5'b00010 : reg_bits_to_display = reg_3[15:0];
		5'b00011 : reg_bits_to_display = reg_3[31:16];
		
		5'b00100 : reg_bits_to_display = reg_2[15:0];
		5'b00101 : reg_bits_to_display = reg_2[31:16];
		
		5'b01000 : reg_bits_to_display = reg_2[15:0];
		5'b01001 : reg_bits_to_display = reg_2[31:16];
		
		5'b01100 : reg_bits_to_display = reg_2[15:0];
		5'b01101 : reg_bits_to_display = reg_2[31:16];
		
		5'b10000 : reg_bits_to_display = reg_2[15:0];
		5'b10001 : reg_bits_to_display = reg_2[31:16];
		
		5'b10100 : reg_bits_to_display = reg_2[15:0];
		5'b10101 : reg_bits_to_display = reg_2[31:16];
		
		5'b11000 : reg_bits_to_display = reg_2[15:0];
		5'b11001 : reg_bits_to_display = reg_2[31:16];
		
		default : reg_bits_to_display = reg_2[15:0]; //arbitrary
	endcase
end

endmodule
	
	


	
/*************16 bit binary to 4 hex characters converter********/
module convert_16bits_to_4hex(binary_in, bcd3, bcd2, bcd1, bcd0);
input [15:0] binary_in;
output [4:0] bcd3, bcd2, bcd1, bcd0;

assign bcd0 = {1'b0, binary_in[3:0]};
assign bcd1 = {1'b0, binary_in[7:4]};
assign bcd2 = {1'b0, binary_in[11:8]};
assign bcd3 = {1'b0, binary_in[15:12]};

endmodule


/********Debounce Circuit***********/
module AND(a, b, out);
input a, b;
output out;

assign out = a & b;

endmodule

module DFF(clk, d, q, q_bar);
input clk, d;
output q, q_bar;

reg q, q_bar;

always @(posedge clk)
begin
  q <= d;
  q_bar <= ~d;
end

endmodule


module debounce(clk, D, SYNCPRESS);
input clk, D;
output SYNCPRESS;

DFF flop1(clk, D, flop1_Q, unused1);
DFF flop2(clk, flop1_Q, SYNCPRESS, unused2);

endmodule