//top file for lab 7 part B
module Complete_MIPS(CLK, RST, switches, btnl, btnr, a, b, c, d, e, f, g, dp, an);
  // Will need to be modified to add functionality
  input CLK,RST;
  input [2:0] switches;  
  input btnl, btnr; 
  //output [31:0] A_Out;
  //output [31:0] D_Out;
  output a, b, c, d, e, f, g, dp;
  output [3:0] an; 
  
  wire [31:0] reg_2, reg_3; 
  wire CS, WE, pulse1;
  wire [6:0] ADDR;
  wire [31:0] Mem_Bus;
  wire [4:0] bcd0,bcd1,bcd2, bcd3; 
  //wire [7:0] reg_2_o, reg_3_o; 
  
  //assign reg_2_o[7:0] = reg_2[7:0]; 
  //assign reg_3_o[7:0] = reg_3[7:0]; 

  //assign A_Out = ADDR;
  //assign D_Out = Mem_Bus;
  
   ///////// SIM VS. SYNTH ON BOARD ///////////
  //assign pulse1 = CLK; // system clk for simulation 
  
  var_clk_div #(64'd25000000) var_clk_div_1(RST, CLK, pulse1); //2hz clk for synthesis 
  
  ///////// SIM VS. SYNTH ON BOARD ///////////
  
  MIPS CPU(pulse1, RST, switches, CS, WE, ADDR, Mem_Bus, reg_2, reg_3);
  Memory MEM(CS, WE, pulse1, ADDR, Mem_Bus);
  determine_output_based_on_switch_input buttons2out_inst(CLK, switches[2], switches[1], switches[0], btnl, btnr, reg_2, reg_3, bcd3, bcd2, bcd1, bcd0);
  seven_seg_display seven_seg_inst( CLK, bcd0, bcd1, bcd2, bcd3, a, b, c, d, e, f, g, dp, an );
  

endmodule