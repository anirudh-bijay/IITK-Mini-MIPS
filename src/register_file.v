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
// Reads are unclocked and unlatched; writes are clocked. The register with
// label (address) 0 is the MIPS $zero register: reads from the register
// return zero and writes to the register are discarded.
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
    reg [BUS_WIDTH - 1 : 0] registers[1 : COUNT - 1];
    wire [BUS_WIDTH - 1 : 0] register_values[0 : COUNT - 1];
    
    assign register_values[0] = {BUS_WIDTH {1'b0}};
    
    genvar i;
    generate
        for (i = 1; i < COUNT; i = i + 1) begin
            assign register_values[i] = registers[i];
        end
    endgenerate
        
    assign data_out1 = register_values[read_addr1];
    assign data_out2 = register_values[read_addr2];
    
    always @(posedge clk)
        if (wr_en)
            registers[write_addr] <= data_in;
endmodule
