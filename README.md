# FalconRT — FPGA Graphics & Game System

FalconRT is a modular FPGA-based graphics and game system implemented in Verilog for the Intel MAX 10 platform. The project explores real-time video generation, sprite rendering, finite-state-machine control, digital timing, and hardware-driven game logic using synthesizable RTL.

The design is organized into independent modules for VGA timing, sprite storage, rendering, game-state control, clock management, color mapping, and top-level integration.

## Architecture

```text
+------------------+
|  Clock Divider   |
+--------+---------+
         |
         v
+------------------+
|  VGA Controller  |
| Timing / Sync    |
+--------+---------+
         |
         v
+------------------+
|  Game FSM        |
| State / Control  |
+--------+---------+
         |
         +--------------------------+
         |                          |
         v                          v
+------------------+       +------------------+
| Player Sprite ROM|       | Enemy Sprite ROM |
+--------+---------+       +--------+---------+
         |                          |
         +-------------+------------+
                       |
                       v
              +------------------+
              | Sprite Renderer  |
              +--------+---------+
                       |
                       v
              +------------------+
              |  Color Mapper    |
              +--------+---------+
                       |
                       v
              +------------------+
              | VGA Video Output |
              +------------------+
```

## Features

- FPGA-based real-time graphics generation
- Modular Verilog RTL architecture
- VGA timing and synchronization
- Player and enemy sprite ROMs
- Sprite rendering logic
- Finite-state-machine game control
- Hardware color mapping
- Clock division and timing control
- Seven-segment display support
- Intel MAX 10 FPGA targeting
- Fully hardware-driven graphics pipeline

## RTL Modules

| Module | Function |
| --- | --- |
| `falconrt_top.v` | Top-level system integration |
| `vga_controller.v` | Generates VGA timing and synchronization signals |
| `sprite_renderer.v` | Handles sprite positioning and pixel rendering |
| `player_sprite_rom.v` | Stores player sprite pixel data |
| `enemy_sprite_rom.v` | Stores enemy sprite pixel data |
| `game_fsm.v` | Implements game-state and control logic |
| `color_mapper.v` | Maps internal pixel information to display colors |
| `clock_divider.v` | Generates slower timing signals from the FPGA clock |
| `seven_segment_decoder.v` | Drives seven-segment display outputs |
| `falcon_register.v` | Stores game/system state |

## Engineering Focus

FalconRT was developed to strengthen practical understanding of:

- RTL design
- FPGA graphics pipelines
- Synchronous digital systems
- Video timing
- Finite-state machines
- Sprite-based rendering
- Modular hardware design
- Hardware debugging
- FPGA system integration

## Tools & Technologies

- Verilog HDL
- Intel Quartus Prime
- Intel MAX 10 FPGA
- RTL design
- Digital logic
- VGA graphics
- Finite-state machines
- Hardware timing and synchronization

## Repository Structure

```text
FalconRT/
├── background_renderer.v
├── clock_divider.v
├── color_mapper.v
├── enemy_sprite_rom.v
├── falcon_register.v
├── falconrt_top.v
├── game_fsm.v
├── player_sprite_rom.v
├── seven_segment_decoder.v
├── sprite_renderer.v
├── vga_controller.v
└── README.md
```

## Future Improvements

Potential extensions include:

- Additional game states and gameplay mechanics
- More sprite types and animation frames
- Collision detection enhancements
- Score tracking and display
- Audio output
- Controller/input integration
- Frame-buffer or memory-backed graphics
- Expanded simulation and automated verification
- FPGA timing and resource-utilization optimization

## What I Learned

This project strengthened my understanding of real-time digital graphics, hardware timing, modular RTL design, finite-state-machine control, sprite rendering, and FPGA-based system integration.

It also provided hands-on experience designing hardware where graphics generation and game behavior are implemented directly in RTL rather than software.

---

**Author:** Aditya Namdev  
Computer Engineering — Virginia Tech
