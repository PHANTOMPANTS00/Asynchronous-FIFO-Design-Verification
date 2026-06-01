`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Shravan Patel 
// Create Date: 13.03.2026 
// Design Name: Write-domian to read-domain synchronizer
// Module Name: w2r_synchronizer
/* Description: This is a simple synchronizer module, used to pass
   an n-bit pointer from the write clock domain to the read clock
   domain, through a pair of registers that are clocked by FIFO
   read clock. All outputs in this module are entirely synchronous 
   to the rclk and all the inputs are entirely asynchronous to the
   wclk. */
//////////////////////////////////////////////////////////////////////////////////


module w2r_synchronizer #(parameter ADDRSIZE = 4)
(
input      [ADDRSIZE:0] wptr,
input                   rclk, rrst,
output reg [ADDRSIZE:0] rq2_wptr
 );
 reg [ADDRSIZE:0] rq1_wptr;
 
always @(posedge rclk or negedge rrst) begin
   if(!rrst) begin
     {rq2_wptr, rq1_wptr} <= 0;
   end
   else begin
     {rq2_wptr, rq1_wptr} <= {rq1_wptr, wptr};
   end
end
 
endmodule
