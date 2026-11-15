module shifter(input wire direction, input wire [4:0] shamt, input wire [31:0] operand, output wire [31:0] shift_out);

reg [31:0] shift_out_reg;
assign shift_out = shift_out_reg;

always @(direction, shamt, operand) begin
    shift_out_reg = direction ? (operand << shamt) : (operand >> shamt);
end

endmodule
