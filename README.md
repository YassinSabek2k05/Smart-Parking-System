# 🅿️ Smart Parking System (FPGA & Arduino Integration)

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

## 📂 Repository Structure

```
smart_parking_system/
├── src/
│   ├── VHDL/              # FPGA VHDL source files (FSM, Top Level, Debouncer)
│   ├── Arduino/           # Arduino sketch (.ino) for sensor monitoring/threshold
├── doc/
│   └── project_report.pdf # Full project documentation
├── test/
│   └── simulation_waveforms.vhd
└── README.md
```

-----

## 🔗 Contact & Resources

This project was developed using components sourced from TECH HUB.

**TECH HUB**

  * **Location:** THREE TOWERS MALL (TAGAMOAA 1 INFRONT OF REHAB GATE 21)
  * **Phone:** 01070739598
  * **Email:** INFO@TECH-HUBEG.COM
