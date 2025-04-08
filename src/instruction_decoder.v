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
    parameter MFLO      = 6'h12
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
    
    // If branch is high, the program counter is updated with the computed
    // branch destination address if the ALU output is zero.
    output reg branch,
    
    // If write_to_register is high, the register file's write enable is
    // asserted.
    // Else, it is deasserted.
    output reg write_to_register,
    
    // If write_to_hi is high, a write is performed to the hi register.
    // Else, nothing is written to hi.
    output reg write_to_hi,
    
    // If write_to_lo is high, a write is performed to the lo register.
    // Else, nothing is written to lo.
    output reg write_to_lo,
    
    // If read_from_hi is high, the data at the write port of the register
    // file is sourced from the hi register.
    output reg read_from_hi,
    
    // If read_from_lo is high, the data at the write port of the register
    // file is sourced from the lo register.
    output reg read_from_lo
);
    always @* begin
        // needs_three_regs
        case (opcode)
            R_TYPE: needs_three_regs <= 1;
            default: needs_three_regs <= 0;
        endcase
        
        // jump
        case (opcode)
            J, JR, JAL: jump <= 1;
            default: jump <= 0;
        endcase
        
        // jump_reg
        case (opcode)
            JR: jump_reg <= 1;
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
            LW, SW: alu_op <= ADDIU;
            default: alu_op <= funct;
        endcase
        
        // alu_imm
        case (opcode)
            R_TYPE:
                case (funct)
                    SLL, SLA, SRL, SRA: alu_imm <= 1;
                    default: alu_imm <= 0;
                endcase
            
            default: alu_imm <= !branch;
        endcase
        
        // branch
        case (opcode)
            BEQ, BNE, BGT, BGTE, BLE, BLEQ, BLEU, BGTU: branch <= 1;
            default: branch <= 0;
        endcase
        
        // write_to_register
        write_to_register <= needs_three_regs || link || load;
        
        // write_to_hi, write_to_lo
        case (opcode)
            MADD_OP, MADDU_OP: begin
                write_to_hi <= 1;
                write_to_lo <= 1;
            end
            
            R_TYPE:
                case (funct)
                    MUL: begin
                        write_to_hi <= 1;
                        write_to_lo <= 1;
                    end
                    
                    default: begin
                        write_to_hi <= 0;
                        write_to_lo <= 0;
                    end
                endcase
            
            default: begin
                write_to_hi <= 0;
                write_to_lo <= 0;
            end
        endcase
        
        case (opcode)
            R_TYPE: begin
                case (funct)
                    MFHI: read_from_hi <= 1;
                    default: read_from_hi <= 0;
                endcase
                
                case (funct)
                    MFLO: read_from_lo <= 1;
                    default: read_from_lo <= 0;
                endcase
            end
                
            default: begin
                read_from_hi <= write_to_register ? 0 : 1'bx;
                read_from_lo <= write_to_register ? 0 : 1'bx;
            end
        endcase
    end
endmodule
