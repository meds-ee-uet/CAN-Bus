# Home
> © 2025 [Maktab-e-Digital Systems Lahore](https://github.com/meds-ee-uet)  
> Licensed under the Apache 2.0 License.

##  Overview
A hardware module that implements the Controller Area Network  protocol for reliable serial communication between multiple devices in embedded systems.

## Top-Level Block Diagram

<p align="center">
  <img src="./docs/images_design/top_module.jpg" 
   alt="Top-Level Architecture" width="600">
</p>

---

## Key Features

- CAN 2.0A/B compliant – Supports standard (11-bit) and extended (29-bit) frames.

- Multi-master communication with non-destructive arbitration.

- Accurate bit timing with programmable synchronization segments.

- Comprehensive error detection – bit, stuff, form, ACK, and CRC errors.

- Priority and filtering module – Ensures high-priority messages are transmitted first and unwanted frames are ignored.

- Automatic error handling with active, passive, and bus-off states.

- Built-in CRC generation and checking for data integrity.

- Modular design – transmitter, receiver, bit timing, CRC, and error units.

- ACK slot handling and bit stuffing/destuffing support.

## 🧩 Project Structure
CAB-Bus/

│
├── docs/ # Project documentation files
│ ├── introduction.md 
│ ├── architecture.md 
│ ├── modules/ 
│ │ ├── transmitter.md
│ │ ├── receiver.md
│ │ ├── bit_timing.md
│ │ ├── crc_module.md
│ │ └── error_handler.md
│ └── verification_plan.md 
├── rtl/ # SystemVerilog source code
│ ├── can_top_module.sv 
│ ├── can_transmitter.sv
│ ├── can_receiver.sv
│ ├── can_timing.sv
│ ├── can_crc.sv
│ └── can_error_handling.sv
│ └── can_arbitartion.sv
│ └── can_filtering.sv
│ └── can_tx_priorty.sv
│
├── tb/ # Testbench and verification 
│ ├── tb_can_top.sv 
│ ├── tb_can_transmitter.sv
│ ├── tb_can_receiver.sv
│ ├── tb_can_timing.sv
│ ├── tb_can_error_handler.sv
│ ├── tb_can_arbitration.sv
│ ├── tb_can_filtering.sv
│ ├── tb_can_tx_priorty.sv
│
├── README.md

## Licensing

Licensed under the **Apache License 2.0**
Copyright © 2025
**[Maktab-e-Digital Systems Lahore](https://github.com/meds-ee-uet)**

---