`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Shravan Patel
// Create Date: 13.03.2026 
// Design Name: Read pointer & empty generation logic
/* Description: This module encloses all the logic that is generated
   within the read clock domain (except synchronizers). The read 
   pointer is a dual n-bit Gray code counter. The n-bit pointer
   rptr is passed to the write clock domain through the r2w_synchronizer
   module. The n-1 bit pointer is used to address the FIFO buffer.
   
   The FIFO empty output is registered and is assserted on the next
   rising rclk edge when the next rptr value equals the synchronized
   wptr value. This module is entirely synchrfonous to the rclk for
   simplified Static Timing Analysis.*/
//////////////////////////////////////////////////////////////////////////////////


module rptr_emptygenlogic #(parameter ADDRSIZE = 4)
(
input      [ADDRSIZE:0]   rq2_wptr,
input                     rinc, rclk, rrst,
output     [ADDRSIZE-1:0] raddr,
output reg                rempty,
output reg [ADDRSIZE:0]   rptr
);
reg  [ADDRSIZE:0] rbin;
wire [ADDRSIZE:0] rgraynext, rbinnext;

// GRAYSTYLE2 pointer
always @(posedge rclk or negedge rrst) begin
  if(!rrst) begin
    {rbin, rptr} <= 0;
  end
  else begin
    {rbin, rptr} <= {rbinnext, rgraynext};
  end
end

// Memory read-address pointer
assign raddr     = rbin[ADDRSIZE-1:0];
assign rbinnext  = rbin + (rinc & ~rempty);
assign rgraynext = (rbinnext >> 1)^rbinnext;

// FIFO empty when rgraynext(next rptr) == rq2_wptr(synchronized wptr) on reset
assign rempty_val = (rgraynext == rq2_wptr);

always @(posedge rclk or negedge rrst) begin
  if(!rrst) begin
   rempty <= 1'b1;
  end
  else begin
   rempty <= rempty_val; 
  end
end

endmodule
