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
    input [31:0] data_from_cp1,
    input [31:0] input_data,
    input input_ready,
    input clk,
    input rst,
    output [31:0] inst,
    output [31:0] data_to_cp1,
    output overflow,
    output [31:0] output_data,
    output output_ready
);
    wire [31:0] pc_in, pc_out, pc_inc;
    wire [31:0] inst_mem_out;
//    wire [31:0] inst_reg_out;
    wire [31:0] reg_out1, reg_out2;
    wire [31:0] data_mem_out;
    wire [31:0] alu_out;
    wire [31:0] mul_out;
    wire alu_overflow;
    
    // Labels for components of an instruction word
    wire [5:0] opcode, funct;
    wire [4:0] rs, rt, rd, shamt;
    assign {opcode, rs, rt, rd, shamt, funct} = inst_mem_out;
    wire [15:0] imm;
    assign {opcode, rs, rt, imm} = inst_mem_out;
    wire [25:0] label;
    assign {opcode, label} = inst_mem_out;
    
    assign inst = inst_mem_out;
    
    // Control signals
    wire needs_three_regs, jump, jump_reg, load, store, link, alu_imm,
        shift_imm, load_upper, branch, write_to_register, load_from_hi_lo,
        from_cp1, has_overflow;
    wire [4:0] alu_op;
    wire [2:0] mul_op;
    
    // Data to coprocessor 1
    assign data_to_cp1 = reg_out2; 
    
    // Program counter
    program_counter pc(
        .D(pc_in),
        .rst(rst),
        .clk(clk),
        .Q(pc_out)
    );
    
    // Instruction memory
    instruction_memory inst_mem(
        .wr_en(1'b0),
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
        .data_out(data_mem_out),
        .input_data(input_data),
        .input_ready({31'b0, input_ready}),
        .output_data(output_data),
        .output_ready(output_ready)
    );
    
//    // Instruction register
//    instruction_register inst_reg(
//        .D(inst_mem_out),
//        .clk(clk),
//        .Q(inst_reg_out)
//    );
    
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
        .shift_imm(shift_imm),
        .load_upper(load_upper),
        .branch(branch),
        .write_to_register(write_to_register),
        .load_from_hi_lo(load_from_hi_lo),
        .mul_op(mul_op),
        .from_cp1(from_cp1),
        .has_overflow(has_overflow)
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
                    ? pc_inc
                    : from_cp1
                        ? data_from_cp1
                        : alu_out
        ),
        .wr_en(write_to_register),
        .clk(clk),
        .data_out1(reg_out1),
        .data_out2(reg_out2)
    );
    
    // ALU
    alu alu(
        .in1(
            shift_imm
                ? {27'bx, shamt}
                : load_upper
                    ? {27'dx, 5'd16} // 32 / 2
                    : reg_out1
        ),
        .in2(
            load_from_hi_lo
                ? mul_out
                : alu_imm
                    ? imm
                    : reg_out2
        ),
        .alu_op(alu_op),
        .alu_imm(alu_imm),
        .out(alu_out),
        .overflow(alu_overflow)
    );
    
    // Overflow exception
    assign overflow = has_overflow ? alu_overflow : 0;
    
    // Multiply unit
    multiply_unit multiply_unit(
        .in1(reg_out1),
        .in2(reg_out2),
        .mul_op(mul_op),
        .clk(clk),
        .out(mul_out)
    );
    
    // Program counter calculation
    assign pc_inc = pc_out + 32'h4;
    assign pc_in = jump
        ? jump_reg
            ? reg_out1
            : {pc_inc[31:28], label, 2'b0}
        : branch && alu_out[0]
            ? pc_inc + {{14{imm[15]}}, imm, 2'b0}
            : pc_inc;
endmodule
