module execute_reg(input wire clock, rst, clr, 
                  we_reg, alu_src, we_dm, dm2reg, hilo_we, update_regfile, shift_sel, shift_dir, input wire [1:0] hilo_sel, input wire [2:0] alu_ctrl,   
                  input wire [31:0] source_reg1, source_reg2, source_reg3, 
                  input wire [4:0] shamt, rs_reg, rt_reg, dst_reg,
                  output wire we_reg_out, alu_src_out, we_dm_out, dm2reg_out, hilo_we_out, update_regfile_out, shift_sel_out, shift_dir_out, output wire [1:0] hilo_sel_out, output wire [2:0] alu_ctrl_out,
                  output wire [31:0] source_reg1_out, source_reg2_out, source_reg3_out, 
                  output wire [4:0] shamt_out, rs_reg_out, rt_reg_out, dst_reg_out);

reg we_reg_reg, alu_src_reg, we_dm_reg, dm2reg_reg, hilo_we_reg, update_regfile_reg, shift_sel_reg, shift_dir_reg; 
reg [1:0] hilo_sel_reg;
reg [2:0] alu_ctrl_reg;
reg [31:0] source_reg1_reg, source_reg2_reg, source_reg3_reg;
reg [4:0] shamt_reg, rs_reg_reg, rt_reg_reg, dst_reg_reg;

assign { we_reg_out, alu_src_out, we_dm_out, dm2reg_out, hilo_we_out, 
        update_regfile_out, shift_sel_out, shift_dir_out, hilo_sel_out, 
        alu_ctrl_out, source_reg1_out, source_reg2_out, source_reg3_out, 
        shamt_out, rs_reg_out, rt_reg_out, dst_reg_out} = {we_reg_reg, alu_src_reg, we_dm_reg, dm2reg_reg, hilo_we_reg, update_regfile_reg, 
                                                                        shift_sel_reg, shift_dir_reg, hilo_sel_reg, alu_ctrl_reg, source_reg1_reg, 
                                                                        source_reg2_reg, source_reg3_reg, shamt_reg, rs_reg_reg, rt_reg_reg, dst_reg_reg};

always @(posedge clock, posedge rst) begin
    if(rst) {we_reg_reg, alu_src_reg, we_dm_reg, dm2reg_reg, hilo_we_reg, update_regfile_reg, 
                                                                        shift_sel_reg, shift_dir_reg, hilo_sel_reg, alu_ctrl_reg, source_reg1_reg, 
                                                                        source_reg2_reg, source_reg3_reg, shamt_reg, rs_reg_reg, rt_reg_reg, dst_reg_reg} = 129'h0;
    else if(clr) {we_reg_reg, alu_src_reg, we_dm_reg, dm2reg_reg, hilo_we_reg, update_regfile_reg, 
                                                                        shift_sel_reg, shift_dir_reg, hilo_sel_reg, alu_ctrl_reg, source_reg1_reg, 
                                                                        source_reg2_reg, source_reg3_reg, shamt_reg, rs_reg_reg, rt_reg_reg, dst_reg_reg} = 129'h0;
    else {we_reg_reg, alu_src_reg, we_dm_reg, dm2reg_reg, hilo_we_reg, update_regfile_reg, 
                                                                        shift_sel_reg, shift_dir_reg, hilo_sel_reg, alu_ctrl_reg, source_reg1_reg, 
                                                                        source_reg2_reg, source_reg3_reg, shamt_reg, rs_reg_reg, rt_reg_reg, dst_reg_reg} = {we_reg, alu_src, we_dm, dm2reg, hilo_we, update_regfile, 
                                                                                                                                                            shift_sel, shift_dir, hilo_sel, alu_ctrl, source_reg1, 
                                                                                                                                                            source_reg2, source_reg3, shamt, rs_reg, rt_reg, dst_reg};

end
endmodule
