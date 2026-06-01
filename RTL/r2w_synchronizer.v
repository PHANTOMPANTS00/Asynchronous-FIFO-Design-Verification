`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Shravan Patel
// Create Date: 13.03.2026
// Design Name: Read-domain to write-domain synchronizer
// Module Name: r2w_synchronizer
/* Description: This is a simple synchronizer module to pass an
   n-bit pointer from the read clock domain to the write clock
   domian through a pair of registers that are clocked by the
   FIFO write clock. All outputs are entirely synchronous to the 
   wclk and all the inputs are entirely asynchronous to the rclk */ 
//////////////////////////////////////////////////////////////////////////////////


module r2w_synchronizer #(parameter ADDRSIZE = 4) 
(
input      [ADDRSIZE:0] rptr,
input                   wclk, wrst,
output reg [ADDRSIZE:0] wq2_rptr 
);
reg [ADDRSIZE:0] wq1_rptr;

always @(posedge wclk or negedge wrst)
  if(!wrst) begin
   {wq2_rptr, wq1_rptr} <= 0;
  end 
  else begin
   {wq2_rptr, wq1_rptr} <= {wq1_rptr, rptr};
  end
endmodule
