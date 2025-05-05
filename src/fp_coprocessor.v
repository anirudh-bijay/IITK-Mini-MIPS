`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Kanpur
// Engineer: Anirudh Cheriyachanaseri Bijay
// 
// Create Date: 16.04.2025 01:41:35
// Design Name: 
// Module Name: fp_coprocessor
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


module fp_coprocessor #(
    parameter REG_COUNT = 32,
    parameter FLAG_COUNT = 8
)(
    input [31:0] inst,
    input [31:0] data_in,
    input clk,
    output [31:0] data_out,
    output reg [0 : FLAG_COUNT - 1] flags
);
    (* ram_style = "registers" *) reg [31:0] registers[0 : REG_COUNT - 1];
//    (* ram_style = "registers" *) reg flags[0 : FLAG_COUNT - 1];
    
    wire [5:0] opcode;
    wire [4:0] fp_opcode;
    wire [4:0] ft, fs, fd;
    wire [2:0] cc;
    wire [5:0] funct;
    
    assign {opcode, fp_opcode, ft, fs, fd, funct} = inst;
    assign cc = fd[4:2];
    
    assign data_out = registers[fs];
    
    wire reg_wr_en, cc_wr_en, from_processor;
    wire [2:0] fpu_op;
    wire [31:0] fpu_out;
    
    // Instruction decoder
    fpc_instruction_decoder inst_dec(
        .fp_opcode(fp_opcode),
        .funct(funct),
        .reg_wr_en(reg_wr_en),
        .cc_wr_en(cc_wr_en),
        .fpu_op(fpu_op),
        .from_processor(from_processor)
    );
    
    // FPU
    fpu fpu(
        .in1(registers[fs]),
        .in2(registers[ft]),
        .fpu_op(fpu_op),
        .out(fpu_out)
    );
    
    always @(posedge clk)
        if (opcode == 6'h11) begin
            if (reg_wr_en)
                registers[fd] <= from_processor ? data_in : fpu_out;
            if (cc_wr_en)
                flags[cc] <= fpu_out[0];
        end
endmodule
