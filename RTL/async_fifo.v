`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Shravan Patel
// Create Date: 13.03.2026 
// Design Name: FIFO top-level module
/* Description: The top-level FIFO module is parameterized FIFO 
   design with all the sub blocks instantiated using the recommended
   practice of doing named port connections.*/
//////////////////////////////////////////////////////////////////////////////////


module async_fifo #(parameter DSIZE    = 8,
                    parameter ADDRSIZE = 4)
(
input  [DSIZE-1:0] wdata,
input              winc, wclk, wrst,
input              rinc, rclk, rrst,
output [DSIZE-1:0] rdata,
output             wfull,
output             rempty
);
wire [ADDRSIZE-1:0] waddr, raddr;
wire [ADDRSIZE:0]   wptr, rptr, wq2_rptr, rq2_wptr;

fifomem #(DSIZE, ADDRSIZE) fifomem
                           (.rdata(rdata), .wdata(wdata),
                            .waddr(waddr), .raddr(raddr),
                            .wclken(winc), .wfull(wfull),
                            .wclk(wclk));

r2w_synchronizer r2w_synchronizer (.wq2_rptr(wq2_rptr), .rptr(rptr),
                                   .wclk(wclk), .wrst(wrst));

w2r_synchronizer w2r_synchronizer (.rq2_wptr(rq2_wptr), .wptr(wptr),
                                   .rclk(rclk), .rrst(rrst));
                                   
rptr_emptygenlogic #(ADDRSIZE) rptr_emptygenlogic
                               (.rempty(rempty), .raddr(raddr),
                                .rptr(rptr), .rq2_wptr(rq2_wptr),
                                .rinc(rinc), .rclk(rclk),
                                .rrst(rrst));
                                
wptr_fullgenlogic #(ADDRSIZE) wptr_fullgenlogic
                              (.wfull(wfull), .waddr(waddr),
                               .wptr(wptr), .wq2_rptr(wq2_rptr),
                               .winc(winc), .wclk(wclk),
                               .wrst(wrst));

endmodule
