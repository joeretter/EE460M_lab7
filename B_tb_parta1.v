//Joe's testbench part a #1
// You can use this skeleton testbench code, the textbook testbench code, or your own
module MIPS_Testbench_B ();
  reg CLK;
  reg RST;
  wire CS;
  wire WE;
  reg [2:0] switches; 
  wire [31:0] Mem_Bus;
  wire [6:0] Address;
  wire [31:0] reg_2, reg_3; 
  
  integer i, a, instr; 
  

  initial
  begin
    CLK = 0;
	switches = 3'b0; 
  end

  
  MIPS CPU(CLK, RST, switches, CS, WE, Address, Mem_Bus, reg_2, reg_3);
  Memory MEM(CS, WE, CLK, Address, Mem_Bus);

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
	
	/*
	
	//1) andi
	repeat(4) begin // wait 4 clk cycles
		@(posedge CLK);
	end
	#2 //wait another 2 ns after register has been written to see its contents
	$display("1) $0 is: %d", CPU.Register.REG[0]);

	//2) andi
	repeat(4) begin 
		@(posedge CLK);
	end
	#2
	$display("2) $4 is: %d", CPU.Register.REG[4]);

	//3) addi
	repeat(4) begin 
		@(posedge CLK);
	end
	#2
	$display("3) $4 is: %d", CPU.Register.REG[4]);

	//4) addi
	repeat(4) begin 
		@(posedge CLK);
	end
	#2
	$display("4) $5 is: %d", CPU.Register.REG[5]);

	//5) add
	repeat(4) begin 
		@(posedge CLK);
	end
	#2
	$display("5) $2 is: %d", CPU.Register.REG[2]);

	//6) add
	repeat(4) begin 
		@(posedge CLK);
	end
	#2
	$display("6) $3 is: %d", CPU.Register.REG[3]);
	*/

for (instr = 0; instr < 41; instr = instr + 1)
begin 
	@(posedge CLK); 
	$display("6) $31 is: %d", CPU.Register.REG[31]);
	for(a = 0; a < 9; a = a + 1 )
	begin 
	#2
	$display("6) $%d is: %d", a, CPU.Register.REG[a]);
	end 
	
end 	
	
/*
	//7) xor1
	repeat(4) begin 
		@(posedge CLK);
	end
	#2
	$display("7) $4 is: %d", CPU.Register.REG[4]);

	//8) and1
	repeat(4) begin 
		@(posedge CLK);
	end
	#2
	$display("8) $5 is: %d", CPU.Register.REG[5]);

	//9) or1
	repeat(4) begin 
		@(posedge CLK);
	end
	#2
	$display("9) $6 is: %d", CPU.Register.REG[6]);

	//10) ori
	repeat(4) begin 
		@(posedge CLK);
	end
	#2
	$display("10) $7 is: %d", CPU.Register.REG[7]);

	//11) beq - note that branches are only 3 cylces
	repeat(3) begin 
		@(posedge CLK);
	end
	#2
	$display("11) pc is: %d", CPU.pc);

	//12) srl
	repeat(4) begin 
		@(posedge CLK);
	end
	#2
	$display("12) $7 is: %d", CPU.Register.REG[7]);

	//13) beq
	repeat(3) begin 
		@(posedge CLK);
	end
	#2
	$display("13) pc is: %d", CPU.pc);

	//15) bne
	repeat(3) begin 
		@(posedge CLK);
	end
	#2
	$display("15) pc is: %d", CPU.pc);

	//16) sll
	repeat(4) begin 
		@(posedge CLK);
	end
	#2
	$display("16) $7 is: %d", CPU.Register.REG[7]);

	//17) bne
	repeat(3) begin 
		@(posedge CLK);
	end
	#2
	$display("17) pc is: %d", CPU.pc);

	//19) lw
	repeat(5) begin 
		@(posedge CLK);
	end
	#2
	$display("19) $8 is: %d", CPU.Register.REG[8]);

	//20) jr
	repeat(3) begin 
		@(posedge CLK);
	end
	#2
	$display("20) pc is: %d", CPU.pc);

	//22) sw
	repeat(4) begin 
		@(posedge CLK);
	end
	#2
	$display("22) Mem[23] is: %d", MEM.RAM[23]);

	//23) j
	repeat(2) begin 
		@(posedge CLK);
	end
	#2
	$display("23) pc is: %d", CPU.pc);

	//25) slt
	repeat(4) begin 
		@(posedge CLK);
	end
	#2
	$display("25) $0 is: %d", CPU.Register.REG[0]);

*/


    /* add your testing code here */
    // you can add in a 'Halt' signal here as well to test Halt operation
    // you will be verifying your program operation using the
    // waveform viewer and/or self-checking operations

    $display("TEST COMPLETE");
    $stop;
  end

endmodule