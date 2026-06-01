`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Shravan Patel
// Create Date: 13.03.2026 
// Design Name: Asynchronous FIFO
// Module Name: fifomem
/* Description: The FIFO memoery buffer is typically an 
   instantiated ASIC or FPGA dual-port, synchronous memory
   device. The memory buffer could also be synthesized to
   ASIC or FPGA registers using RTL code as done in this 
   module. If a vendor RAM is instantiated, it is highly 
   recommended that the instantiation to be done using named
   port connections.*/
//////////////////////////////////////////////////////////////////////////////////


module fifomem #( parameter DATASIZE = 8, // Memory data word width
                  parameter ADDRSIZE = 4) // Adderess bits
(
input  [DATASIZE-1:0] wdata,
input  [ADDRSIZE-1:0] waddr, raddr,
input                 wclken, wfull, wclk,
output [DATASIZE-1:0] rdata
);
// instantiation of vendor's dual port RAM
/* INSTANTIATE HERE (BY PORT NAME) */

// RTL Verilog memory model
reg [DATASIZE-1:0] mem [2**ADDRSIZE-1:0];
assign rdata = mem[raddr];

always @(posedge wclk) begin
  if(wclken && !wfull) begin
    mem[waddr] <= wdata;
  end
end

endmodule
