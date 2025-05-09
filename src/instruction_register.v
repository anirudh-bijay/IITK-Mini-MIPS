`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Kanpur
// Engineer: Anirudh Cheriyachanaseri Bijay
// 
// Create Date: 29.03.2025 18:12:47
// Design Name: 
// Module Name: instruction_register
// Project Name: IITK-Mini-MIPS
// Target Devices: 
// Tool Versions: 
// Description: 
// Wrapper around a register modelling D flip-flops to load instructions to
// from the instruction memory.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module instruction_register #(
    parameter BUS_WIDTH = 32
)(
    input [BUS_WIDTH - 1 : 0] D,
    input clk,
    output reg [BUS_WIDTH - 1 : 0] Q
);
    always @(posedge clk)
        Q <= D;
endmodule
