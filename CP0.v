`timescale 1ns / 1ps
module CP0(
    input  [ 0:0] clk    ,
    input  [ 0:0] reset  ,
    input  [ 0:0] WE     ,
    input  [ 4:0] CP0Addr,
    input  [31:0] CP0Data, 
    input  [31:0] VPC    ,   
    input  [ 0:0] delay  ,   
    input  [ 4:0] excCode,  
    input  [ 5:0] HWInt  , 
    input  [ 0:0] EXLClr , 
    output [31:0] outEPC ,  
	 output [31:0] CP0Read, 
    output [ 0:0] Req 
    );
	 
	 reg [31:0] SR   ;
	 reg [31:0] Cause;
	 reg [31:0] EPC  ;
	 
	 wire [0:0] exc  ;
	 wire [0:0] inter;		
	 
	 assign exc   = !SR[1] && excCode != 5'd31;
	 assign inter = !SR[1] && SR[0] && (SR[15:10] & HWInt) != 6'b0 ;
	 assign Req   = exc || inter;
	 
	 initial 
	 begin
		SR         <= 0    ;
	   Cause      <= 0    ;
		EPC        <= 0    ;
		Cause[6:2] <= 5'd31;
	 end
	 
	 always @(posedge clk)
	 begin
		if (reset)
		begin
			SR         <= 0    ;
			Cause      <= 0    ;
			EPC        <= 0    ;
			Cause[6:2] <= 5'd31;
		end 
		else 
		begin
			SR[1] <= EXLClr ? 1'b0 : 
                  Req    ? 1'b1 :
						SR[1];

         Cause[31:31] <= Req ? delay : Cause[31];
         Cause[15:10] <= HWInt;
         Cause[ 6: 2] <= inter ? 5'd0    :
                         exc   ? excCode :
							    Cause[6:2]; 
			if (WE) 
			begin
				if (CP0Addr == 5'd12) 
				begin
					SR <= CP0Data;
				end
				else if (CP0Addr == 5'd13) 
				begin
					Cause <= CP0Data;
				end 
				else if (CP0Addr == 5'd14) 
				begin
					EPC <= CP0Data;
				end
			end
			if (Req)
			begin
				EPC <= delay ? VPC - 4 : VPC;
			end
		end
	 end
	 
	 assign outEPC  = EPC;
	 assign CP0Read = CP0Addr == 5'd12 ? SR    :
							CP0Addr == 5'd13 ? Cause :
							CP0Addr == 5'd14 ? EPC   :
							32'd0;	
endmodule