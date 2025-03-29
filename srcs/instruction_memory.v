`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Kanpur
// Engineer: Anirudh Cheriyachanaseri Bijay
// 
// Create Date: 29.03.2025 17:45:48
// Design Name: instruction_memory
// Module Name: instruction_memory
// Project Name: IITK-Mini-MIPS
// Target Devices: 
// Tool Versions: 
// Description: 
// Wrapper around an instance of distributed_ram_0
// assigned for storing instructions.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module instruction_memory #(
    localparam CAPACITY = 512,
    localparam BUS_WIDTH = 32,
    localparam ADDR_WIDTH = $clog2(CAPACITY)
) (
    input [ADDR_WIDTH - 1 : 0] read_addr,
    input [ADDR_WIDTH - 1 : 0] write_addr,
    input [BUS_WIDTH - 1 : 0] data_in,
    input wr_en,
    input clk,
    output [BUS_WIDTH - 1 : 0] data_out
);
    distributed_ram_0 memory(
        .d(data_in),
        .a(write_addr),
        .dpra(read_addr),
        .dpo(data_out),
        .clk(clk),
        .we(wr_en)
    );
endmodule
