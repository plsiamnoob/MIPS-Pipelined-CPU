module memory_reg(input wire clock, rst,
                  we_dm, dm2reg, update_reg, input wire [4:0] dst_reg, 
                  input wire [31:0] result, source_reg2,
                  output wire we_dm_out, dm2reg_out, update_reg_out, output wire [4:0] dst_reg_out,
                  output wire [31:0] result_out, source_reg2_out
                  );

reg we_dm_reg, dm2reg_reg, update_reg_reg;
reg [4:0] dst_reg_reg;
reg [31:0] result_reg, source_reg2_reg;

assign {we_dm_out, dm2reg_out, update_reg_out, dst_reg_out, 
       result_out, source_reg2_out} = {we_dm_reg, dm2reg_reg, update_reg_reg, 
                                      dst_reg_reg, result_reg, source_reg2_reg};

always @(posedge clock, posedge rst) begin
    if(rst) {we_dm_reg, dm2reg_reg, update_reg_reg, 
            dst_reg_reg, result_reg, source_reg2_reg} = 72'h0;
    else {we_dm_reg, dm2reg_reg, update_reg_reg, 
         dst_reg_reg, result_reg, source_reg2_reg} = {we_dm, dm2reg, update_reg, dst_reg,
                                                     result, source_reg2};

end
endmodule