// ----------------------------------------------------------------------
// Copyright (c) 2016, The Regents of the University of California All
// rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
// 
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
// 
//     * Redistributions in binary form must reproduce the above
//       copyright notice, this list of conditions and the following
//       disclaimer in the documentation and/or other materials provided
//       with the distribution.
// 
//     * Neither the name of The Regents of the University of California
//       nor the names of its contributors may be used to endorse or
//       promote products derived from this software without specific
//       prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL REGENTS OF THE
// UNIVERSITY OF CALIFORNIA BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
// OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
// TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
// USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
// DAMAGE.
// ----------------------------------------------------------------------
//----------------------------------------------------------------------------
// Filename:			async_fifo.v
// Version:				1.00.a
// Verilog Standard:	Verilog-2001
// Description:			Asynchronous capable parameterized FIFO. As with all
// traditional FIFOs, the RD_DATA will be valid one cycle following a RD_EN 
// assertion. RD_EMPTY will remain low until the cycle following the last RD_EN 
// assertion. Note, that RD_EMPTY may actually be high on the same cycle that 
// RD_DATA contains valid data.
// Author:				Matt Jacobsen
// History:				@mattj: Version 2.0
// Additional Comments: Based on design by CE Cummings in Simulation and 
// Synthesis Techniques for Asynchronous FIFO Design with Asynchronous Pointer 
// Comparisons
//-----------------------------------------------------------------------------
`timescale 1ns/1ns

function integer clog2;
	input [31:0] N;
	reg [31:0] value;
	begin
        clog2 = N==1?0:N==2?1:N<=4?2:N<=8?3:N<=16?4:N<=32?5:N<=64?6:N<=128?7:N<=256?8:N<=512?9:N<=1024?10:N<=2048?11:N<=4096?12:N<=8192?13:N<=16384?14:N<=32768?15:N<=65536?16:N<=131072?17:N<=262144?18:N<=524288?19:N<=1048576?20:N<=2097152?21:N<=4194304?22:N<=8388608?23:N<=16777216?24:N<=33554432?25:N<=67108864?26:N<=134217728?27:N<=268435456?28:N<=536870912?29:N<=1073741824?30:31 ;
	end
endfunction
// clog2s -- calculate the ceiling log2 value, min return is 1 (safe).
function integer clog2s;
	input [31:0] N;
	reg [31:0] value;
	begin
		clog2s = N<=2?1:N<=4?2:N<=8?3:N<=16?4:N<=32?5:N<=64?6:N<=128?7:N<=256?8:N<=512?9:N<=1024?10:N<=2048?11:N<=4096?12:N<=8192?13:N<=16384?14:N<=32768?15:N<=65536?16:N<=131072?17:N<=262144?18:N<=524288?19:N<=1048576?20:N<=2097152?21:N<=4194304?22:N<=8388608?23:N<=16777216?24:N<=33554432?25:N<=67108864?26:N<=134217728?27:N<=268435456?28:N<=536870912?29:N<=1073741824?30:31 ;		
	end
endfunction


// `ifndef LOG2
//liwei  github/hexsdr  715713994@qq.com

`define CLOG2S(N)( N<=2?1:N<=4?2:N<=8?3:N<=16?4:N<=32?5:N<=64?6:N<=128?7:N<=256?8:N<=512?9:N<=1024?10:N<=2048?11:N<=4096?12:N<=8192?13:N<=16384?14:N<=32768?15:N<=65536?16:N<=131072?17:N<=262144?18:N<=524288?19:N<=1048576?20:N<=2097152?21:N<=4194304?22:N<=8388608?23:N<=16777216?24:N<=33554432?25:N<=67108864?26:N<=134217728?27:N<=268435456?28:N<=536870912?29:N<=1073741824?30:31)
`define CLOG2(N) ( N==1?0:N==2?1:N<=4?2:N<=8?3:N<=16?4:N<=32?5:N<=64?6:N<=128?7:N<=256?8:N<=512?9:N<=1024?10:N<=2048?11:N<=4096?12:N<=8192?13:N<=16384?14:N<=32768?15:N<=65536?16:N<=131072?17:N<=262144?18:N<=524288?19:N<=1048576?20:N<=2097152?21:N<=4194304?22:N<=8388608?23:N<=16777216?24:N<=33554432?25:N<=67108864?26:N<=134217728?27:N<=268435456?28:N<=536870912?29:N<=1073741824?30:31)

module async_fifo_riffa #(
	parameter C_WIDTH = 8,	// Data bus width
	parameter C_DEPTH = 64,	// Depth of the FIFO
	// Local parameters
	parameter C_REAL_DEPTH = 2**`CLOG2(C_DEPTH),
	parameter C_DEPTH_BITS = `CLOG2(C_REAL_DEPTH),
	parameter C_DEPTH_P1_BITS = `CLOG2(C_REAL_DEPTH+1)
)
(
	input RD_CLK,							// Read clock
	input RD_RST,							// Read synchronous reset
	input WR_CLK,						 	// Write clock
	input WR_RST,							// Write synchronous reset
	input [C_WIDTH-1:0] WR_DATA, 			// Write data input (WR_CLK)
	input WR_EN, 							// Write enable, high active (WR_CLK)
	output [C_WIDTH-1:0] RD_DATA, 			// Read data output (RD_CLK)
	input RD_EN,							// Read enable, high active (RD_CLK)
	output WR_FULL, 						// Full condition (WR_CLK)
	output RD_EMPTY 						// Empty condition (RD_CLK)
);
 

wire						wCmpEmpty;
wire						wCmpFull;
wire	[C_DEPTH_BITS-1:0]	wWrPtr;
wire	[C_DEPTH_BITS-1:0]	wRdPtr;
wire	[C_DEPTH_BITS-1:0]	wWrPtrP1;
wire	[C_DEPTH_BITS-1:0]	wRdPtrP1;


// Memory block (synthesis attributes applied to this module will
// determine the memory option).
ram_2clk_1w_1r #(.C_RAM_WIDTH(C_WIDTH), .C_RAM_DEPTH(C_REAL_DEPTH)) mem (
	.CLKA(WR_CLK),
	.ADDRA(wWrPtr),
	.WEA(WR_EN & !WR_FULL),
	.DINA(WR_DATA),
	.CLKB(RD_CLK),
	.ADDRB(wRdPtr),
	.DOUTB(RD_DATA)
);


// Compare the pointers.
async_cmp #(.C_DEPTH_BITS(C_DEPTH_BITS)) asyncCompare (
	.WR_RST(WR_RST),
	.WR_CLK(WR_CLK),
	.RD_RST(RD_RST),
	.RD_CLK(RD_CLK),
	.RD_VALID(RD_EN & !RD_EMPTY),
	.WR_VALID(WR_EN & !WR_FULL),
	.EMPTY(wCmpEmpty), 
	.FULL(wCmpFull),
	.WR_PTR(wWrPtr), 
	.WR_PTR_P1(wWrPtrP1), 
	.RD_PTR(wRdPtr), 
	.RD_PTR_P1(wRdPtrP1)
);


// Calculate empty
rd_ptr_empty #(.C_DEPTH_BITS(C_DEPTH_BITS)) rdPtrEmpty (
	.RD_EMPTY(RD_EMPTY), 
	.RD_PTR(wRdPtr),
	.RD_PTR_P1(wRdPtrP1),
	.CMP_EMPTY(wCmpEmpty), 
	.RD_EN(RD_EN),
	.RD_CLK(RD_CLK), 
	.RD_RST(RD_RST)
);


// Calculate full
wr_ptr_full #(.C_DEPTH_BITS(C_DEPTH_BITS)) wrPtrFull (
	.WR_CLK(WR_CLK), 
	.WR_RST(WR_RST),
	.WR_EN(WR_EN),
	.WR_FULL(WR_FULL), 
	.WR_PTR(wWrPtr),
	.WR_PTR_P1(wWrPtrP1),
	.CMP_FULL(wCmpFull)
);
 
endmodule


module async_cmp #(
  parameter C_DEPTH_BITS = 4,
  // Local parameters
  parameter N = C_DEPTH_BITS-1
)
(
	input WR_RST,
	input WR_CLK,
	input RD_RST,
	input RD_CLK,
	input RD_VALID,
	input WR_VALID,
	output EMPTY, 
	output FULL, 
	input [C_DEPTH_BITS-1:0] WR_PTR, 
	input [C_DEPTH_BITS-1:0] RD_PTR, 
	input [C_DEPTH_BITS-1:0] WR_PTR_P1, 
	input [C_DEPTH_BITS-1:0] RD_PTR_P1
);
  
reg				rDir=0;
wire			wDirSet = (  (WR_PTR[N]^RD_PTR[N-1]) & ~(WR_PTR[N-1]^RD_PTR[N]));
wire			wDirClr = ((~(WR_PTR[N]^RD_PTR[N-1]) &  (WR_PTR[N-1]^RD_PTR[N])) | WR_RST);

reg				rRdValid=0;
reg				rEmpty=1;
reg				rFull=0;
wire			wATBEmpty = ((WR_PTR == RD_PTR_P1) && (RD_VALID | rRdValid));
wire			wATBFull = ((WR_PTR_P1 == RD_PTR) && WR_VALID);
wire			wEmpty = ((WR_PTR == RD_PTR) && !rDir);
wire			wFull = ((WR_PTR == RD_PTR) && rDir);

assign EMPTY = wATBEmpty || rEmpty;
assign FULL  = wATBFull || rFull;

always @(posedge wDirSet or posedge wDirClr)
if (wDirClr) 
	rDir <= 1'b0;
else
	rDir <= 1'b1;

always @(posedge RD_CLK) begin
	rEmpty <= (RD_RST ? 1'd1 : wEmpty);
	rRdValid <= (RD_RST ? 1'd0 : RD_VALID);
end

always @(posedge WR_CLK) begin
	rFull <= (WR_RST ? 1'd0 : wFull);
end

endmodule 
 
 
module rd_ptr_empty #(
	parameter C_DEPTH_BITS = 4
)
(
	input RD_CLK, 
	input RD_RST,
	input RD_EN, 
	output RD_EMPTY,
	output [C_DEPTH_BITS-1:0] RD_PTR,
	output [C_DEPTH_BITS-1:0] RD_PTR_P1,
	input CMP_EMPTY 
);

reg							rEmpty=1;
reg							rEmpty2=1;
reg		[C_DEPTH_BITS-1:0]	rRdPtr=0;
reg		[C_DEPTH_BITS-1:0]	rRdPtrP1=0;
reg		[C_DEPTH_BITS-1:0]	rBin=0;
reg		[C_DEPTH_BITS-1:0]	rBinP1=1;
wire	[C_DEPTH_BITS-1:0]	wGrayNext;
wire	[C_DEPTH_BITS-1:0]	wGrayNextP1;
wire	[C_DEPTH_BITS-1:0]	wBinNext;
wire	[C_DEPTH_BITS-1:0]	wBinNextP1;

assign RD_EMPTY = rEmpty;
assign RD_PTR = rRdPtr;
assign RD_PTR_P1 = rRdPtrP1;

// Gray coded pointer
always @(posedge RD_CLK or posedge RD_RST) begin
	if (RD_RST) begin
		rBin <= #1 0;
		rBinP1 <= #1 1;
		rRdPtr <= #1 0;
		rRdPtrP1 <= #1 0;
	end
	else begin
		rBin <= #1 wBinNext;
		rBinP1 <= #1 wBinNextP1;
		rRdPtr <= #1 wGrayNext;
		rRdPtrP1 <= #1 wGrayNextP1;
	end
end

// Increment the binary count if not empty
assign wBinNext = (!rEmpty ? rBin + RD_EN : rBin);
assign wBinNextP1 = (!rEmpty ? rBinP1 + RD_EN : rBinP1);
assign wGrayNext = ((wBinNext>>1) ^ wBinNext); // binary-to-gray conversion
assign wGrayNextP1 = ((wBinNextP1>>1) ^ wBinNextP1); // binary-to-gray conversion

always @(posedge RD_CLK) begin
	if (CMP_EMPTY)
		{rEmpty, rEmpty2} <= #1 2'b11;
	else
		{rEmpty, rEmpty2} <= #1 {rEmpty2, CMP_EMPTY};
end

endmodule
 
 
module wr_ptr_full #(
	parameter C_DEPTH_BITS = 4
)
(
	input WR_CLK, 
	input WR_RST,
	input WR_EN,
	output WR_FULL, 
	output [C_DEPTH_BITS-1:0] WR_PTR, 
	output [C_DEPTH_BITS-1:0] WR_PTR_P1, 
	input CMP_FULL
);

reg							rFull=0;
reg							rFull2=0;
reg		[C_DEPTH_BITS-1:0]	rPtr=0;
reg		[C_DEPTH_BITS-1:0]	rPtrP1=0;
reg		[C_DEPTH_BITS-1:0]	rBin=0;
reg		[C_DEPTH_BITS-1:0]	rBinP1=1;
wire	[C_DEPTH_BITS-1:0]	wGrayNext;
wire	[C_DEPTH_BITS-1:0]	wGrayNextP1;
wire	[C_DEPTH_BITS-1:0]	wBinNext;
wire	[C_DEPTH_BITS-1:0]	wBinNextP1;

assign WR_FULL = rFull;
assign WR_PTR = rPtr;
assign WR_PTR_P1 = rPtrP1;

// Gray coded pointer
always @(posedge WR_CLK or posedge WR_RST) begin
	if (WR_RST) begin
		rBin <= #1 0;
		rBinP1 <= #1 1;
		rPtr <= #1 0;
		rPtrP1 <= #1 0;
	end
	else begin
		rBin <= #1 wBinNext;
		rBinP1 <= #1 wBinNextP1;
		rPtr <= #1 wGrayNext;
		rPtrP1 <= #1 wGrayNextP1;
	end
end

// Increment the binary count if not full
assign wBinNext = (!rFull ? rBin + WR_EN : rBin);
assign wBinNextP1 = (!rFull ? rBinP1 + WR_EN : rBinP1);
assign wGrayNext = ((wBinNext>>1) ^ wBinNext); // binary-to-gray conversion
assign wGrayNextP1 = ((wBinNextP1>>1) ^ wBinNextP1); // binary-to-gray conversion

always @(posedge WR_CLK) begin
	if (WR_RST) 
		{rFull, rFull2} <= #1 2'b00;
	else if (CMP_FULL) 
		{rFull, rFull2} <= #1 2'b11;
	else
		{rFull, rFull2} <= #1 {rFull2, CMP_FULL};
end

endmodule

///////////////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/1ns
module sync_fifo #(
	parameter C_WIDTH = 32,	// Data bus width
	parameter C_DEPTH = 1024,	// Depth of the FIFO
	parameter C_PROVIDE_COUNT = 0, // Include code for counts
	// Local parameters
	parameter C_REAL_DEPTH = 2**`CLOG2(C_DEPTH),
	parameter C_DEPTH_BITS = `CLOG2S(C_REAL_DEPTH),
	parameter C_DEPTH_P1_BITS = `CLOG2S(C_REAL_DEPTH+1)
)
(
	input CLK,								// Clock
	input RST, 								// Sync reset, active high
	input [C_WIDTH-1:0] WR_DATA, 			// Write data input
	input WR_EN, 							// Write enable, high active
	output [C_WIDTH-1:0] RD_DATA, 			// Read data output
	input RD_EN,							// Read enable, high active
	output FULL, 							// Full condition
	output EMPTY, 							// Empty condition
	output [C_DEPTH_P1_BITS-1:0] COUNT		// Data count
);
 

reg		[C_DEPTH_BITS:0]	rWrPtr=0, _rWrPtr=0;
reg		[C_DEPTH_BITS:0]	rWrPtrPlus1=1, _rWrPtrPlus1=1;
reg		[C_DEPTH_BITS:0]	rRdPtr=0, _rRdPtr=0;
reg		[C_DEPTH_BITS:0]	rRdPtrPlus1=1, _rRdPtrPlus1=1;
reg							rFull=0, _rFull=0;
reg							rEmpty=1, _rEmpty=1;

// Memory block (synthesis attributes applied to this module will
// determine the memory option).
ram_1clk_1w_1r #(.C_RAM_WIDTH(C_WIDTH), .C_RAM_DEPTH(C_REAL_DEPTH)) mem (
	.CLK(CLK),
	.ADDRA(rWrPtr[C_DEPTH_BITS-1:0]),
	.WEA(WR_EN & !rFull),
	.DINA(WR_DATA),
	.ADDRB(rRdPtr[C_DEPTH_BITS-1:0]),
	.DOUTB(RD_DATA)
);


// Write pointer logic.
always @ (posedge CLK) begin
	if (RST) begin
		rWrPtr <= #1 0;
		rWrPtrPlus1 <= #1 1;
	end
	else begin
		rWrPtr <= #1 _rWrPtr;
		rWrPtrPlus1 <= #1 _rWrPtrPlus1;
	end
end

always @ (*) begin
	if (WR_EN & !rFull) begin
		_rWrPtr = rWrPtrPlus1;
		_rWrPtrPlus1 = rWrPtrPlus1 + 1'd1;
	end
	else begin
		_rWrPtr = rWrPtr;
		_rWrPtrPlus1 = rWrPtrPlus1;
	end
end


// Read pointer logic.
always @ (posedge CLK) begin
	if (RST) begin
		rRdPtr <= #1 0;
		rRdPtrPlus1 <= #1 1;
	end
	else begin
		rRdPtr <= #1 _rRdPtr;
		rRdPtrPlus1 <= #1 _rRdPtrPlus1;
	end
end

always @ (*) begin
	if (RD_EN & !rEmpty) begin
		_rRdPtr = rRdPtrPlus1;
		_rRdPtrPlus1 = rRdPtrPlus1 + 1'd1;
	end
	else begin
		_rRdPtr = rRdPtr;
		_rRdPtrPlus1 = rRdPtrPlus1;
	end
end


// Calculate empty
assign EMPTY = rEmpty;

always @ (posedge CLK) begin
	rEmpty <= #1 (RST ? 1'd1 : _rEmpty);
end

always @ (*) begin
	_rEmpty = (rWrPtr == rRdPtr) || (RD_EN && !rEmpty && (rWrPtr == rRdPtrPlus1));
end


// Calculate full
assign FULL = rFull;

always @ (posedge CLK) begin
	rFull <= #1 (RST ? 1'd0 : _rFull);
end

always @ (*) begin
	_rFull = ((rWrPtr[C_DEPTH_BITS-1:0] == rRdPtr[C_DEPTH_BITS-1:0]) && (rWrPtr[C_DEPTH_BITS] != rRdPtr[C_DEPTH_BITS])) ||
	(WR_EN && (rWrPtrPlus1[C_DEPTH_BITS-1:0] == rRdPtr[C_DEPTH_BITS-1:0]) && (rWrPtrPlus1[C_DEPTH_BITS] != rRdPtr[C_DEPTH_BITS]));
end

generate
if (C_PROVIDE_COUNT) begin: provide_count
	reg [C_DEPTH_BITS:0] rCount=0, _rCount=0;

	assign COUNT = (rFull ? C_REAL_DEPTH[C_DEPTH_P1_BITS-1:0] : rCount);

	// Calculate read count
	always @ (posedge CLK) begin
		if (RST)
			rCount <= #1 0;
		else
			rCount <= #1 _rCount;
	end

	always @ (*) begin
		_rCount = (rWrPtr - rRdPtr);
	end
end
else begin: provide_no_count
	assign COUNT = 0;
end 
endgenerate

endmodule


 
module ram_1clk_1w_1r
    #(
      parameter C_RAM_WIDTH = 32,
      parameter C_RAM_DEPTH = 1024
      )
    (
     input                           CLK,
     input [`CLOG2S(C_RAM_DEPTH)-1:0] ADDRA,
     input                           WEA,
     input [`CLOG2S(C_RAM_DEPTH)-1:0] ADDRB,
     input [C_RAM_WIDTH-1:0]         DINA,
     output [C_RAM_WIDTH-1:0]        DOUTB
     );
    localparam C_RAM_ADDR_BITS = `CLOG2S(C_RAM_DEPTH);
    reg [C_RAM_WIDTH-1:0]            rRAM [C_RAM_DEPTH-1:0];
    reg [C_RAM_WIDTH-1:0]            rDout;
    assign DOUTB = rDout;
    always @(posedge CLK) begin
        if (WEA)
            rRAM[ADDRA] <= #1 DINA;
        rDout <= #1 rRAM[ADDRB];
    end    
endmodule

 
module ram_2clk_1w_1r 
    #(
      parameter C_RAM_WIDTH = 32,
      parameter C_RAM_DEPTH = 1024
      )
    (
     input                           CLKA,
     input                           CLKB,
     input                           WEA,
     input [`CLOG2S(C_RAM_DEPTH)-1:0] ADDRA,
     input [`CLOG2S(C_RAM_DEPTH)-1:0] ADDRB,
     input [C_RAM_WIDTH-1:0]         DINA,
     output [C_RAM_WIDTH-1:0]        DOUTB
     );
    //Local parameters
    localparam C_RAM_ADDR_BITS = `CLOG2S(C_RAM_DEPTH);
    reg [C_RAM_WIDTH-1:0]            rRAM [C_RAM_DEPTH-1:0];
    reg [C_RAM_WIDTH-1:0]            rDout;   
    assign DOUTB = rDout;
    always @(posedge CLKA) begin
        if (WEA)
            rRAM[ADDRA] <= #1 DINA;
    end
    always @(posedge CLKB) begin
        rDout <= #1 rRAM[ADDRB];
    end
endmodule