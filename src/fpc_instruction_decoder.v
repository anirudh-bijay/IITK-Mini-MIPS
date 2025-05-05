`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Kanpur
// Engineer: Anirudh Cheriyachanaseri Bijay
// 
// Create Date: 16.04.2025 03:47:15
// Design Name: 
// Module Name: fpc_instruction_decoder
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


module fpc_instruction_decoder #(
    // fp_opcode
    parameter MFC1 = 5'h0,
    parameter MTC1 = 5'h4,
    parameter COP1_S = 5'h10,
    // funct
    parameter ADD = 6'h0,
    parameter SUB = 6'h1,
    parameter C_EQ = 6'd50,
    parameter C_LE = 6'd62,
    parameter C_LT = 6'd60,
    parameter C_GE = 6'd40,
    parameter C_GT = 6'd42,
    parameter MOV = 6'h6,
    // fpu_op
    parameter FPU_ADD = 3'h0,
    parameter FPU_SUB = 3'h1,
    parameter FPU_EQ = 3'h2,
    parameter FPU_LT = 3'h3,
    parameter FPU_GT = 3'h4,
    parameter FPU_LE = 3'h5,
    parameter FPU_GE = 3'h6,
    parameter FPU_MOV = 3'h7
)(
    input [4:0] fp_opcode,
    input [5:0] funct,
    output reg reg_wr_en,
    output reg cc_wr_en,
    output reg [2:0] fpu_op,
    output reg from_processor
);   
    always @* begin
        // reg_wr_en
        case (fp_opcode)
            MTC1: reg_wr_en <= 1;
            COP1_S: reg_wr_en <= funct < 6'd40;
            default: reg_wr_en <= 0;
        endcase
        
        // cc_wr_en
        case (fp_opcode)
            COP1_S: cc_wr_en <= !(funct < 6'd40);
            default: cc_wr_en <= 0;
        endcase
        
        // fpu_op
        case (funct)
            ADD: fpu_op <= FPU_ADD;
            SUB: fpu_op <= FPU_SUB;
            C_EQ: fpu_op <= FPU_EQ;
            C_LT: fpu_op <= FPU_LT;
            C_GT: fpu_op <= FPU_GT;
            C_LE: fpu_op <= FPU_LE;
            C_GE: fpu_op <= FPU_GE;
            MOV: fpu_op <= FPU_MOV;
            default: fpu_op <= 3'bx;
        endcase
        
        // from_processor
        case (fp_opcode)
            MFC1: from_processor <= 1;
            COP1_S: from_processor <= 0;
            default: from_processor <= 1'bx;
        endcase
    end
endmodule
