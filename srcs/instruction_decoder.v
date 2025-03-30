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
    parameter R_TYPE    = 6'b000000,
    parameter J         = 6'b000010,
    parameter JR        = 6'b001000,
    parameter JAL       = 6'b000011,
    parameter LW        = 6'b100011,
    parameter LUI       = 6'b001111,
    parameter SW        = 6'b101011,
    parameter BEQ       = 6'b000100,
    parameter BNE       = 6'b000101,
    parameter BGT,
    parameter BGTE,
    parameter BLE,
    parameter BLEQ,
    parameter BLEU,
    parameter BGTU,
    // Functions
    parameter SLL       = 6'b000000,
    parameter SRL       = 6'b000010,
    parameter SLA       = SLL,
    parameter SRA       = 6'b000011
) (
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
    output reg write_to_register
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
            default: jump_reg <= 0;
        endcase
        
        // load
        case (opcode)
            LW, LUI: load <= 1;
            default: load <= 0;
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
            // TODO: 
            default: alu_op <= funct;
        endcase
        
        // alu_imm
        case (opcode)
            R_TYPE: case (funct)
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
    end
endmodule
