`timescale 1ns / 1ps
module Bridge (
    input  [31:0] addr   ,
    input  [ 3:0] byteen ,
    input  [31:0] DMData ,
    input  [31:0] TC0Data,
    input  [31:0] TC1Data,
    output [ 0:0] TC0WE  , 
    output [ 0:0] TC1WE  , 
    output [31:0] read 
);
	 
    assign TC0WE = addr >= 32'h7f00 && addr <= 32'h7f0b && byteen;
    assign TC1WE = addr >= 32'h7f10 && addr <= 32'h7f1b && byteen;

    assign read = (addr >= 32'h0000 && addr <= 32'h2fff) ? DMData  :
                  (addr >= 32'h7f00 && addr <= 32'h7f0b) ? TC0Data :
                  (addr >= 32'h7f10 && addr <= 32'h7f1b) ? TC1Data : 
						32'd0;			  
endmodule
