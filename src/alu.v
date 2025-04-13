`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Kanpur
// Engineer: Anirudh Cheriyachanaseri Bijay
// 
// Create Date: 10.04.2025 01:58:21
// Design Name: 
// Module Name: alu
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


module alu #(
    parameter BUS_WIDTH = 32,
    // alu_op
    parameter ADD = 5'h0,
    parameter SUB = 5'h10,
    parameter AND = 5'h1,
    parameter OR  = 5'h2,
    parameter NOT = 5'h3,
    parameter XOR = 5'h4,
    parameter SLL = 5'h5,
    parameter SRL = 5'h6,
    parameter SRA = 5'h7,
    parameter EQ  = 5'h8,
    parameter NE  = 5'h9,
    parameter LT  = 5'ha,
    parameter GT  = 5'hb,
    parameter LE  = 5'hc,
    parameter GE  = 5'hd,
    parameter LTU = 5'he,
    parameter GTU = 5'hf
)(
    input [BUS_WIDTH - 1 : 0] in1,
    input [BUS_WIDTH - 1 : 0] in2,
    input [4:0] alu_op,
    input alu_imm,
    output reg [BUS_WIDTH - 1 : 0] out,
    output reg overflow
);
    wire [BUS_WIDTH - 1 : 0] sign_extended_in2 = $signed(in2[BUS_WIDTH / 2 - 1 : 0]);
    wire [BUS_WIDTH - 1 : 0] zero_extended_in2 = $unsigned(in2[BUS_WIDTH / 2 - 1 : 0]);
    
    wire [BUS_WIDTH - 1 : 0] operand1;
    reg [BUS_WIDTH - 1 : 0] operand2;
    
    assign operand1 = in1;
    
    always @*
        if (alu_imm)
            case (alu_op)
                ADD, SUB, EQ, NE, LT, GT, LE, GE: operand2 <= sign_extended_in2;
                default: operand2 <= zero_extended_in2;
            endcase       
        else
            operand2 <= in2;
            
    // 32-bit adder/subtractor
    //
    // A single ip instance capable of both addition and subtraction is used
    // to reduce hardware resource consumption. The ip is customised to use a
    // single DSP48 slice for the computation and returns, in addition to the
    // sum/difference truncated to 32 bits, a carry-out bit that is
    // used to determine whether overflow has occurred.
    
    wire [BUS_WIDTH - 1 : 0] addsub_out;
    wire addsub_c_out;
    
    int_addsub_0 adder_subtractor(
        .A(operand1),
        .B(operand2),
        .ADD(
            alu_op == ADD
                ? 1
                : alu_op == SUB
                    ? 0
                    : 1'bx  // Don't care condition
        ),
        .S(addsub_out),
        .C_OUT(addsub_c_out)
    );
    
    wire addsub_overflow = addsub_c_out ^ addsub_out[BUS_WIDTH - 1];
    
    // Comparator
    wire less = $signed(operand1) < $signed(operand2), equal = operand1 == operand2;
    wire less_unsigned = $unsigned(operand1) < $unsigned(operand2);
    
    always @* begin
        case (alu_op)
            ADD, SUB: out <= addsub_out;
            AND: out <= operand1 & operand2;
            OR: out <= operand1 | operand2;
            NOT: out <= ~operand2;
            XOR: out <= operand1 ^ operand2;
            SLL: out <= operand2 << operand1[4:0];
            SRL: out <= operand2 >> operand1[4:0];
            SRA: out <= $signed(operand2) >>> operand1[4:0];
            EQ: out <= equal;
            NE: out <= !equal;
            LT: out <= less;
            GT: out <= !(less || equal);
            LE: out <= less || equal;
            GE: out <= !less;
            LTU: out <= less_unsigned;
            GTU: out <= !(less_unsigned || equal);
            default: out <= {BUS_WIDTH {1'bx}};
        endcase
        
        case (alu_op)
            ADD, SUB: overflow <= addsub_overflow;
            default: overflow <= 1'bx;
        endcase
    end
endmodule
