module multiplier(input wire [31:0] operand1, operand2, output wire [63:0] mult_out);

reg [63:0] multiplier_reg;
assign mult_out = multiplier_reg;

always @(operand1, operand2) begin
    multiplier_reg = operand1 * operand2;
end

endmodule
