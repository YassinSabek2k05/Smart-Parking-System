# 🅿️ Smart Parking System (FPGA & Arduino Integration)

## 📺 Demo Video

Watch the smart parking system in action:
- **[Smart Parking System Demo](Part2/Demo_Videos/Smart%20Parking%20System.mp4)** - Full system demonstration
- **[Simulation Video](Part2/Demo_Videos/Simulation_Video.mp4)** - VHDL simulation waveforms

---

## Project Overview

This project implements a fully functional **Smart Parking System** designed to manage vehicle traffic in a small, 8-spot garage. The system utilizes an Intel MAX 10 FPGA (DE10-Lite) as the core control unit, integrating sensor inputs, actuator control, and a critical **Fire Safety Override** protocol handled by an external Arduino Mega.

The system features three distinct operational modes: Autonomous, Manual, and Hazard Response.

### Key Features

  * **Capacity Management:** Strictly maintains the count of available spots (capacity 8), preventing overflow.
  * **Sensor Debouncing:** VHDL-based FSM logic eliminates signal bouncing and jitter from IR sensors.
  * **Hazard Override:** Immediate, failsafe gate opening and buzzer activation upon smoke detection, overriding all normal parking operations.
  * **Voltage Safety:** Implements a voltage divider circuit to safely interface the 5V Arduino output with the 3.3V FPGA inputs.

-----

## 🛠️ Hardware & Architecture

The system uses a mixed-logic architecture where the FPGA handles fast, synchronous control (the FSM), and the Arduino handles slow, analog sensor processing.

### Core Components

| Component | Function | Notes |
| :--- | :--- | :--- |
| **FPGA Board** | Terasic DE10-Lite (Intel MAX 10) | Core logic control and counter management. |
| **Microcontroller** | Arduino Mega 2560 | Dedicated to analog reading of the MQ-2 Gas Sensor. |
| **Actuator** | Servo Motor (SG90) | Controls the entry/exit gate. |
| **Sensors** | 2 x IR Obstacle Sensors | Detect vehicle presence and sequence (entry/exit). |
| **Safety Sensor** | MQ-2 Gas/Smoke Sensor | Monitors air quality for emergency detection. |

### Circuit Integration: Voltage Divider

To protect the FPGA's 3.3V GPIO pins from the Arduino's 5V logic, a **Voltage Divider circuit** (using $10\text{k}\Omega / 20\text{k}\Omega$ resistors) was implemented on the communication line to step down the signal voltage.

-----

## 🧠 Implementation Details

### 1\. VHDL Finite State Machine (Autonomous Mode)

The core vehicle detection and gate sequencing are managed by an FSM designed to handle the two IR sensors. The FSM ensures the available spot counter is only updated after a sequence is **fully confirmed**, preventing errors from partial passes.

| State | Condition | Action / Purpose |
| :--- | :--- | :--- |
| **WAITING** | Gate remains closed. | Waits for the **outer sensor** to trigger (entry). |
| **ENTERING** | Outer sensor detects car ($01$). | Gate opens. Waits for the car to clear the inner sensor ($10$). |
| **EXITING** | Inner sensor detects car ($10$). | Gate opens. Waits for the car to clear the outer sensor ($01$). |
| **WAIT\_FOR\_CLEAR** | Any sensor is blocked ($01$, $10$, or $00$). | Safety state that holds the gate open, preventing accidental closure on a vehicle. |

### 2\. Manual Control Logic

Manual control is handled via a push-button toggle with built-in safety features:

  * **Debouncing:** A $50\text{ms}$ software debouncer filters the button input.
  * **Capacity Lockout:** The system checks `if parking > 0` (i.e., not full) before allowing the manual gate open command. If the lot is full, the gate remains locked.

### 3\. Hazard Response (Fire Safety Override)

This protocol ensures system stability and safety during an emergency:

1.  **Detection:** Arduino continuously monitors the MQ-2 sensor.
2.  **Trigger:** If smoke levels exceed the threshold ($\mathbf{300}$), the Arduino sends a Logic High ('1') signal to the FPGA.
3.  **Override:** The FPGA immediately **overrides all existing FSM states** and forces the gate open.
4.  **Notification:** The **Buzzer activates**.
5.  **Stability:** The Arduino firmware includes a 3-second latch to ensure the gate remains open even during brief, fluctuating smoke readings.

-----

## 📂 Project Structure

```
Smart Parking System/
├── README.md                          # Project documentation
├── Part1/                             # Digital clock design (preliminary exercise)
│   ├── digital_clock.vhd             # VHDL source for digital clock
│   ├── tb_digital_clock.vhd          # Testbench for digital clock
│   └── simulation_waveform.pdf       # Simulation waveform results
│
└── Part2/                             # Smart Parking System (main project)
    ├── Project_Report.pdf            # Complete project documentation
    ├── Pin_Assignments.csv           # FPGA pin configuration
    ├── Pin_Assignments.xlsx          # FPGA pin configuration (Excel)
    ├── Demo_Videos/                  # System demonstrations
    │   ├── Smart Parking System.mp4  # Full system demo
    │   └── Simulation_Video.mp4      # VHDL simulation video
    └── source_code/                  # Implementation files
        ├── smartparking.vhd          # Main FPGA VHDL code (FSM & logic)
        ├── seg7_0to8_only.vhd        # 7-segment display driver
        └── smokesensor.ino           # Arduino sketch for smoke sensor monitoring
```

### File Descriptions

#### Part1: Digital Clock
- **digital_clock.vhd** - Implements a digital clock counter in VHDL
- **tb_digital_clock.vhd** - Testbench for verification and simulation
- **simulation_waveform.pdf** - Results from simulation showing correct behavior

#### Part2: Smart Parking System
- **smartparking.vhd** - Core FPGA implementation containing the FSM, debouncer, and control logic
- **seg7_0to8_only.vhd** - Driver for 7-segment LED display (shows available parking spots)
- **smokesensor.ino** - Arduino firmware for reading the MQ-2 smoke/gas sensor and communicating hazard status to FPGA
- **Pin_Assignments** - Maps VHDL signals to physical FPGA pins on the DE10-Lite board
- **Project_Report.pdf** - Full technical report with circuit diagrams, timing analysis, and design rationale

-----

## 🔗 Contact & Resources

This project was developed using components sourced from TECH HUB.

**TECH HUB**

  * **Location:** THREE TOWERS MALL (TAGAMOAA 1 INFRONT OF REHAB GATE 21)
  * **Phone:** 01070739598
  * **Email:** INFO@TECH-HUBEG.COM
