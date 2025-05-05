`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Kanpur
// Engineer: Anirudh Cheriyachanaseri Bijay
// 
// Create Date: 16.04.2025 10:15:16
// Design Name: 
// Module Name: cpu
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


module cpu(
    input [31:0] input_data,
    input input_ready,
    input clk,
    input rst,
    output [31:0] output_data,
    output output_ready
);
    wire [31:0] data_from_cp1, data_to_cp1;
    wire [31:0] inst_to_cp1;
    wire overflow;
    wire [0:7] cp1_flags;
    
    processor processor(
        .clk(clk),
        .rst(rst),
        .data_from_cp1(data_from_cp1),
        .data_to_cp1(data_to_cp1),
        .inst(inst_to_cp1),
        .overflow(overflow),
        .input_data(input_data),
        .input_ready(input_ready),
        .output_data(output_data),
        .output_ready(output_ready)
    );
    
    fp_coprocessor coprocessor_1(
        .clk(clk),
        .inst(inst_to_cp1),
        .data_in(data_to_cp1),
        .data_out(data_from_cp1),
        .flags(cp1_flags)
    );
endmodule
