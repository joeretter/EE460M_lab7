//Anne's Testbench part a #3 
module MIPS_part_a3_tb ();
  reg CLK;
  reg RST;
  reg HALT; 
  wire CS;
  wire WE;
  wire [31:0] Mem_Bus;
  wire [31:0] Address;
  wire [31:0] reg_1; 
  
  

  initial
  begin
    CLK = 0;
	HALT = 1'b0; 
  end

  Complete_MIPS mips_inst(CLK, RST, HALT, Address, Mem_Bus, reg_1);

  always
  begin
    #5 CLK = !CLK; //posedge clk occurs every 10 ns
  end

  always
  begin
    RST <= 1'b1; //reset the processor
	


    //Notice that the memory is initialize in the in the memory module not here

    @(posedge CLK);
    // driving reset low here puts processor in normal operating mode
    RST = 1'b0;
	//1) andi
	repeat(4) begin // wait 4 clk cycles
		@(posedge CLK);
	end
	#2 //wait another 2 ns after register has been written to see its contents
	$display("1) $0 is: %d", mips_inst.CPU.Register.REG[0]);
	
	//2) andi
	repeat(4) begin 
		@(posedge CLK);
	end
	#2
	$display("2) $1 is: %d", mips_inst.CPU.Register.REG[1]);

	//3) addi
	repeat(4) begin 
		@(posedge CLK);
	end
	#2
	$display("3) $0 is: %d", mips_inst.CPU.Register.REG[0]);
	
	$display("TEST COMPLETE");
    $stop;
	
	end 

endmodule 