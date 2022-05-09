 /*
module por_rst #( parameter HI_BIT = 8 )(input clk,rst , output reg por  );
reg [HI_BIT:0]  c ;always @(posedge clk) if (rst) c<=0; else if (c[HI_BIT]==0)c<=c+1;
always @(posedge clk)  por  <= ~c[HI_BIT] ;
endmodule 


*/
 
module por_rst #( parameter CNTR = 8 )(input clk,rst , output reg por  );
reg [31:0]  c ;
wire c_of = CNTR ==c; 
always @(posedge clk) if (rst) c<=0; else if (c_of==0)c<=c+1;
always @(posedge clk)  por  <= ~c_of ;
endmodule 
