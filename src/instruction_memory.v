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
// Unaligned accesses (using addresses that are not multiples
// of 4) are not supported.
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
)(
    input [ADDR_WIDTH + 1 : 0] read_addr,
    input [ADDR_WIDTH + 1 : 0] write_addr,
    input [BUS_WIDTH - 1 : 0] data_in,
    input wr_en,
    input clk,
    output [BUS_WIDTH - 1 : 0] data_out
);
    simple_dual_port_distributed_ram_0 memory(
        .d(data_in),
        .a(write_addr[ADDR_WIDTH + 1 : 2]),
        .dpra(read_addr[ADDR_WIDTH + 1 : 2]),
        .dpo(data_out),
        .clk(clk),
        .we(wr_en)
    );
endmodule
