5-Stage Pipelined RISC-V CPU in SystemVerilog

## Features:

- Hazard detection
- Data forwarding
- Branch handling
- JAL support

## Features

- IF/ID/EX/MEM/WB pipeline
- Forwarding unit
- Hazard control unit
- Instruction memory via hex file
- testbench verification

## Usage

1. Open project in Vivado
2. Add files in `src/`
3. Add testbench from `tb/`
4. Add program hex file to simulation sources
5. Run simulation

## Expected register output after prog2.hex

x1 = 5  
x2 = 7  
x3 = 12  
x4 = 12  
x5 = 12  
x6 = 17

## Future work

- Floating point arithmetic
- further FGPA integration
- Super scalar pipeline
- Cache integration and Cache coherence
- Out of order Processing

By DeMarkus Taylor

