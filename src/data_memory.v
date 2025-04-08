`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Kanpur
// Engineer: Anirudh Cheriyachanaseri Bijay
// 
// Create Date: 09.04.2025 02:16:59
// Design Name: 
// Module Name: data_memory
// Project Name: IITK-Mini-MIPS
// Target Devices: 
// Tool Versions: 
// Description: 
// Wrapper around an instance of distributed_ram_0
// assigned for storing data.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module data_memory #(
    localparam CAPACITY = 512,
    localparam BUS_WIDTH = 32,
    localparam ADDR_WIDTH = $clog2(CAPACITY)
)(
    input [ADDR_WIDTH - 1 : 0] addr,
    input [BUS_WIDTH - 1 : 0] data_in,
    input wr_en,
    input clk,
    output [BUS_WIDTH - 1 : 0] data_out
);
    single_port_distributed_ram_0 memory(
        .d(data_in),
        .a(addr),
        .spo(data_out),
        .clk(clk),
        .we(wr_en)
    );
endmodule
