`timescale 1ns / 1ps
module E_Reg(
    input  [ 0:0] clk        ,
    input  [ 0:0] reset      ,
	 input  [ 0:0] freeze     ,
	 input  [31:0] inInstr    ,
	 input  [31:0] inPc       ,
    input  [31:0] inRegRead1 ,
    input  [31:0] inRegRead2 ,
	 input  [31:0] inImm      ,
	 input  [ 0:0] inRegWE    ,
	 input  [ 0:0] inDelay    ,
	 input  [ 4:0] inExcCode  ,
	 output [31:0] outInstr   ,
	 output [31:0] outPc      ,
    output [31:0] outRegRead1,
    output [31:0] outRegRead2,
	 output [31:0] outImm     ,
	 output [ 0:0] outRegWE   ,
	 output [ 0:0] outDelay   ,
	 output [ 4:0] outExcCode
    );
	 
	 reg [31:0] instr   ;
    reg [31:0] pc      ;
	 reg [31:0] regRead1;
	 reg [31:0] regRead2;
	 reg [31:0] imm     ;
	 reg [ 0:0] regWE   ;
	 reg [ 4:0] excCode ;
	 reg [ 0:0] delay   ;
	 
	 initial
	 begin
		instr    <= 0           ;
		pc       <= 32'h00003000;
		regRead1 <= 0           ;
		regRead2 <= 0           ;
		imm      <= 0           ;
		regWE    <= 0           ;
		excCode  <= 5'd31       ;
		delay    <= 0           ;
	 end
	 
	 always@ (posedge clk)
	 begin
		if(reset) 
		begin
			instr    <= 0           ;
			pc       <= 32'h00003000;
			regRead1 <= 0           ;
			regRead2 <= 0           ;
			imm      <= 0           ;
			regWE    <= 0           ;
			excCode  <= 5'd31       ;
			delay    <= 0           ;
		end
		else if(freeze)
		begin
			instr    <= 0      ;
			pc       <= inPc   ;
			regRead1 <= 0      ;
			regRead2 <= 0      ;
			imm      <= 0      ;
			regWE    <= 0      ;
			excCode  <= 5'd31  ;
			delay    <= inDelay;
		end
		else		
		begin
			pc       <= inPc      ;
			instr    <= inInstr   ;
			regRead1 <= inRegRead1;
			regRead2 <= inRegRead2;
			imm      <= inImm     ;
			regWE    <= inRegWE   ;
			excCode  <= inExcCode ;
			delay    <= inDelay   ;
		end
	 end
	 
	 assign outInstr    = instr   ;
	 assign outPc       = pc      ;
	 assign outRegRead1 = regRead1;
	 assign outRegRead2 = regRead2;
	 assign outImm      = imm     ;
	 assign outRegWE    = regWE   ;
	 assign outDelay    = delay   ;
	 assign outExcCode  = excCode ;

endmodule

