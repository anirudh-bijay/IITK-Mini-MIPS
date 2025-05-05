`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Kanpur
// Engineer: Anirudh Cheriyachanaseri Bijay
// 
// Create Date: 15.04.2025 02:23:05
// Design Name: 
// Module Name: test_bench1
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


module test_bench1();
    reg clk, rst, input_ready;
    reg [31:0] input_data;
    wire [31:0] output_data;
    wire output_ready;
    
    cpu cpu(input_data, input_ready, clk, rst, output_data, output_ready);
    
    initial begin
        clk <= 0;
        forever #20 clk <= ~clk;
    end
    
    initial begin
        rst <= 1;
        input_ready <= 0;
        #120 rst <= 0;
        #240 input_data <= 5;
        input_ready <= 1;
    end

//    wire [31:0] data_out;
//    register_file regfile(.clk(clk), .wr_en(rst), .data_in(1), .write_addr(0), .read_addr1(0), .data_out1(data_out));
endmodule
