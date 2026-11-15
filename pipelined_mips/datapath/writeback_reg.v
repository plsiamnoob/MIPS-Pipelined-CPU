module writeback_reg (input wire clock, rst, 
                      dm2reg, update_reg, 
                      input wire [4:0] dst_reg,
                      input wire [31:0] result, rd_dm,
                      output wire dm2reg_out, update_reg_out,
                      output wire [4:0] dst_reg_out,
                      output wire [31:0] result_out, rd_dm_out);

reg dm2reg_reg, update_reg_reg;
reg [4:0] dst_reg_reg;
reg [31:0] result_out_reg, rd_dm_reg;

assign {dm2reg_out, update_reg_out, 
        dst_reg_out, result_out, rd_dm_out} = {dm2reg_reg, update_reg_reg,
                                                            dst_reg_reg, result_out_reg, rd_dm_reg};

always @(posedge clock, posedge rst) begin
    if(rst) {dm2reg_reg, update_reg_reg,
            dst_reg_reg, result_out_reg, rd_dm_reg} = 71'h0;
    else {dm2reg_reg, update_reg_reg,
         dst_reg_reg, result_out_reg, rd_dm_reg} = {dm2reg, update_reg, 
                                                   dst_reg, result, rd_dm};

end
endmodule