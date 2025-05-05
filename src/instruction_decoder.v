`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Kanpur
// Engineer: Anirudh Cheriyachanaseri Bijay
// 
// Create Date: 30.03.2025 22:23:03
// Design Name: 
// Module Name: instruction_decoder
// Project Name: IITK-Mini-MIPS
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module instruction_decoder #(
    // Opcodes
    parameter R_TYPE    = 6'h0,
    parameter MADD_OP   = 6'h1c,
    parameter MADDU_OP  = 6'h1c,
    parameter ADDI      = 6'h8,
    parameter ADDIU     = 6'h9,
    parameter ANDI      = 6'hc,
    parameter ORI       = 6'hd,
    parameter XORI      = 6'he,
    parameter LW        = 6'h23,
    parameter SW        = 6'h2b,
    parameter LUI       = 6'hf,
    parameter BEQ       = 6'h4,
    parameter BNE       = 6'h5,
    parameter BGT       = 6'h7,
    parameter BGTE      = 6'h1,
    parameter BLE       = 6'h1,
    parameter BLEQ      = 6'h7,
    parameter BLEU      = 6'h16,
    parameter BGTU      = 6'h17,
    parameter SLTI      = 6'ha,
    parameter SEQ       = 6'h18,
    parameter J         = 6'h2,
    parameter JAL       = 6'h3,
    parameter CP1       = 6'h11,
    // Functions
    parameter ADD       = 6'h20,
    parameter SUB       = 6'h22,
    parameter ADDU      = 6'h21,
    parameter SUBU      = 6'h23,
    parameter MADD      = 6'h0,
    parameter MADDU     = 6'h1,
    parameter MUL       = 6'h18,
    parameter AND       = 6'h24,
    parameter OR        = 6'h25,
    parameter NOT       = 6'h27,
    parameter XOR       = 6'h26,
    parameter SLL       = 6'h0,
    parameter SRL       = 6'h2,
    parameter SLA       = SLL,
    parameter SRA       = 6'h3,
    parameter SLT       = 6'h2a,
    parameter JR        = 6'h8,
    parameter MFHI      = 6'h10,
    parameter MFLO      = 6'h12,
    // ALU opcodes
    parameter ALU_ADD = 5'h0,
    parameter ALU_SUB = 5'h10,
    parameter ALU_AND = 5'h1,
    parameter ALU_OR  = 5'h2,
    parameter ALU_NOT = 5'h3,
    parameter ALU_XOR = 5'h4,
    parameter ALU_SLL = 5'h5,
    parameter ALU_SRL = 5'h6,
    parameter ALU_SRA = 5'h7,
    parameter ALU_EQ  = 5'h8,
    parameter ALU_NE  = 5'h9,
    parameter ALU_LT  = 5'ha,
    parameter ALU_GT  = 5'hb,
    parameter ALU_LE  = 5'hc,
    parameter ALU_GE  = 5'hd,
    parameter ALU_LTU = 5'he,
    parameter ALU_GTU = 5'hf,
    // Multiply unit opcodes
    parameter MUL_MADD  = 3'b000,
    parameter MUL_MADDU = 3'b001,
    parameter MUL_MUL   = 3'b010,
    parameter MUL_MFHI  = 3'b101,
    parameter MUL_MFLO  = 3'b100
)(
    input [5:0] opcode,
    input [5:0] funct,
    
    // If link is high, then the input to the register is as described below.
    // Else, if needs_three_regs is high, then inst[15:11] is input to the
    // register file's write destination address.
    // Else, inst[20:16] is input to the register file's write destination
    // address.
    output reg needs_three_regs,
    
    // If jump is high, then the program counter is updated with the jump
    // address, computed based on the jump_reg signal below.
    // Else, the program counter is either incremented or updated with the
    // address computed from the branch offset, depending on the branch
    // signal below.
    output reg jump,
    
    // If jump_reg is high, then the jump address is loaded from a register.
    // Else, it is loaded from inst[25:0].
    output reg jump_reg,
    
    // If load is high, then the register file's write input is supplied with
    // data read from the data memory.
    // Else, it is supplied with the ALU's result or the incremented program
    // counter, depending on the link signal below.
    output reg load,
    
    // If store is high, then the data memory's write enable is asserted.
    // Else, it is deasserted.
    output reg store,
    
    // If link is high, then:
    //   - if load is low, the register file's write input is supplied
    //       with the incremented program counter.
    //       Else, the behaviour is as described above.
    //   - 31 (address of $ra) is input to the register
    //       file's write destination address.
    // 
    // Else,
    //   - if load is low, the register file's write input is supplied
    //       with the ALU's result.
    //       Else, the behaviour is as described above.
    //   - the input to the register file's write destination address is
    //       determined by the need_three_regs signal.
    output reg link,
    
    // Function code for ALU
    output reg [5:0] alu_op,
    
    // If alu_imm is high, the second operand of the ALU is sourced from
    // inst[15:0].
    // Else, it is sourced from the data available at read port 2 of the
    // register file.
    output reg alu_imm,
    
    // If shift_imm is high, the first operand of the ALU is sourced from
    // {11'bx, inst[10:6]}.
    // Else, the behaviour is determined by the load_upper signal.
    output reg shift_imm,
    
    // If shift_imm is high, the behaviour is as described above.
    // If shift_imm is low and load_upper is high, the first operand of the
    // ALU is 16 (in decimal).
    // Else, the first operand of the ALU is sourced from the data available
    // at read port 1 of the register file.
    output reg load_upper,
    
    // If branch is high, the program counter is updated with the computed
    // branch destination address if the ALU output is zero.
    output reg branch,
    
    // If write_to_register is high, the register file's write enable is
    // asserted.
    // Else, it is deasserted.
    output reg write_to_register,
    
    // If load_from_hi_lo is high, the second operand of the ALU is sourced
    // from the output of the multiply unit.
    output reg load_from_hi_lo,
    
    // Function code for multiply unit
    output reg [2:0] mul_op,
    
    // 
    output reg from_cp1,
    
    //
    output reg has_overflow
);
    always @* begin
        // needs_three_regs
        case (opcode)
            R_TYPE: needs_three_regs <= 1;
            default: needs_three_regs <= 0;
        endcase
        
        // jump
        case (opcode)
            J, JAL: jump <= 1;
            R_TYPE:
                case (funct)
                    JR: jump <= 1;
                    default: jump <= 0;
                endcase
                
            default: jump <= 0;
        endcase
        
        // jump_reg
        case (opcode)
            R_TYPE: jump_reg <= 1;
            default: jump_reg <= jump ? 0 : 1'bx;
        endcase
        
        // load
        case (opcode)
            LW: load <= 1;
            default: load <= 0;
            // NOTE: lui is not a load instruction in the sense of the load
            //       signal as defined above. While lw loads data from the
            //       memory, lui simply performs a left shift and writes the
            //       result to the destination register.
        endcase
        
        // store
        case (opcode)
            SW: store <= 1;
            default: store <= 0;
        endcase
        
        // link
        case (opcode)
            JAL: link <= 1;
            default: link <= 0;
        endcase
        
        // alu_op
        case (opcode)
            ADDI, ADDIU, LW, SW: alu_op <= ALU_ADD;
            ANDI: alu_op <= ALU_AND;
            ORI: alu_op <= ALU_OR;
            XORI: alu_op <= ALU_XOR;
            LUI: alu_op <= ALU_SLL;
            SEQ, BEQ: alu_op <= ALU_EQ;
            BNE: alu_op <= ALU_NE;
            BGT: alu_op <= ALU_GT;
            BGTE: alu_op <= ALU_GE;
            SLTI, BLE: alu_op <= ALU_LT;
            BLEQ: alu_op <= ALU_LE;
            BLEU: alu_op <= ALU_LTU;
            BGTU: alu_op <= ALU_GTU;
            R_TYPE:
                case (funct)
                    ADD, ADDU: alu_op <= ALU_ADD;
                    SUB, SUBU: alu_op <= ALU_SUB;
                    AND: alu_op <= ALU_AND;
                    OR: alu_op <= ALU_OR;
                    NOT: alu_op <= ALU_NOT;
                    XOR: alu_op <= ALU_XOR;
                    SLL, SLA: alu_op <= ALU_SLL;
                    SRL: alu_op <= ALU_SRL;
                    SRA: alu_op <= ALU_SRA;
                    SLT: alu_op <= ALU_LT;
                    MFHI, MFLO: alu_op <= ALU_OR;
                    default: alu_op <= 5'bx;
                endcase
            default: alu_op <= 5'bx;
        endcase
        
        // alu_imm
        case (opcode)
            R_TYPE: alu_imm <= 0;
            default: alu_imm <= !branch;
        endcase
        
        // shift_imm
        case (opcode)
            R_TYPE:
                case (funct)
                    SLL, SLA, SRL, SRA: shift_imm <= 1;
                    default: shift_imm <= 0;
                endcase
                
            default: shift_imm <= 0;
        endcase
        
        // load_upper
        case (opcode)
            LUI: load_upper <= 1;
            default: load_upper <= 0;
        endcase
        
        // branch
        case (opcode)
            BEQ, BNE, BGT, BGTE, BLE, BLEQ, BLEU, BGTU: branch <= 1;
            default: branch <= 0;
        endcase
        
        // write_to_register
        write_to_register <= !(branch || store || (jump && !(jump_reg || link)));
        
        // load_from_hi_lo
        case (opcode)
            R_TYPE:
                case (funct)
                    MFHI, MFLO: load_from_hi_lo <= 1;
                    JR, MUL: load_from_hi_lo <= 1'bx;
                    default: load_from_hi_lo <= 0;
                endcase
            default: load_from_hi_lo <= 0;
        endcase
        
        // mul_op
        case (opcode)
            MADD_OP, MADDU_OP:
                case (funct)
                    MADD: mul_op <= MUL_MADD;
                    MADDU: mul_op <= MUL_MADDU;
                    default: mul_op <= MUL_MFLO;
                endcase
                
            R_TYPE:
                case (funct)
                    MUL: mul_op <= MUL_MUL;
                    MFHI: mul_op <= MUL_MFHI;
                    MFLO: mul_op <= MUL_MFLO;
                    default: mul_op <= MUL_MFLO;
                endcase
                
            default: mul_op <= MUL_MFLO;
        endcase
        
        // from_cp1
        case (opcode)
            CP1: from_cp1 <= 1;
            default: from_cp1 <= 0;
        endcase
        
        // has_overflow
        case (opcode)
            R_TYPE:
                case (funct)
                    ADD, SUB, ADDI: has_overflow <= 1;
                    default: has_overflow <= 0;
                endcase
                
            default: has_overflow <= 0;
        endcase
    end
endmodule
