# Theory of Operation — CAN Controller

A detailed, implementation-focused explanation of Controller Area Network (CAN) core architecture, protocol, and data flow. Suitable for documentation in reports and  README files.

## 1. Overview

Controller Area Network (CAN) is a multi-master, message-oriented serial bus protocol originally developed for automotive applications (Bosch) and standardized as ISO 11898. It provides robust, prioritized, and deterministic message delivery for real-time control systems. This document explains the CAN protocol variants (2.0A/2.0B / ISO 11898-1), the core controller architecture used in hardware (FPGA/ASIC/MCU CAN IP), and the typical data flow for transmission and reception, including error handling and timing considerations

---

### Top-Level Block Diagram

<p align="center">
  <img src="./images_design/top_module.jpg" 
   alt="Top-Level Architecture" width="600">
</p>

---

## 2. Key Concepts & Terminology

- Node: Any device connected to the CAN bus (microcontroller, sensor, actuator, gateway).

- Dominant/Recessive: Logical levels on the bus — Dominant (logical '0') overrides Recessive (logical '1').

- Bitwise arbitration: Conflict resolution method where lower identifier (more dominant bits) wins.

- Frame types: Data Frame, Remote Frame, Error Frame, Overload Frame.

- Standard vs Extended frame: Standard uses 11-bit identifier (CAN 2.0A), Extended uses 29-bit identifier (CAN 2.0B).

- ACK: Acknowledge field — receivers assert a dominant bit to indicate successful reception.

- Bit stuffing: Insert a complementary bit after five consecutive identical bits to maintain synchronization.

- CRC: Cyclic Redundancy Check used for error detection (15-bit for classical CAN).

## Protocol Summary (CAN 2.0A / 2.0B & ISO 11898-1)

- Physical layer: Two-wire differential bus (CAN_H, CAN_L) implemented by a transceiver; physical termination resistors required at both ends.

- Bit rates: Common rates: 10 kbit/s — 1 Mbit/s for classical CAN (higher for CAN FD). Specific timing defined by bit time segments (SYNC, PROP, PHASE1, PHASE2).

- Message-oriented: Data carried in frames; arbitration by identifier (priority).

- Deterministic arbitration: Message with lowest numeric identifier wins arbitration.

## 4. CAN Frame Structures (classical CAN)
### 4.1 Data Frame (standard format — 11-bit ID)
