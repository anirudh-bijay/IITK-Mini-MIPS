# IITK-Mini-MIPS

IITK-Mini-MIPS is an extended and slightly modified version of the MIPS instruction set
architecture. IITK-Mini-MIPS assumes a Harvard architecture with the word size and
instruction width both fixed at 32 bits. The architecture mandates 32 general-purpose
registers and a floating point coprocessor with 32 floating point registers and support
for addition, subtraction, and comparisons.

Here, we design the microarchitecture of a single-cycle processor implementing the ISA
in Verilog. The target device is the AUP PYNQ-Z2.

## Building the project

The Verilog source files can be found under [`src`](src), while IPs can be found under
[`ip`](ip). The project can be built in Vivado by setting `origin_dir` to the root
directory of the cloned repository in the Tcl shell and then running the Tcl script
[`rebuild.tcl`](rebuild.tcl).
