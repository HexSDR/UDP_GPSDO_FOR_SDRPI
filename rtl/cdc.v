module CDC_REGS  # (parameter aw =4,parameter dw =8 )(
        input wr_clk,wr_en ,
        input [dw-1:0] wr_dat,
        input rd_clk,
        output [dw-1:0] rd_dat,
        output reg rd_vd
    );
   
        wire empty ;
    wire rd_fifo =   ~empty ;
    always @ (posedge rd_clk ) rd_vd <= rd_fifo ;
    
     async_fifo   #(
        .C_WIDTH ( dw) ,    // Data bus width
        .C_DEPTH(1<<aw) ) riffa_fifo    (
        .RD_CLK ( rd_clk ) ,                            // Read clock
        .RD_RST ( 1'b0 ) ,                            // Read synchronous reset
        .WR_CLK ( wr_clk) ,                             // Write clock
        .WR_RST ( 1'b0 ) ,                            // Write synchronous reset
        .WR_DATA (  wr_dat ) ,             // Write data input (WR_CLK)
        .WR_EN ( wr_en) ,                             // Write enable, high active (WR_CLK)
        .RD_DATA ( rd_dat) ,             // Read data output (RD_CLK)
        .RD_EN (rd_fifo ) ,                            // Read enable, high active (RD_CLK)
        .WR_FULL (  ) ,                         // Full condition (WR_CLK)
        .RD_EMPTY ( empty)                          // Empty condition (RD_CLK)
    );
     
            

        
endmodule

/*


 cdc_fifo cdc_fifo(
.wr_clk( ), 
.rst( ),
.wr_en( ) ,
.wr_dat( ),
.rd_clk( ),
.rd_en( ),
.rd_dat( ),
.rd_vd( )
);


*/



module cdc_fifo_riffa # (parameter aw =4,parameter dw =8 )(
        input wr_clk, rst,wr_en ,
        input [7:0] wr_dat,
        input rd_clk,
        output [7:0] rd_dat,
        output reg rd_vd
    );

    wire rst_n  = ~ rst ;
    reg[7:0] st ; 
        wire empty ;
    wire rd_fifo = ( st == 20 ) && ( ~empty ) ;
    always @ (posedge rd_clk ) rd_vd <= rd_fifo ;
    
     async_fifo_riffa   #(
        .C_WIDTH ( dw) ,    // Data bus width
        .C_DEPTH(1<<aw) ) riffa_fifo    (
        .RD_CLK ( rd_clk ) ,                            // Read clock
        .RD_RST ( 1'b0 ) ,                            // Read synchronous reset
        .WR_CLK ( wr_clk) ,                             // Write clock
        .WR_RST ( 1'b0 ) ,                            // Write synchronous reset
        .WR_DATA (  wr_dat ) ,             // Write data input (WR_CLK)
        .WR_EN ( wr_en) ,                             // Write enable, high active (WR_CLK)
        .RD_DATA ( rd_dat) ,             // Read data output (RD_CLK)
        .RD_EN (rd_fifo ) ,                            // Read enable, high active (RD_CLK)
        .WR_FULL (  ) ,                         // Full condition (WR_CLK)
        .RD_EMPTY ( empty)                          // Empty condition (RD_CLK)
    );
     
            
                         
    reg empty_r ,empty_1r ,empty_2r;
    always @ (posedge rd_clk) empty_r <= empty;
    always @ (posedge rd_clk) empty_1r <= empty_r;                  
    always @ (posedge rd_clk) empty_2r <= empty_1r;                  
                                                  
    always @ (posedge rd_clk  ) if ( rst )  st <= 0;else case (st)
        0: st<=10;
        10: if (empty_2r==0)st<=20;
        20: if (empty) st<=10;
        default  st<=0;endcase 
        
endmodule



/*

*/

 

module cdc_fifo_oc # (parameter aw =4,parameter dw =8 )(
        input wr_clk, rst,wr_en ,
        input [7:0] wr_dat,
        input rd_clk,
        output [7:0] rd_dat,
        output reg rd_vd
    );

    wire rst_n  = ~ rst ;
    reg[7:0] st ;
        wire [1:0]rd_level,wr_level;
        wire empty ;
    wire rd_fifo = ( st == 20 ) && ( ~empty ) ;
    always @ (posedge rd_clk ) rd_vd <= rd_fifo ;

 
    generic_fifo_dc_gray #(.aw(aw),.dw(dw)) generic_fifo_dc_gray (
                             .rd_clk(rd_clk) ,
                             .wr_clk(wr_clk) ,
                             .rst(rst_n) ,
                             .clr(~rst_n) ,
                             .din(wr_dat ) ,
                             .we(wr_en) ,
                             .dout(rd_dat ) ,
                             .re(rd_fifo ) ,
                             .full( ) ,
                             .empty(empty )  ,
                             .wr_level(wr_level) ,
                             .rd_level(rd_level)
                         );
                         
                         reg empty_r ,empty_1r ,empty_2r;
                         always @ (posedge rd_clk) empty_r <= empty;
                         always @ (posedge rd_clk) empty_1r <= empty_r;                  
                         always @ (posedge rd_clk) empty_2r <= empty_1r;                  
                                                  
    always @ (posedge rd_clk or posedge  rst) if ( rst )  st <= 0;else case (st)
        0: st<=10;
        10: if (empty_2r==0 )st<=20;
        20: if (empty) st<=10;
        default  st<=0;endcase 
        
endmodule

