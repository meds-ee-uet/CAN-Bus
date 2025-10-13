# Installation/User Guide

© 2025 **Maktab-e-Digital Systems Lahore**  
Licensed under the [Apache 2.0 License](https://www.google.com/search?q=LICENSE)

---



This document provides step-by-step instructions to set up, compile, and simulate the **CAN Bus Controller IP Core** project using **QuestaSim**.  
The entire project is implemented in **SystemVerilog**, including all submodules and testbenches.

---

##  **1.Prerequisites**

Before starting, make sure your system meets the following requirements.

#### **Software Requirements**
- **Operating System:** Windows 10+ / Ubuntu 20.04+
- **Mentor QuestaSim** (preferred version 2021.1 or later)
- **SystemVerilog Support** enabled
- **Git** (for version control)
- **Text Editor/IDE:** VS Code, Sublime, or Questa built-in editor

#### **Download link for QuestaSim:**
[QuesataSim Download Page](https://getintopc.com/softwares/simulators/mentor-graphics-questasim-2024-free-download/)

#### You can also use **EDA Playground** to simulate your SystemVerilog files online without local installation: 
 [EDA Playground](https://www.edaplayground.com/)

---

##  **2. Setting Up QuestaSim**

Follow these steps to prepare your simulation environment.

##### **Step 1: Launch QuestaSim**
- Open QuestaSim from your system applications or terminal.  
- In the QuestaSim GUI, go to:  
  `File → New → Project`
- Give your project a name (e.g., `CAN_Project`) and choose a working directory.

---

##### **Step 2: Add Source Files**
- Add all `.sv` files from the `src/` folder.  
- Add the top-level testbench file `can_top_tb.sv` from the `testbench/` folder.  
- Ensure that **`can_top.sv`** is set as the **design’s top module**.

---

##  **3. Compile the Design**

Open the **Transcript Window** and run the following commands:

```
vlib work
vlog ../src/*.sv
vlog ../testbench/can_top_tb.sv
```
**Explanation:**

- `vlib work` — Creates a working library.
- `vlog` — Compiles all SystemVerilog source and testbench files.

If compilation is successful, no errors should appear in the transcript.

##  **4. Run the Simulation**

After successful compilation, start the simulation using:

```
vsim work.can_top_tb
```
Then, to view signals and execute the simulation:

```
add wave *
run -all
```

##  **5. Simulation Verification**

The top-level module integrates all submodules (transmitter, receiver, bit timing, CRC, error handling).  
Simulation confirms correct CAN frame transmission, reception, timing, and CRC/error handling.

---
##  **6. Troubleshooting**

| Issue                       | Cause                                | Solution                             |
|------------------------------|--------------------------------------|-------------------------------------|
| Compilation errors           | Missing `.sv` files or wrong path   | Verify all source files are added   |
| Signals not visible          | Not added to waveform                | Use `add wave *`                     |
| Simulation hangs             | Clock or reset not applied           | Check testbench logic               |
| CRC mismatch                 | Incorrect CRC implementation         | Review polynomial & bit order       |

---


Licensed under the **Apache License 2.0**
Copyright © 2025
**[Maktab-e-Digital Systems Lahore](https://github.com/meds-ee-uet)**

---
