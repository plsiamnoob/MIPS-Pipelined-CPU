module decode_reg( input wire clock, rst, en, clr, taken, 
input wire [31:0] instr, pc_plus4, 
output wire taken_out, 
output wire [31:0] instr_out, pc_plus4_out);

reg taken_reg;
reg[31:0] instr_reg, pc_plus4_reg;

assign {taken_out, instr_out, pc_plus4_out} = {taken_reg, instr_reg, pc_plus4_reg};

always @(posedge clock, posedge rst) begin
    if(rst) {taken_reg, instr_reg, pc_plus4_reg} = 65'h0;
    else if(clr) {taken_reg, instr_reg, pc_plus4_reg} = 65'h0;
    else if (en) {taken_reg, instr_reg, pc_plus4_reg} = {taken, instr, pc_plus4};
end
endmodule