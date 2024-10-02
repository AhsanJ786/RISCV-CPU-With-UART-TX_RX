# 32-bit RISC-V Processor

## Overview

This repository contains the implementation of a 32-bit RISC-V processor core. The processor features a 3-stage pipeline and integrates UART (Universal Asynchronous Receiver/Transmitter) modules for communication. The UART modules include both a transmitter and a receiver, enabling serial communication.

### Features

- **32-bit RISC-V Processor**: Implements the RISC-V Instruction Set Architecture (ISA) RV32I.
- **3-Stage Pipeline**: Includes a simplified pipeline for efficient instruction processing.
  - **Stages**:
    1. **Fetch**: Instruction is fetched from memory.
    2. **Decode/Execute**: Instruction is decoded, and execution begins.
    3. **Write-Back**: Result of the instruction is written back to the register file.
- **UART Transmitter and Receiver**: Serial communication support using UART.
  - **Transmitter**: Sends data to connected devices.
  - **Receiver**: Receives data from external sources.
- **Memory Interface**: Includes a Data Memory module for data storage and retrieval.

### Block Diagram

The block diagram of the system is shown below for better understanding of the architecture:

- **Pipeline**: Handles instruction execution in stages.
- **LSU (Load Store Unit)**: Manages memory accesses for load and store instructions.
- **Data Memory**: Stores data that can be accessed by load and store operations.
- **UART Register File**: Contains the control and status registers for the UART communication.
  - **DataReg**: Register for holding data to be transmitted or received.
  - **BaudDiv**: Baud rate divisor for setting the communication speed.
  - **Control**: Control register for managing UART operation.
  - **Rx_Data**: Register for storing received data.
  - **IE (Interrupt Enable)**: Register for enabling interrupts.
  - **IP (Interrupt Pending)**: Register for tracking pending interrupts.
- **Write-Back**: Handles the write-back of results from the pipeline to the register file.


### Getting Started

#### Prerequisites

- **Verilog Simulator**: Any simulator that supports SystemVerilog for running and testing the processor, such as ModelSim, Questa, or Xilinx Vivado.
- **RISC-V Toolchain**: To compile and generate machine code for testing the processor.

#### Cloning the Repository

To clone this repository, run:

```sh
git clone https://github.com/yourusername/riscv-32bit-processor.git



