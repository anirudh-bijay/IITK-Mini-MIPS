# Initial delay after power-on

nop                             # 0x00

# main
# -------------
# Entry point of the program

jal     0x3c                    # 0x04 | jal read_word
or      $a0, $zero, $v0         # 0x08
jal     0x1c                    # 0x0c | jal fact
or      $a0, $v0, $zero         # 0x10
jal     0x50                    # 0x14 | jal write_word
j       0x68                    # 0x18 | j exit

# fact
# -------------
# Computes the factorial of a whole number.
#
# PARAMETERS
#   - $a0: Number whose factorial to compute.
#
# RETURNS
#   - $v0: Factorial of the argument.
#
# NOTE
#   The argument passed should be small enough
#   that its factorial can be represented in
#   32 bits; else, the result will be incorrect.

addiu   $t0, $a0, -1            # 0x1c
beq     $t0, $zero, 0x10        # 0x20
mul     $a0, $t0                # 0x24
mflo    $a0                     # 0x28
addiu   $t0, $t0, -1            # 0x2c
j       0x20                    # 0x30
or      $v0, $a0, $zero         # 0x34
jr      $ra                     # 0x38

# read_word
# -------------
# Reads a 32-bit word from memory-mapped I/O.
#
# PARAMETERS
#   None.
#
# RETURNS
#   - $v0: 32-bit word read from input.

ori     $at, $zero, 512         # 0x3c
lw      $v0, 1($at)             # 0x40
beq     $v0, $zero, -0x8        # 0x44
lw      $v0, 0($at)             # 0x48
jr      $ra                     # 0x4c

# write_word
# -------------
# Writes a 32-bit word to memory-mapped I/O.
#
# PARAMETERS
#   - $a0: 32-bit word to write to output.
#
# RETURNS
#   None.

ori     $at, $zero, 512         # 0x50
sw      $a0, 2($at)             # 0x54
ori     $a0, $zero, 1           # 0x58
sw      $a0, 3($at)             # 0x5c
sw      $zero, 3($at)           # 0x60
jr      $ra                     # 0x64

# exit
# -------------
# Exits the program.
#
# PARAMETERS
#   None.
#
# RETURNS
#   None.
nop                             # 0x68