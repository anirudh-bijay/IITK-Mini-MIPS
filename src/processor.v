`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Kanpur
// Engineer: Anirudh Cheriyachanaseri Bijay
// 
// Create Date: 07.04.2025 22:42:59
// Design Name: 
// Module Name: processor
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


module processor(
    input clk
);
    wire [31:0] pc_out;
    wire [31:0] inst_mem_out;
    wire [31:0] inst_reg_out;
    wire [31:0] reg_out1, reg_out2;
    wire [31:0] data_mem_out;
    wire [31:0] alu_out;
    
    // Labels for components of an instruction word
    wire [5:0] opcode, funct;
    wire [4:0] rs, rt, rd, shamt;
    assign {opcode, rs, rt, rd, shamt, funct} = inst_reg_out;
    wire [15:0] imm;
    assign {opcode, rs, rt, imm} = inst_reg_out;
    wire [25:0] label;
    assign {opcode, label} = inst_reg_out;
    
    // Control signals
    wire needs_three_regs, jump, jump_reg, load, store, link, alu_imm,
        branch, write_to_register, write_to_hi, write_to_lo, read_from_hi,
        read_from_lo;
    wire [5:0] alu_op;
    
    // Program counter
    program_counter pc(
        .clk(clk),
        .Q(pc_out)
    );
    
    // Instruction memory
    instruction_memory inst_mem(
        .read_addr(pc_out),
        .clk(clk),
        .data_out(inst_mem_out)
    );
    
    // Data memory
    data_memory data_mem(
        .addr(alu_out),
        .data_in(reg_out2),
        .wr_en(store),
        .clk(clk),
        .data_out(data_mem_out)
    );
    
    // Instruction register
    instruction_register inst_reg(
        .D(inst_mem_out),
        .clk(clk),
        .Q(inst_reg_out)
    );
    
    // Instruction decoder
    instruction_decoder inst_dec(
        .opcode(opcode),
        .funct(funct),
        .needs_three_regs(needs_three_regs),
        .jump(jump),
        .jump_reg(jump_reg),
        .load(load),
        .store(store),
        .link(link),
        .alu_op(alu_op),
        .alu_imm(alu_imm),
        .branch(branch),
        .write_to_register(write_to_register),
        .write_to_hi(write_to_hi),
        .write_to_lo(write_to_lo),
        .read_from_hi(read_from_hi),
        .read_from_lo(read_from_lo)
    );
    
    // Register file
    register_file reg_file(
        .read_addr1(rs),
        .read_addr2(rt),
        .write_addr(
            needs_three_regs
                ? rd
                : link
                    ? 31    // $ra
                    : rt
        ),
        .data_in(
            load
                ? data_mem_out
                : link
                    ? pc_out + 4
                    : alu_out
        ),
        .wr_en(write_to_register),
        .clk(clk),
        .data_out1(reg_out1),
        .data_out2(reg_out2)
    );
endmodule
