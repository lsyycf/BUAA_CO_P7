`timescale 1ns / 1ps
module W_CU(
    input  [5:0] op      ,
	 input  [4:0] rs      ,
    input  [5:0] rb      ,
	 output [1:0] Tnew    , 
	 output [1:0] fwAddrOp, 
	 output [1:0] fwDataOp,
	 output [0:0] new
    );
	 
	 wire add  ;
    wire sub  ;
	 wire andd ;
	 wire orr  ;
	 wire slt  ;
	 wire sltu ;
    wire ori  ;
	 wire lui  ;
	 wire addi ;
	 wire andi ;
    wire lw   ;
	 wire lh   ;
	 wire lb   ;
    wire sw   ;
	 wire sh   ;
	 wire sb   ;
    wire beq  ;
	 wire bne  ;
    wire jal  ;
    wire jr   ;
	 wire mult ;
	 wire multu;
	 wire div  ;
	 wire divu ;
	 wire mflo ;
	 wire mfhi ;
	 wire mtlo ;
	 wire mthi ;
	 wire mfc  ; 
	 wire mtc  ; 
	 wire sys  ;
	 wire ere  ; 
	 wire nop  ;
	 wire ne   ; 
	 
	 Decoder Decoder_instance(
									  .op      (op)   ,
									  .rs      (rs)   ,
									  .rb      (rb)   , 
									  .add     (add)  , 
									  .sub     (sub)  ,
									  .andd    (andd) ,
									  .orr     (orr)  ,
									  .lui     (lui)  , 
									  .slt     (slt)  ,
									  .sltu    (sltu) ,
									  .ori     (ori)  ,
									  .addi    (addi) ,
									  .andi    (andi) ,
									  .mfhi    (mfhi) ,
									  .mflo    (mflo) ,
 									  .mthi    (mthi) ,
									  .mtlo    (mtlo) ,
									  .mult    (mult) ,
									  .multu   (multu),
									  .div     (div)  ,
									  .divu    (divu) ,
									  .lw      (lw)   ,
									  .lh      (lh)   ,
									  .lb      (lb)   ,
									  .sw      (sw)   ,
									  .sh      (sh)   ,
									  .sb      (sb)   ,
									  .beq     (beq)  ,
									  .bne     (bne)  ,
									  .jal     (jal)  ,
									  .jr      (jr)   ,
									  .mfc0    (mfc)  ,
									  .mtc0    (mtc)  ,
									  .eret    (ere)  ,
									  .syscall (sys)  ,
									  .nop     (nop)  ,
									  .new     (ne)
   );
														
	 assign Tnew = add || sub || andd || orr || slt || sltu || ori || addi || andi || lw || lh || lb || lui || jal || mfhi || mflo || mfc ? 2'b00 : 2'b11;									

	 assign fwAddrOp = add || sub || andd || orr || slt || sltu || mfhi || mflo ? 2'b00 :
								ori || addi || andi || lw || lh || lb || lui || mfc ? 2'b01 : 
								jal ? 2'b10 : 
								2'b11; 
					
	 assign fwDataOp = add || sub || andd || orr || slt || sltu || lui || ori || addi || andi || mfhi || mflo ? 2'b00 :
								lw || lh || lb || mfc ? 2'b01 :
								jal ? 2'b10 : 
								2'b11; 
	 assign new = ne;
	 
endmodule

