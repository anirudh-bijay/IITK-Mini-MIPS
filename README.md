# IITK Mini-MIPS

IITK Mini-MIPS is an extended and slightly modified version of the MIPS instruction set
architecture. IITK-Mini-MIPS assumes a Harvard architecture with the word size and
instruction width both fixed at 32 bits. The architecture mandates 32 general-purpose
registers and a floating point coprocessor with 32 floating point registers and support
for addition, subtraction, and comparisons.

Here, we design the microarchitecture of a single-cycle processor implementing the ISA
in Verilog. The AMD Vivado™ Design Suite was used to implement the design and test it
on a PYNQ-Z2 FPGA development board.

This project is undertaken in partial fulfilment of the requirements of the course
[CS220: Computer Organisation](https://www.cse.iitk.ac.in/pages/CS220.html) offered at
IIT Kanpur in Winter 2025 instructed by
[Prof. Debapriya Basu Roy](https://www.cse.iitk.ac.in/users/dbroy).

## Building the Project

You will need the [AMD Vivado™ Design Suite](https://www.amd.com/en/products/software/adaptive-socs-and-fpgas/vivado.html)
to build the project.

To build, simply add all files under the [`src`](src) and [`ip`](ip)
directories into a new Vivado project.

> If, on adding the files, the IPs show up as 'locked', right-click on each
  locked IP in the *Sources* tab and select 'Upgrade IP'.

## Usage Instructions

To run a program:

1. Use the [assembler](assembler.py) to generate a COE file
    using the following command:

    ```powershell
    python assembler.py INPUT_FILE -o OUTPUT_FILE -coe
    ```

    Note that you need Python 3.11 or above installed to run the assembler.

    The output file must be placed in the folder
    [`ip/simple_dual_port_distributed_ram_0`](ip/simple_dual_port_distributed_ram_0)
    and should have a `.coe` file extension. For help on the assembler,
    invoke it with the `--help` (`-h`) flag.

    ```powershell
    python assembler.py -h
    ```

    #### Example

    [`factorial.s`](factorial.s) contains an example assembly program that
    computes the factorial of a whole number. It demonstrates jumps using
    absolute addresses, branches using PC-relative offsets, and read-write
    operations on memory-mapped I/O using polling.

    ```powershell
    python assembler.py factorial.s -o ip/simple_dual_port_distributed_ram_0/factorial.coe -coe
    ```
    
    > The `.coe` file places the instructions in your program in the
    instruction memory sequentially starting from address `0x0`. Jump
    addresses in the assembly program should take this into account.

2. In Vivado, right-click on `simple_dual_port_distributed_ram_0` in the
    *Sources* tab and select 'Re-customize IP'.

3. In the window that opens, go to the *RST & Initialization* tab and select
    the previously generated `.coe` file as the coefficients file. Click 'OK'
    to save your changes and regenerate the IP output products.

4. For simulation as well as for running on an FPGA, the processor's `clk`
    input must be connected to a clock source and its `rst` signal must be
    asserted at the start. Thereafter, `rst` should be deasserted; execution
    then starts from the first instruction in your program, loaded at address
    `0x0`.