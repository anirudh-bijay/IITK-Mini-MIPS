`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.04.2025 05:21:44
// Design Name: 
// Module Name: multiply_unit
// Project Name: 
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


module multiply_unit #(
    parameter BUS_WIDTH = 32,
    // mul_op
    parameter MADD  = 3'b000,
    parameter MADDU = 3'b001,
    parameter MUL   = 3'b010,
    parameter MFHI  = 3'b101,
    parameter MFLO  = 3'b100
)(
    input [BUS_WIDTH - 1 : 0] in1,
    input [BUS_WIDTH - 1 : 0] in2,
    input [2:0] mul_op,
    input clk,
    output reg [BUS_WIDTH - 1 : 0] out
);
    reg [BUS_WIDTH - 1 : 0] hi, lo;
    
    reg [2 * BUS_WIDTH - 1 : 0] addend;
    wire [2 * BUS_WIDTH - 1 : 0] signed_result, unsigned_result;
    
    signed_multadd_0 signed_multiply_adder(
        .A(in1),
        .B(in2),
        .C(addend),
        .SUBTRACT(0),
        .P(signed_result)
    );
    
    unsigned_multadd_0 unsigned_multiply_adder(
        .A(in1),
        .B(in2),
        .C(addend),
        .SUBTRACT(0),
        .P(unsigned_result)
    );
    
    always @* begin
        case (mul_op)
            MADD, MADDU: addend <= {hi, lo};
            MUL: addend <= {(2 * BUS_WIDTH) {1'b0}};
            default: addend <= {(2 * BUS_WIDTH) {1'bx}};
        endcase
        
        case (mul_op)
            MFHI: out <= hi;
            MFLO: out <= lo;
            default: out <= {BUS_WIDTH {1'bx}};
        endcase
    end
        
    always @(posedge clk)
        case (mul_op)
            MUL, MADD: {hi, lo} <= signed_result;
            MADDU: {hi, lo} <= unsigned_result;
        endcase
endmodule
