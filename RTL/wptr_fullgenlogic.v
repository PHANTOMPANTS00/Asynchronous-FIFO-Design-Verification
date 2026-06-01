`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Shravan Patel 
// Create Date: 13.03.2026 
// Design Name: Write pointer & full generation logic 
/* Description: This module encloses all of the FIFO logic that is
   generated within the write clock domain (except synchronizers).
   The write pointer is a dual n-bit Gray code counter. The n-bit 
   pointer wptr is passed to the read clock domain through the 
   w2r_synchronizer module. the n-1 bit pointer waddr is used to 
   adderss the FIFO buffer.
   
   The FIFO full output is registered and is asserted on the next rising 
   wclk edge when the next modified wgraynext value equals the 
   synchronized and modified w2q_rptr value (except MSBs). The module is
   entirely synchronous to the wclk for simplified Static Timing
   Analysis.*/
//////////////////////////////////////////////////////////////////////////////////


module wptr_fullgenlogic #(parameter ADDRSIZE = 4)
(
input      [ADDRSIZE:0]   wq2_rptr,
input                     winc,wclk,wrst,
output reg                wfull,
output reg [ADDRSIZE:0]   wptr,
output     [ADDRSIZE-1:0] waddr
);
reg  [ADDRSIZE:0] wbin;
wire [ADDRSIZE:0] wbinnext, wgraynext;

// GRAYSTYLE2 pointer
always @(posedge wclk or negedge wrst) begin
  if(!wrst) begin
   {wbin, wptr} <= 0;
  end
  else begin 
   {wbin, wptr} <= {wbinnext, wgraynext};
  end
end 

// Memory write-address pointer
assign waddr     = wbin[ADDRSIZE-1:0];
assign wbinnext  = wbin + (winc & ~wfull);
assign wgraynext = (wbinnext>>1)^wbinnext;

// FIFO full generation (wgraynext == w2q_rptr(except MSBs))
assign wfull_val = (wgraynext == {~wq2_rptr[ADDRSIZE:ADDRSIZE-1],
                                   wq2_rptr[ADDRSIZE-2:0]});

always @(posedge wclk or negedge wrst) begin
   if(!wrst) begin
     wfull <= 1'b0;
   end
   else begin 
    wfull <= wfull_val;
   end
end

endmodule 
