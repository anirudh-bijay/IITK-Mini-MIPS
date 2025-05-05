`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Kanpur
// Engineer: Anirudh Cheriyachanaseri Bijay
// 
// Create Date: 15.04.2025 01:57:10
// Design Name: 
// Module Name: fpu
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


module fpu #(
    // fpu_op
    parameter ADD = 3'h0,
    parameter SUB = 3'h1,
    parameter EQ = 3'h2,
    parameter LT = 3'h3,
    parameter GT = 3'h4,
    parameter LE = 3'h5,
    parameter GE = 3'h6,
    parameter MOV = 3'h7
)(
    input [31:0] in1,
    input [31:0] in2,
    input [2:0] fpu_op,
    output reg [31:0] out
);
    // 32-bit floating point adder/subtractor
    //
    // A single ip instance capable of both addition and subtraction is used
    // to reduce hardware resource consumption. The ip is customised to use
    // two DSP48 slice for the computation.
   
    wire [31:0] addsub_out;
    
    fp_addsub_0 adder_subtractor(
        .s_axis_a_tdata(in1),
        .s_axis_b_tdata(in2),
        .s_axis_operation_tdata(
            fpu_op == ADD
                ? 8'b0
                : fpu_op == SUB
                    ? 8'b1
                    : 8'bx  // Don't care condition
        ),
        .m_axis_result_tdata(addsub_out)
    );
    
    // 32-bit floating point comparator
    
    wire less, equal, greater;
    
    fp_compare_0 comparator(
        .s_axis_a_tdata(in1),
        .s_axis_b_tdata(in2),
        .m_axis_result_tdata({greater, less, equal})
    );
    
    always @*
        case (fpu_op)
            ADD, SUB: out <= addsub_out;
            EQ: out <= equal;
            LT: out <= less;
            GT: out <= greater;
            LE: out <= less || equal;
            GE: out <= greater || equal;
            MOV: out <= in1;
            default: out <= 32'bx;
        endcase
endmodule
