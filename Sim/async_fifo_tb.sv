`timescale 1ns / 1ps

module async_fifo_tb;

  // Parameters
  parameter DSIZE    = 8;
  parameter ADDRSIZE = 4;

  // DUT Signals
  logic [DSIZE-1:0] wdata;
  logic             winc, wclk, wrst;
  logic             rinc, rclk, rrst;
  logic [DSIZE-1:0] rdata;
  logic             wfull;
  logic             rempty;

  // SystemVerilog Queue to act as the Golden Reference Model
  logic [DSIZE-1:0] golden_queue[$];
  logic [DSIZE-1:0] expected_data;

  // Instantiate the DUT (Device Under Test)
  async_fifo #(
    .DSIZE(DSIZE),
    .ADDRSIZE(ADDRSIZE)
  ) dut (
    .wdata(wdata),
    .winc(winc),
    .wclk(wclk),
    .wrst(wrst),
    .rinc(rinc),
    .rclk(rclk),
    .rrst(rrst),
    .rdata(rdata),
    .wfull(wfull),
    .rempty(rempty)
  );

  // -----------------------------------------------------------
  // Clock Generation (Asynchronous domains)
  // wclk = 100 MHz (10ns period)
  // rclk = 40 MHz  (25ns period)
  // -----------------------------------------------------------
  initial begin
    wclk = 0;
    forever #5 wclk = ~wclk;
  end

  initial begin
    rclk = 0;
    forever #12.5 rclk = ~rclk;
  end

  // -----------------------------------------------------------
  // Verification Tasks
  // -----------------------------------------------------------
  
  // Task to write data into the FIFO
  task write_data(input logic [DSIZE-1:0] data);
    @(posedge wclk);
    if (!wfull) begin
      winc  <= 1'b1;
      wdata <= data;
      golden_queue.push_back(data); // Push to golden model
    end else begin
      $display("[%0t] WARNING: Tried to write to full FIFO", $time);
      winc <= 1'b0;
    end
    @(posedge wclk);
    winc <= 1'b0;
  endtask

  // Task to read and verify data from the FIFO
  task read_and_verify();
    @(posedge rclk);
    if (!rempty) begin
      rinc <= 1'b1;
      @(posedge rclk); // Wait for data to appear on rdata
      rinc <= 1'b0;
      
      expected_data = golden_queue.pop_front(); // Pop from golden model
      
      if (rdata !== expected_data) begin
        $error("[%0t] FAIL: Data mismatch! Expected: %h, Got: %h", $time, expected_data, rdata);
      end else begin
        $display("[%0t] PASS: Read %h successfully.", $time, rdata);
      end
    end else begin
      $display("[%0t] WARNING: Tried to read from empty FIFO", $time);
      rinc <= 1'b0;
    end
  endtask

  // -----------------------------------------------------------
  // Main Stimulus Block
  // -----------------------------------------------------------
  initial begin
    // Initialize signals
    winc  = 0;
    wdata = 0;
    rinc  = 0;
    
    // Apply Reset
    wrst = 0;
    rrst = 0;
    #30;
    wrst = 1;
    rrst = 1;
    #30;

    $display("--- Starting Async FIFO Automated Test ---");

    // Test 1: Write until almost full
    for (int i = 0; i < 15; i++) begin
      write_data($urandom_range(0, 255));
    end

    // Test 2: Read some data out
    for (int i = 0; i < 8; i++) begin
      read_and_verify();
    end

    // Test 3: Concurrent Read and Write (Stress Testing)
    fork
      // Thread 1: Write continuously
      begin
        for (int i = 0; i < 20; i++) begin
          write_data($urandom_range(0, 255));
          #15; // Random delay
        end
      end
      
      // Thread 2: Read continuously
      begin
        for (int i = 0; i < 20; i++) begin
          read_and_verify();
          #40; // Random delay
        end
      end
    join

    // Test 4: Flush remaining data
    while (golden_queue.size() > 0) begin
      read_and_verify();
    end

    #100;
    $display("--- Test Completed. If no FAILS printed, design is solid! ---");
    $finish;
  end

endmodule