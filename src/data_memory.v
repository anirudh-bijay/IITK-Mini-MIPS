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


module data_memory #(
    localparam CAPACITY = 516,
    localparam BUS_WIDTH = 32,
    localparam ADDR_WIDTH = $clog2(CAPACITY)
)(
    input [ADDR_WIDTH + 1 : 0] addr,
    input [BUS_WIDTH - 1 : 0] data_in,
    input [BUS_WIDTH - 1 : 0] input_data,
    input [BUS_WIDTH - 1 : 0] input_ready,
    input wr_en,
    input clk,
    output [BUS_WIDTH - 1 : 0] data_out,
    output [BUS_WIDTH - 1 : 0] output_data,
    output [BUS_WIDTH - 1 : 0] output_ready
);
    wire data_out_ram;
    
    single_port_distributed_ram_0 memory(
        .d(data_in),
        .a(addr[ADDR_WIDTH + 1 : 2]),
        .spo(data_out_ram),
        .clk(clk),
        .we(wr_en)
    );
    
    reg [BUS_WIDTH - 1 : 0] mmio[CAPACITY - 4 : CAPACITY - 1];  // {input_data, input_ready, output_data, output_ready}
    
    assign output_data = mmio[CAPACITY - 2];
    assign output_ready = mmio[CAPACITY - 1];
    
    always @(posedge clk) begin
        mmio[CAPACITY - 4] <= input_data;
        mmio[CAPACITY - 3] <= input_ready;
        
        if (wr_en)
            mmio[addr] <= data_in;
    end
    
    assign data_out = addr < CAPACITY - 4
        ? data_out_ram
        : mmio[addr];
endmodule
