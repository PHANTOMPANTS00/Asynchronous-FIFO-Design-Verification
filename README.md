# Parameterized Asynchronous FIFO with Self-Checking SystemVerilog Testbench

## 📌 Project Overview
This repository contains a robust, parameterized Asynchronous FIFO design configured for Clock Domain Crossing (CDC) architectures. The implementation safely transfers data between independent, unsynchronized read and write clock domains using dual n-bit Gray code counters to mitigate metastability risks. 

The accompanying verification environment features a fully automated, self-checking SystemVerilog testbench. Rather than relying on manual waveform inspection, it uses a dynamic queue-based golden reference model to validate data integrity in real time.

---

## 🛠️ Key Design Architecture

The hardware architecture follows best-in-class digital design practices and is split across 6 modular RTL blocks:

*   **`async_fifo.v`**: The top-level structural wrapper instantiating all sub-blocks with explicit named port connections.
*   **`fifomem.v`**: Dual-port synchronous memory array handling write storage and read operations.
*   **`r2w_synchronizer.v` & `w2r_synchronizer.v`**: Two-stage flip-flop synchronizers used to safely pass the Gray-coded read/write pointers across the clock domains.
*   **`wptr_fullgenlogic.v`**: Generates the binary/Gray write pointer counters and handles synchronous full-flag (`wfull`) logic inside the write clock domain.
*   **`rptr_emptygenlogic.v`**: Generates the binary/Gray read pointer counters and handles synchronous empty-flag (`rempty`) logic inside the read clock domain.

### Hardware Features
*   **Meta-stability Mitigation:** Utilizes 2-stage synchronization loops for safe pointer passing across asynchronous domain boundaries.
*   **Gray Coding:** Pointers are converted to Gray code before synchronization so that only one bit changes per clock cycle, preventing false full/empty flag evaluations.
*   **Glitch-Free Flag Generation:** Full and empty flags are registered within their respective clock domains to ensure optimal Static Timing Analysis (STA) clean paths.
*   **Parameterized Design:** Configurable data word size (`DSIZE`) and address bits/memory depth (`ADDRSIZE`).

### Schematic
<img width="2560" height="1528" alt="Async_FIFO_RTL" src="https://github.com/user-attachments/assets/995f96c3-2daa-4a47-b1f9-d178e08769b5" />



---

## 🧪 Verification Strategy & Testbench

Modern semiconductor engineering prioritizes automated validation. This project utilizes a **Self-Checking SystemVerilog Testbench** (`async_fifo_tb.sv`) that completely replaces manual visual verification:

1.  **Asynchronous Stress Test:** The write domain runs at **100 MHz (10ns period)** while the read domain runs at a completely independent **40 MHz (25ns period)** to aggressively simulate worst-case clock phase shifts.
2.  **Golden Reference Model:** A SystemVerilog dynamic `queue` models an idealized, zero-delay FIFO. Data successfully written to the RTL is simultaneously pushed into the queue.
3.  **Automated Regression & Checking:** During a read transaction, data popped from the hardware FIFO is automatically compared against the golden queue. Any mismatches instantly trigger a SystemVerilog `$error` statement.
4.  **Full FIFO Boundary Test:** The testbench drives back-to-back writes to saturate the FIFO, checking the robustness of the `wfull` assertion and confirming that extra writes are ignored without corrupting existing data.

---

## 📊 Simulation Results

The simulation was executed using **AMD Xilinx Vivado (xsim)**. The testbench ran to absolute completion (`$finish called at 2487500 ps`), passing all random data blocks and stress scenarios.

### Tcl Console Output Log
<img width="2560" height="1528" alt="Screenshot 2026-06-01 175243" src="https://github.com/user-attachments/assets/1f50e76e-d23d-4e6d-92da-6de334573aaa" />

