//varilabe clk generate
//INPUTclk_var 
//OUTPUT clk divided by (clk_var * 2) = pulse  

module var_clk_div(rst, clk, pulse);  
input wire rst, clk; 
output wire pulse; 

reg [31:0] r_reg; 
wire [31:0] r_nxt; 
reg clk_track; 
parameter clk_var = 0; 

assign r_nxt = r_reg+1;   	      
assign pulse = clk_track; 
 
always @(posedge clk)
begin
  if (rst)
     begin
        r_reg <= 0;
	    clk_track <= 1'b1; 
     end
 
  else if (r_nxt == clk_var)
 	   begin
	     r_reg <= 0;
	     clk_track <= ~clk_track;
	   end
 
  else 
      r_reg <= r_nxt;
end


endmodule


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

module Memory(CS, WE, CLK, ADDR, Mem_Bus);
  input CS;
  input WE;
  input CLK;
  input [6:0] ADDR;
  inout [31:0] Mem_Bus;

  reg [31:0] data_out;
  reg [31:0] RAM [0:127];
  integer i,p; 

  initial
  begin
    for(p = 0; p < 128; p = p +1)
	begin 
	RAM[p] = 32'b0; 
	end
    /* Write your Verilog-Text IO code here */
	//write a separate text file with MIPS machine code in hexidecimal
	$readmemb("C:/Users/Anne/Documents/GitHub/EE460M_lab7/B_machine_code_test.txt", RAM);
  for(i = 0 ; i < 41; i = i + 1)
	begin 
	$display ("mem %d is %h", i, RAM[i]); 
	end
  end
 
  assign Mem_Bus = ((CS == 1'b0) || (WE == 1'b1)) ? 32'bZ : data_out;

  always @(negedge CLK)
  begin

    if((CS == 1'b1) && (WE == 1'b1))
      RAM[ADDR] <= Mem_Bus[31:0];

    data_out <= RAM[ADDR];
  end
endmodule

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

module REG(CLK, RegW, DR, SR1, SR2, Reg_In, switches, ReadReg1, ReadReg2, reg_2, reg_3);
  input CLK;
  input RegW;
  input [4:0] DR;
  input [4:0] SR1;
  input [4:0] SR2;
  input [31:0] Reg_In;
  input [2:0] switches; 
  output reg [31:0] ReadReg1;
  output reg [31:0] ReadReg2;
  output [31:0] reg_2, reg_3; 
  
  reg [31:0] REG [0:31];
  integer i;

  initial begin
    ReadReg1 = 0;
    ReadReg2 = 0;
	
	for(i = 0; i < 32; i = i +1)
	begin 
	REG[i] = 0; 
	end 
	
  end
   
   assign reg_2 = REG[2];
   assign reg_3 = REG[3];   
   
  always @(posedge CLK)
  begin
    REG[1] <= {29'b0, switches}; 
	
    if(RegW == 1'b1)
      REG[DR] <= Reg_In[31:0];

    ReadReg1 <= REG[SR1];
    ReadReg2 <= REG[SR2];
  end
endmodule


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

`define opcode instr[31:26]
`define sr1 instr[25:21]
`define sr2 instr[20:16]
`define f_code instr[5:0]
`define numshift instr[10:6]

module MIPS (CLK, RST, switches, CS, WE, ADDR, Mem_Bus, reg_2, reg_3);
  input CLK, RST; 
  input [2:0] switches; 
  output reg CS, WE;
  output [6:0] ADDR;
  inout [31:0] Mem_Bus;
  output wire [31:0] reg_2, reg_3; 
  
  

  //special instructions (opcode == 000000), values of F code (bits 5-0):
  parameter add = 6'b100000;//
  parameter sub = 6'b100010;//
  parameter xor1 = 6'b100110;//
  parameter and1 = 6'b100100;//
  parameter or1 = 6'b100101;//
  parameter slt = 6'b101010; //set less than
  parameter srl = 6'b000010; //shift right logical
  parameter sll = 6'b000000; //shift left logical
  parameter jr = 6'b001000; //jump register
  parameter rbit = 6'b101111;
  parameter rev = 6'b110000;
  parameter mult = 6'b011000;
  //f_codes special instruction Anne 
  parameter add8 = 6'b101101; 
  parameter sadd = 6'b110001; 
  parameter ssub = 6'b110010; 
  parameter mfhi = 6'd010000; 
  parameter mflo = 6'b010010; 

  //non-special instructions, values of opcodes:
  parameter addi = 6'b001000;//
  parameter andi = 6'b001100;//
  parameter ori = 6'b001101;//
  parameter lw = 6'b100011; //load word
  parameter sw = 6'b101011; //store word
  parameter beq = 6'b000100; //branch equal
  parameter bne = 6'b000101; //branch not equal
  parameter j = 6'b000010; // to address
  parameter jal = 6'b000011;
  parameter lui = 6'b001111;
  

  
  //instruction format
  parameter R = 2'd0;
  parameter I = 2'd1;
  parameter J = 2'd2;

  //internal signals
  reg [5:0] op, opsave;
  wire [1:0] format;
  reg [31:0] instr, alu_result;
  reg [6:0] pc, npc, npc_str;
  wire [31:0] imm_ext, alu_in_A, alu_in_B, readreg1, readreg2;
  reg [31:0] reg_in; 
  reg [31:0] alu_result_save;
  reg /*alu_or_mem, alu_or_mem_save, */regw, writing, reg_or_imm, reg_or_imm_save;
  reg [2:0] reg_in_sel, reg_in_sel_save; 
  reg fetchDorI;
  wire [4:0] dr;
  wire [1:0] dr_sel;
  reg [1:0] dr_sel_reg; 
  reg [2:0] state, nstate;
  reg [31:0] HI, LO;
  reg [63:0] product;
  reg ldHILO;
  
  //new var Anne
  reg [8:0] rbit_i; 
  reg [63:0] sadd_temp, ssub_temp;   

  //combinational
  assign imm_ext = (instr[15] == 1)? {16'hFFFF, instr[15:0]} : {16'h0000, instr[15:0]};//Sign extend immediate field
  //assign dr = (format == R)? instr[15:11] : instr[20:16]; //Destination Register MUX (MUX1)
  assign dr = dr_sel[1] ? (dr_sel[0] ? instr[25:21] : 5'd31) : (dr_sel[0] ? instr[15:11] : instr[20:16]);
  assign dr_sel = dr_sel_reg; 
  assign alu_in_A = readreg1;
  assign alu_in_B = (reg_or_imm_save)? imm_ext : readreg2; //ALU MUX (MUX2)
  //assign reg_in = (alu_or_mem_save)? Mem_Bus : alu_result_save; //Data MUX SEE NEXT ALWAYS BLOCK
  assign format = (`opcode == 6'd0)? R : (((`opcode == j) || (`opcode == jal))? J : I);
  assign Mem_Bus = (writing)? readreg2 : 32'bZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ;

  //drive memory bus only during writes
  assign ADDR = (fetchDorI)? pc : alu_result_save[6:0]; //ADDR Mux
  REG Register(CLK, regw, dr, `sr1, `sr2, reg_in, switches, readreg1, readreg2, reg_2, reg_3);

  initial begin
    op = and1; opsave = and1;
    state = 3'b0; nstate = 3'b0;
    reg_in_sel = 3'b0;
    regw = 0;
    fetchDorI = 0;
    writing = 0;
    reg_or_imm = 0; reg_or_imm_save = 0;
    reg_in_sel_save = 3'b0;
  end
  
  always @(*) //MUX 3
  begin
	case(reg_in_sel_save)
		3'd0 : reg_in = alu_result_save;
		3'd1 : reg_in = Mem_Bus;
		3'd2 : reg_in = npc_str; //may need to double check this one
		3'd3 : reg_in = HI;
		3'd4 : reg_in = LO;
	default : reg_in = reg_in;
	endcase
  end
  

  always @(*)
  begin
    fetchDorI = 0; CS = 0; WE = 0; regw = 0; writing = 0; alu_result = 32'd0;
    npc = pc; op = jr; reg_or_imm = 0; reg_in_sel = 3'b0; nstate = 3'd0;
	ldHILO = 0;
    case (state)
      0: begin //fetch
        npc_str = pc + 7'd1; 
		npc = pc + 7'd1; CS = 1; nstate = 3'd1;
        fetchDorI = 1;
		 
      end
      1: begin //decode
        nstate = 3'd2; reg_or_imm = 0; reg_in_sel = 3'b0; dr_sel_reg = 2'b00;
        if (format == J) begin //jump, and finish
          npc = instr[6:0];
          
		  if (`opcode == jal) begin //load $31 for jal
			dr_sel_reg = 2'b10; 
			reg_in_sel = 3'd2; 
			nstate = 3'd2;
		  end
		  else nstate = 3'd0;
        end
        else if (format == R) begin//register instructions
          op = `f_code;
		  //dr_sel_reg 
		  if((`f_code == rbit) || (`f_code == rev)) dr_sel_reg = 2'b11; 
		  else dr_sel_reg = 2'b01;
		  //reg_in_sel 
		  if(`f_code == mfhi) reg_in_sel = 3'b11; 
		  else if(`f_code == mflo) reg_in_sel = 3'd4; 
		 
		  
		end
        else if (format == I) begin //immediate instructions
          reg_or_imm = 1;
          if(`opcode == lw) begin
            op = add;
            reg_in_sel = 3'b001;
          end
          else if ((`opcode == lw)||(`opcode == sw)||(`opcode == addi)) op = add;
          else if ((`opcode == beq)||(`opcode == bne)) begin
            op = sub;
            reg_or_imm = 0;
          end
          else if (`opcode == andi) op = and1;
          else if (`opcode == ori) op = or1;
		  else if (`opcode == lui) op = lui; //keep adding alu instructions here
		  
		  
        end
      end
      2: begin //execute
        nstate = 3'd3;
        if (opsave == and1) alu_result = alu_in_A & alu_in_B;
        else if (opsave == or1) alu_result = alu_in_A | alu_in_B;
        else if (opsave == add) alu_result = alu_in_A + alu_in_B;
        else if (opsave == sub) alu_result = alu_in_A - alu_in_B;
        else if (opsave == srl) alu_result = alu_in_B >> `numshift;
        else if (opsave == sll) alu_result = alu_in_B << `numshift;
        else if (opsave == slt) alu_result = (alu_in_A < alu_in_B)? 32'd1 : 32'd0;
        else if (opsave == xor1) alu_result = alu_in_A ^ alu_in_B;
		//added for new instructions Anne //
		else if(opsave == lui) alu_result = (alu_in_B << 5'd16) ; // shf immediate left 16 
		else if(opsave == add8) begin 
		alu_result[31:24] = alu_in_A[31:24] + alu_in_B[31:24]; 
		alu_result[23:16] = alu_in_A[23:16] + alu_in_B[23:16]; 
		alu_result[15:8] = alu_in_A[15:8] + alu_in_B[15:8]; 
		alu_result[7:0] = alu_in_A[7:0] + alu_in_B[7:0];
		end 
		else if(opsave == rbit) 
		begin 
		for(rbit_i= 0; rbit_i < 32; rbit_i = rbit_i +1)
			begin 
			alu_result[rbit_i] = alu_in_B[ 31 - rbit_i]; 
			end 
		end 
		else if(opsave == rev)
		begin 
		alu_result[31:24] = alu_in_B[7:0]; 
		alu_result[23:16] = alu_in_B[15:8];
		alu_result[15:8] = alu_in_B[23:16];
		alu_result[7:0] = alu_in_B[31:24];
		end 
		else if(opsave == sadd)
		begin 
		sadd_temp = alu_in_A + alu_in_B; 
		if( sadd_temp > 64'h0FFFFFFFF) alu_result = 32'hFFFFFFFF; 
		else  alu_result = alu_in_A + alu_in_B;
		end 
		if(opsave == ssub)
		begin 
		ssub_temp = alu_in_A - alu_in_B; 
		if(ssub_temp < 0 ) alu_result = 0; 
		else alu_result = alu_in_A - alu_in_B;
		end 
		///////////////////////////////
		
        if (((alu_in_A == alu_in_B)&&(`opcode == beq)) || ((alu_in_A != alu_in_B)&&(`opcode == bne))) begin
          npc = pc + imm_ext[6:0];
          nstate = 3'd0;
        end
        else if ((`opcode == bne)||(`opcode == beq)) nstate = 3'd0;
        else if (opsave == jr) begin
          npc = alu_in_A[6:0];
          nstate = 3'd0;
        end
		else if (`opcode == jal) begin
			regw = 1;
			nstate = 3'd0;
		end
		else if (`f_code == mult) begin
			product = readreg1 * readreg2;
		end
		else if((`f_code == mfhi) || (`f_code == mflo)) begin regw = 1; nstate = 0; end //CYCLES?
		
      end
      3: begin //prepare to write to mem
        nstate = 3'd0;
        if ((format == R)||(`opcode == addi)||(`opcode == andi)||(`opcode == ori)||(`opcode == lui)) regw = 1;
        else if (`opcode == sw) begin
          CS = 1;
          WE = 1;
          writing = 1;
        end
        else if (`opcode == lw) begin
          CS = 1;
          nstate = 3'd4;
        end
		if(`f_code == mult) begin
		  regw = 0;
		  ldHILO = 1;
		end
      end
      4: begin
        nstate = 3'd0;
        CS = 1;
        if (`opcode == lw) regw = 1;
      end
	 
	  
    endcase
  end //always

  always @(posedge CLK) begin

    if (RST) begin
      state <= 3'd0;
      pc <= 7'd0;
    end
    else begin
      state <= nstate;
      pc <= npc;
    end

    if (state == 3'd0) instr <= Mem_Bus;
    else if (state == 3'd1) begin
      opsave <= op;
      reg_or_imm_save <= reg_or_imm;
      //alu_or_mem_save <= alu_or_mem;
	  reg_in_sel_save <= reg_in_sel;
    end
    else if (state == 3'd2) alu_result_save <= alu_result;
	
	if(ldHILO) begin
		HI <= product[63:32];
		LO <= product[31:0];
	end

  end //always
  

endmodule
