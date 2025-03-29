`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Kanpur
// Engineer: Anirudh Cheriyachanaseri Bijay
// 
// Create Date: 29.03.2025 22:38:06
// Design Name: 
// Module Name: register_file
// Project Name: IITK-Mini-MIPS
// Target Devices: 
// Tool Versions: 
// Description: 
// Register file with two read ports and one write port supporting concurrent
// read-write operations. On read and write to the same register, the existing
// data is read first before writing in the new data.
// 
// Reads are unclocked and unlatched; writes are clocked.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module register_file #(
    parameter COUNT = 32,
    parameter BUS_WIDTH = 32,
    localparam ADDR_WIDTH = $clog2(COUNT)
)(
    input [ADDR_WIDTH - 1 : 0] read_addr1,
    input [ADDR_WIDTH - 1 : 0] read_addr2,
    input [ADDR_WIDTH - 1 : 0] write_addr,
    input [BUS_WIDTH - 1 : 0] data_in,
    input wr_en,
    input clk,
    output [BUS_WIDTH - 1 : 0] data_out1,
    output [BUS_WIDTH - 1 : 0] data_out2
);
    reg [BUS_WIDTH - 1 : 0] registers[0 : COUNT - 1];
    
    always @(*)
        registers[0] <= 0;
    
    assign data_out1 = registers[read_addr1];
    assign data_out2 = registers[read_addr2];
    
    always @(posedge clk)
        if (wr_en && write_addr != {ADDR_WIDTH{1'b0}})
                registers[write_addr] <= data_in;
endmodule
