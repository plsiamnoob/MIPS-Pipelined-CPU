module comparator(input wire [31:0] operand1, operand2, output wire eq);
assign eq = operand1 == operand2;
endmodule