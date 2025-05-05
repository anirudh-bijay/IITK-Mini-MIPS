import argparse
from enum import Enum
import sys

def parse_args():
    """
    Parse command line arguments.
    """

    # Instantiate the argument parser
    parser = argparse.ArgumentParser(
        description='Convert a program written in IITK-Mini-MIPS assembly '
            'language to machine code.',
    )

    # Take a mandatory file argument
    parser.add_argument('file', type=str, help='the assembly file')

    # Add an optional output file argument
    parser.add_argument('-o', '--output', type=str, help='the output file')
    
    # Add an optional coe flag
    parser.add_argument('-coe', '--coe', action='store_true',
                        help='generate a .coe file to load into the instruction memory')
    
    return parser.parse_args()

def parse_instruction(instruction: str) -> tuple[str, list[str]]:
    """
    Parse a single assembly instruction into its components.
    """

    instruction = instruction.lower()  # Convert to lowercase

    operands = [x.strip() for x in instruction.split(',')]  # Split arguments by commas
    if operands == ['']:
        raise ValueError("Empty instruction")

    _ = operands[0].split()  # Split the first argument by spaces to extract opcode and first operand
    op = _[0].rstrip()  # Get the operation (first word)

    if len(_) == 2:
        # An argument exists
        operands[0] = _[1].lstrip()
    elif len(_) == 1:
        # No argument exists
        operands = []
    else:
        # Incorrect format
        raise ValueError("Incorrect instruction format")
    
    return op, operands

def to_machine_code(instruction: str) -> str:
    """
    Convert a single assembly instruction to machine code.
    """

    Field = Enum('Field', 'RS RT RD SHAMT IMM LABEL ADDR FS FT FD CC')

    RS, RT, RD, SHAMT, IMM, LABEL, ADDR, FS, FT, FD, CC = Field.RS, Field.RT, Field.RD, Field.SHAMT, Field.IMM, Field.LABEL, Field.ADDR, Field.FS, Field.FT, Field.FD, Field.CC
    
    opcode_map = {
        'nop'   : (0x00,),                  # Pseudoinstruction
        'add'   : (0x00, RD, RS, RT),       # R-type
        'sub'   : (0x00, RD, RS, RT),       # R-type
        'addu'  : (0x00, RD, RS, RT),       # R-type
        'subu'  : (0x00, RD, RS, RT),       # R-type
        'madd'  : (0x1c, RD, RS, RT),       # R-type
        'maddu' : (0x1c, RD, RS, RT),       # R-type
        'mul'   : (0x00, RS, RT),           # R-type
        'and'   : (0x00, RD, RS, RT),       # R-type
        'or'    : (0x00, RD, RS, RT),       # R-type
        'not'   : (0x00, RD, RT),           # R-type
        'xor'   : (0x00, RD, RS, RT),       # R-type
        'sll'   : (0x00, RD, RT, SHAMT),    # R-type
        'srl'   : (0x00, RD, RT, SHAMT),    # R-type
        'sla'   : (0x00, RD, RT, SHAMT),    # R-type
        'sra'   : (0x00, RD, RT, SHAMT),    # R-type
        'slt'   : (0x00, RD, RS, RT),       # R-type
        'jr'    : (0x00, RS),               # R-type
        'mfhi'  : (0x00, RD),               # R-type
        'mflo'  : (0x00, RD),               # R-type
        'addi'  : (0x08, RT, RS, IMM),      # I-type
        'addiu' : (0x09, RT, RS, IMM),      # I-type
        'andi'  : (0x0c, RT, RS, IMM),      # I-type
        'ori'   : (0x0d, RT, RS, IMM),      # I-type
        'xori'  : (0x0e, RT, RS, IMM),      # I-type
        'lw'    : (0x23, RT, ADDR),         # I-type
        'sw'    : (0x2b, RT, ADDR),         # I-type
        'lui'   : (0x0f, RT, IMM),          # I-type
        'beq'   : (0x04, RS, RT, IMM),      # I-type
        'bne'   : (0x05, RS, RT, IMM),      # I-type
        'bgt'   : (0x07, RS, RT, IMM),      # I-type
        'bgte'  : (0x01, RS, RT, IMM),      # I-type
        'ble'   : (0x01, RT, RS, IMM),      # I-type
        'bleq'  : (0x07, RT, RS, IMM),      # I-type
        'bleu'  : (0x16, RS, RT, IMM),      # I-type
        'bgtu'  : (0x17, RS, RT, IMM),      # I-type
        'slti'  : (0x0a, RS, RT, IMM),      # I-type
        'seq'   : (0x18, RS, RT, IMM),      # I-type
        'j'     : (0x02, LABEL),            # J-type
        'jal'   : (0x03, LABEL),            # J-type
        'mfc1'  : (0x11, RT, FS),           # Coprocessor 1
        'mtc1'  : (0x11, RT, FS),           # Coprocessor 1
        'add.s' : (0x11, FD, FS, FT),       # Coprocessor 1
        'sub.s' : (0x11, FD, FS, FT),       # Coprocessor 1
        'c.eq.s': (0x11, CC, FS, FT),       # Coprocessor 1
        'c.le.s': (0x11, CC, FS, FT),       # Coprocessor 1
        'c.lt.s': (0x11, CC, FS, FT),       # Coprocessor 1
        'c.ge.s': (0x11, CC, FS, FT),       # Coprocessor 1
        'c.gt.s': (0x11, CC, FS, FT),       # Coprocessor 1 
        'mov.s' : (0x11, FD, FS),           # Coprocessor 1
    }

    funct_map = {
        'add'   : 0x20,       # R-type
        'sub'   : 0x22,       # R-type
        'addu'  : 0x21,       # R-type
        'subu'  : 0x23,       # R-type
        'madd'  : 0x00,       # R-type
        'maddu' : 0x01,       # R-type
        'mul'   : 0x18,       # R-type
        'and'   : 0x24,       # R-type
        'or'    : 0x25,       # R-type
        'not'   : 0x27,       # R-type
        'xor'   : 0x26,       # R-type
        'sll'   : 0x00,       # R-type
        'srl'   : 0x02,       # R-type
        'sla'   : 0x00,       # R-type
        'sra'   : 0x03,       # R-type
        'slt'   : 0x2a,       # R-type
        'jr'    : 0x08,       # R-type
        'mfhi'  : 0x10,       # R-type
        'mflo'  : 0x12,       # R-type
        'add.s' : 0x00,       # Coprocessor 1
        'sub.s' : 0x01,       # Coprocessor 1
        'c.eq.s': 0x32,       # Coprocessor 1
        'c.le.s': 0x3e,       # Coprocessor 1
        'c.lt.s': 0x3c,       # Coprocessor 1
        'c.ge.s': 0x28,       # Coprocessor 1
        'c.gt.s': 0x2a,       # Coprocessor 1
        'mov.s' : 0x06,       # Coprocessor 1
    }

    fmt_map = {
        'mfc1'  : 0x00,       # Coprocessor 1
        'mtc1'  : 0x04,       # Coprocessor 1
        'add.s' : 0x10,       # Coprocessor 1
        'sub.s' : 0x10,       # Coprocessor 1
        'c.eq.s': 0x10,       # Coprocessor 1
        'c.le.s': 0x10,       # Coprocessor 1
        'c.lt.s': 0x10,       # Coprocessor 1
        'c.ge.s': 0x10,       # Coprocessor 1
        'c.gt.s': 0x10,       # Coprocessor 1
        'mov.s' : 0x10,       # Coprocessor 1
    }

    op, operands = parse_instruction(instruction)

    binary_code = bin(opcode_map[op][0])[2:].zfill(6) + 26 * '0'  # Convert opcode to binary and pad with zeros

    if len(opcode_map[op]) != len(operands) + 1:
        raise ValueError("Incorrect number of operands")
    
    for i, operand in enumerate(operands):
        if opcode_map[op][i + 1] == RS or opcode_map[op][i + 1] == RT or opcode_map[op][i + 1] == RD:
            if operand[0] != '$':
                raise ValueError("Invalid register name")
            
            try:
                reg_num = int(operand[1:])  # Convert register name to number
            except ValueError:
                match operand[1:]:
                    case 'zero': reg_num = 0
                    case 'at': reg_num = 1
                    case 'v0': reg_num = 2
                    case 'v1': reg_num = 3
                    case 'a0': reg_num = 4
                    case 'a1': reg_num = 5
                    case 'a2': reg_num = 6
                    case 'a3': reg_num = 7
                    case 't0': reg_num = 8
                    case 't1': reg_num = 9
                    case 't2': reg_num = 10
                    case 't3': reg_num = 11
                    case 't4': reg_num = 12
                    case 't5': reg_num = 13
                    case 't6': reg_num = 14
                    case 't7': reg_num = 15
                    case 's0': reg_num = 16
                    case 's1': reg_num = 17
                    case 's2': reg_num = 18
                    case 's3': reg_num = 19
                    case 's4': reg_num = 20
                    case 's5': reg_num = 21
                    case 's6': reg_num = 22
                    case 's7': reg_num = 23
                    case 't8': reg_num = 24
                    case 't9': reg_num = 25
                    case 'k0': reg_num = 26
                    case 'k1': reg_num = 27
                    case 'gp': reg_num = 28
                    case 'sp': reg_num = 29
                    case 'fp': reg_num = 30
                    case 'ra': reg_num = 31
                    case _: raise ValueError("Invalid register name")

            if reg_num < 0 or reg_num > 31:
                raise ValueError("Invalid register number")
            
            match opcode_map[op][i + 1]:
                case Field.RS: binary_code = binary_code[:6] + bin(reg_num)[2:].zfill(5) + binary_code[11:]
                case Field.RT: binary_code = binary_code[:11] + bin(reg_num)[2:].zfill(5) + binary_code[16:]
                case Field.RD: binary_code = binary_code[:16] + bin(reg_num)[2:].zfill(5) + binary_code[21:]
        elif opcode_map[op][i + 1] == SHAMT:
            try:
                shamt = int(operand, base=0)  # Convert shift amount to number
            except ValueError:
                raise ValueError("Invalid shift amount")
            
            if shamt < 0 or shamt > 31:
                raise ValueError("Invalid shift amount")
            
            binary_code = binary_code[:21] + bin(shamt)[2:].zfill(5) + binary_code[26:]
        elif opcode_map[op][i + 1] == IMM:
            try:
                imm = int(operand, base=0)  # Convert immediate value to number
            except ValueError:
                raise ValueError("Invalid immediate value")
            
            if op in ['beq', 'bne', 'bgt', 'bgte', 'ble', 'bleq', 'bleu', 'bgtu']:
                binary_code = binary_code[:16] + bin((imm >> 2) & 0xffff)[2:].zfill(16)
            else:
                binary_code = binary_code[:16] + bin(imm & 0xffff)[2:].zfill(16)
        elif opcode_map[op][i + 1] == LABEL:
            # Convert label to address (dummy conversion for now)
            try:
                label_addr = int(operand, base=0)  # Convert label to address
            except ValueError:
                raise ValueError("Invalid label address")
            
            binary_code = binary_code[:6] + bin((label_addr >> 2) & 0x3ffffff)[2:].zfill(26)
        elif opcode_map[op][i + 1] == FS or opcode_map[op][i + 1] == FT or opcode_map[op][i + 1] == FD:
            if operand[0] != '$':
                raise ValueError("Invalid register name")
            
            try:
                reg_num = int(operand[1:])  # Convert register name to number
            except ValueError:
                if operand[1] != 'f':
                    raise ValueError("Invalid register name")
                
                try:
                    reg_num = int(operand[2:])  # Convert register name to number
                except ValueError:
                    raise ValueError("Invalid register name")

            if reg_num < 0 or reg_num > 31:
                raise ValueError("Invalid register number")
            
            match opcode_map[op][i + 1]:
                case Field.FT: binary_code = binary_code[:11] + bin(reg_num)[2:].zfill(5) + binary_code[16:]
                case Field.FS: binary_code = binary_code[:16] + bin(reg_num)[2:].zfill(5) + binary_code[21:]
                case Field.FD: binary_code = binary_code[:21] + bin(reg_num)[2:].zfill(5) + binary_code[26:]
        elif opcode_map[op][i + 1] == CC:
            try:
                flag_num = int(operand)  # Convert flag number to number
            except ValueError:
                raise ValueError("Invalid flag number")
            
            if flag_num < 0 or flag_num > 8:
                raise ValueError("Invalid flag number")
            
            binary_code = binary_code[:21] + bin(flag_num)[2:].zfill(3) + '00' + binary_code[26:]
        elif opcode_map[op][i + 1] == ADDR:
            _ = operand.split('(', maxsplit=1)

            if len(_) == 2:
                if not _[1].endswith(')'):
                    raise ValueError("Invalid address format")
                
                offset = int(_[0], base=0)  # Convert offset to number
                base = _[1][:-1].strip()  # Get base register name
            elif len(_) == 1:
                offset = 0  # Default offset is 0
                base = _[0]  # Get base register name
            else:
                raise ValueError("Invalid address format")

            if base[0] != '$':
                raise ValueError("Invalid register name")
            
            try:
                reg_num = int(base[1:])  # Convert register name to number
            except ValueError:
                match base[1:]:
                    case 'zero': reg_num = 0
                    case 'at': reg_num = 1
                    case 'v0': reg_num = 2
                    case 'v1': reg_num = 3
                    case 'a0': reg_num = 4
                    case 'a1': reg_num = 5
                    case 'a2': reg_num = 6
                    case 'a3': reg_num = 7
                    case 't0': reg_num = 8
                    case 't1': reg_num = 9
                    case 't2': reg_num = 10
                    case 't3': reg_num = 11
                    case 't4': reg_num = 12
                    case 't5': reg_num = 13
                    case 't6': reg_num = 14
                    case 't7': reg_num = 15
                    case 's0': reg_num = 16
                    case 's1': reg_num = 17
                    case 's2': reg_num = 18
                    case 's3': reg_num = 19
                    case 's4': reg_num = 20
                    case 's5': reg_num = 21
                    case 's6': reg_num = 22
                    case 's7': reg_num = 23
                    case 't8': reg_num = 24
                    case 't9': reg_num = 25
                    case 'k0': reg_num = 26
                    case 'k1': reg_num = 27
                    case 'gp': reg_num = 28
                    case 'sp': reg_num = 29
                    case 'fp': reg_num = 30
                    case 'ra': reg_num = 31
                    case _: raise ValueError("Invalid register name")

            if reg_num < 0 or reg_num > 31:
                raise ValueError("Invalid register number")
            
            binary_code = binary_code[:6] + bin(reg_num)[2:].zfill(5) + binary_code[11:16] + bin(offset & 0xffff)[2:].zfill(16)
        else:
            raise ValueError("Invalid operand type")
        
    if op in funct_map:
        binary_code = binary_code[:26] + bin(funct_map[op])[2:].zfill(6)

    if op in fmt_map:
        binary_code = binary_code[:6] + bin(fmt_map[op])[2:].zfill(5) + binary_code[11:]

    assert binary_code.count('1') + binary_code.count('0') == 32, "Binary code length is not 32 bits"

    return binary_code

def assemble(assembly_code: list[str]) -> list[str]:
    """
    Convert assembly code to machine code.
    """

    # Placeholder for the machine code
    machine_code: list[str] = []
    linenum = 0  # Line number for error reporting

    # Process each line of assembly code
    for line in assembly_code:
        linenum += 1
        linecopy = line.strip()  # Copy the line for error reporting

        # Strip comments
        line = line.split('#')[0]
        if not line or line.isspace():
            continue  # Skip empty lines

        try:
            # Convert the assembly instruction to machine code (dummy conversion)
            machine_code.append(to_machine_code(line))
        except Exception as e:
            print(f"Error in line {linenum}: {linecopy}", file=sys.stderr)
            raise

    return machine_code

def main():
    """
    Main function to run the program.
    """

    # Parse command line arguments
    args = parse_args()

    try:
        # Read the assembly file
        with open(args.file, 'r') as f:
            assembly_code = f.readlines()
    except FileNotFoundError:
        print(f"Error: File '{args.file}' not found.", file=sys.stderr)
    except IsADirectoryError:
        print(f"Error: '{args.file}' is a directory.", file=sys.stderr)
    except IOError as e:
        print(f"Error: An I/O error occurred: {e}", file=sys.stderr)

    # Process the assembly code
    machine_code = assemble(assembly_code)

    # Dump the machine code to the output file or stdout
    if args.output:
        try:
            with open(args.output, 'w') as f:
                if args.coe:
                    f.write(f'; {args.output}\n')
                    f.write(';\n')
                    f.write(f'; Assembly:\n')
                    f.write(';\n')
                    for line in assembly_code:
                        f.write(f'; {line}')
                    f.write('\n')
                    f.write('\n')
                    f.write('memory_initialization_radix=2;\n')
                    f.write('memory_initialization_vector=')

                for code in machine_code[:-1]:
                    f.write(code + '\n')

                if machine_code:
                    f.write(machine_code[-1])

                if args.coe:
                    f.write(';')
        except IOError as e:
            print(f"Error: An I/O error occurred: {e}", file=sys.stderr)
    else:
        if args.coe:
            print('memory_initialization_radix=2;')
            print('memory_initialization_vector=', end='')

        for code in machine_code[:-1]:
            print(code)
        if machine_code:
            print(machine_code[-1], end='')
        if args.coe:
            print(';')

if __name__ == '__main__':
    main()