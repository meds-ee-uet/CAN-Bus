<div align="center">
  <img src="./docs/images_design/meds.jpg" width="150" height="150">
</div>

<h1 align="center">CAN BUS IP CORE</h1>

<p align="center">
  <b>A hardware module that implements the Controller Area Network  protocol for reliable serial communication between multiple devices in embedded systems.</b>
</p>

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

## Getting Started

###  1️⃣ Clone the repository

```bash
git clone https://github.com/meds-ee-uet/CAN-Bus.git
cd CAN_Bus
```
### 2️⃣ Open QuestaSim and set up the working library
```bash
vlib work
vmap work work
```

### 3️⃣ Compile all RTL and testbench files
```
vlog src/*.sv tb/tb_top.sv
```
### 4️⃣ Run the simulation
```
vsim work.tb_top -do "run -all"
```

### 5️⃣ (Optional) View waveforms
```
add wave *
run -all
```
---

## Full Documentation

For detailed module descriptions, timing diagrams, and verification results, visit:

**[Full Documentation on ReadTheDocs](https://ip-can-bus.readthedocs.io/en/latest/)**

---