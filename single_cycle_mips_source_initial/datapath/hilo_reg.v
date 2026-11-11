`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2026 05:47:07 PM
// Design Name: 
// Module Name: hilo_reg
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


module hilo_reg(input clk, rst, hilo_we, input [63:0] in,  output wire [31:0] hi, lo);

reg [31:0] hi_reg;
reg [31:0] lo_reg;

assign hi = hi_reg;
assign lo = lo_reg;

always @(posedge clk, posedge rst) begin
    if(rst) {hi_reg, lo_reg} = 64'h0;
    else if (hilo_we) {hi_reg, lo_reg} = in;
end

endmodule
