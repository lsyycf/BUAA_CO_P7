`timescale 1ns / 1ps
module D_Reg(
    input  [ 0:0] clk       ,
    input  [ 0:0] reset     ,
	 input  [ 0:0] freeze    ,
    input  [31:0] inInstr   ,
    input  [31:0] inPc      ,
	 input  [ 0:0] inDelay   ,
	 input  [ 4:0] inExcCode ,
    output [31:0] outInstr  ,
    output [31:0] outPc     ,
	 output [ 0:0] outDelay  ,
	 output [ 4:0] outExcCode
    );
	 
	 reg [31:0] instr  ;
	 reg [31:0] pc     ;
	 reg [ 4:0] excCode;
	 reg [ 0:0] delay  ;
	 
	 initial
	 begin
		instr   <= 0           ;
		pc      <= 32'h00003000;
		excCode <= 5'd31       ;
		delay   <= 0           ;
	 end
	 
	 always @(posedge clk)
	 begin
		if (reset)
		begin
			instr   <= 0           ;
			pc      <= 32'h00003000;
			excCode <= 5'd31       ;
			delay   <= 0           ;
		end 
		else if (!freeze) 
		begin
			instr   <= inInstr  ;
			pc      <= inPc     ;
			excCode <= inExcCode;
			delay   <= inDelay  ;
		end
	 end
	 
	 assign outInstr   = instr  ;
	 assign outPc      = pc     ;
	 assign outDelay   = delay  ;
	 assign outExcCode = excCode;

endmodule

