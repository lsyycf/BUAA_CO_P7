`timescale 1ns / 1ps
module mips(
    input  [ 0:0] clk           ,                    
    input  [ 0:0] reset         ,                 
    input  [ 0:0] interrupt     ,
    input  [31:0] i_inst_rdata  ,   
    input  [31:0] m_data_rdata  ,
    output [31:0] m_data_addr   ,
    output [31:0] macroscopic_pc, 
    output [31:0] i_inst_addr   ,	 
    output [31:0] m_data_wdata  ,  
    output [ 3:0] m_data_byteen ,  
    output [31:0] m_int_addr    ,     
    output [ 3:0] m_int_byteen  ,  
    output [31:0] m_inst_addr   ,    
    output [ 0:0] w_grf_we      ,            
    output [ 4:0] w_grf_addr    ,     
    output [31:0] w_grf_wdata   ,    
    output [31:0] w_inst_addr 
	 );
	 
	 wire [31:0] rdata  ;
	 wire [ 0:0] TC0WE  ;
	 wire [ 0:0] TC1WE  ;
	 wire [31:0] TC0data;
	 wire [31:0] TC1data;
	 wire [ 0:0] IRQ0   ;
	 wire [ 0:0] IRQ1   ;
	 wire [ 5:0] HWInt  ;
	 
	 CPU CPU_instance(
	                  .clk           (clk)           , 
							.reset         (reset)         , 
							.i_inst_rdata  (i_inst_rdata)  , 
							.m_data_rdata  (rdata)         , 
							.HWInt         (HWInt)         , 
					      .macroscopic_pc(macroscopic_pc), 
							.i_inst_addr   (i_inst_addr)   , 
							.m_data_addr   (m_data_addr)   , 
							.m_data_wdata  (m_data_wdata)  , 
							.m_data_byteen (m_data_byteen) , 
							.m_inst_addr   (m_inst_addr)   , 
							.w_grf_we      (w_grf_we)      , 
							.w_grf_addr    (w_grf_addr)    , 
							.w_grf_wdata   (w_grf_wdata)   ,
							.w_inst_addr   (w_inst_addr)
	 );
	 
	 assign m_int_addr   = m_data_addr  ;
	 assign m_int_byteen = m_data_byteen;
	 
	 Bridge Bridge_instance(
	                        .addr   (m_data_addr)  ,
									.byteen (m_data_byteen),
									.DMData (m_data_rdata) ,
									.TC0Data(TC0data)      , 
									.TC1Data(TC1data)      ,
									.TC0WE  (TC0WE)        , 
									.TC1WE  (TC1WE)        , 
									.read   (rdata)
    );
						
	 assign HWInt = {3'd0, interrupt, IRQ1, IRQ0};
	 
	 TC TC0(
			  .clk  (clk)              ,
			  .reset(reset)            , 
			  .Addr (m_data_addr[31:2]),
			  .WE   (TC0WE)            , 
			  .Din  (m_data_wdata)     , 
			  .Dout (TC0data)          , 
			  .IRQ  (IRQ0)
	 );
	 
	 TC TC1(
			  .clk  (clk)              , 
			  .reset(reset)            ,
			  .Addr (m_data_addr[31:2]),
			  .WE   (TC1WE)            , 
			  .Din  (m_data_wdata)     , 
			  .Dout (TC1data)          , 
			  .IRQ  (IRQ1)
	 );

endmodule

