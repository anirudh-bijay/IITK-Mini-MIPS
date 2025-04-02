# IITK-Mini-MIPS

## Architecture

## Design and Constraints

## Instructions

## Components

### Instruction Memory

The instruction memory has a word size of exactly 32 bits. The implementation
uses a simple dual port distributed RAM for the instruction memory.

![Instruction memory schematic](instruction_memory_schematic.png)

### Register File

The register file contains 32 general-purpose registers of width 32 bits each.
The registers are labelled `$0` through `$31`, and their respective addresses
in the implementation are 0 through 31. Register `$0` is hardwired to zero;
writes to it are discarded.

The schematic can be viewed [here](register_file_schematic.pdf).

Although the schematic displays a dummy register for register `$0`, only
writes are performed to it. The output corresponding to 0 for the mux select
is hardwired to ground; as such, the register has no meaningful role and
should ideally be optimised out.