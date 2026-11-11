`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2026 05:15:22 PM
// Design Name: 
// Module Name: multiplier
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


module multiplier(input wire [31:0] operand1, operand2, output wire [63:0] mult_out);

reg [63:0] multiplier_reg;
assign mult_out = multiplier_reg;

always @(operand1, operand2) begin
    multiplier_reg = operand1 * operand2;
end

endmodule
