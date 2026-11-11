`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2026 01:50:37 PM
// Design Name: 
// Module Name: shifter
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


module shifter(input wire direction, input wire [4:0] shamt, input wire [31:0] operand, output wire [31:0] shift_out);

reg [31:0] shift_out_reg;
assign shift_out = shift_out_reg;

always @(direction, shamt, operand) begin
    shift_out_reg = direction ? (operand << shamt) : (operand >> shamt);
end

endmodule
