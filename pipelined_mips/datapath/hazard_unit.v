module hazard_unit (input wire branch, jump, jr, execute_we_reg, execute_dm2reg, memory_dm2reg,
                    decode_prediction_bit, pc_src, memory_we_reg, writeback_we_reg, 
                    input wire [4:0] decode_rs_reg, decode_rt_reg, 
                    execute_rd_reg, execute_rs_reg, execute_rt_reg, 
                    memory_rd_reg, writeback_rd_reg, 
                    output wire stall, flush, 
                    output wire [1:0] forward_id_rs, forward_id_rt, forward_ex_rs, forward_ex_rt);

wire ex_reg_match, mem_reg_match;

assign ex_reg_match = (((decode_rs_reg == execute_rd_reg) | (decode_rt_reg == execute_rd_reg))) & (execute_rd_reg != 5'd0);
assign mem_reg_match = (((decode_rs_reg == memory_rd_reg) | (decode_rt_reg == memory_rd_reg))) & (memory_rd_reg != 5'd0);

assign stall = (ex_reg_match & execute_dm2reg & ~(jump & ~jr)) | 
               (ex_reg_match  & execute_we_reg & (branch | jr)) | 
               (mem_reg_match & memory_dm2reg & (branch | jr));
assign flush = ~stall & ((pc_src ^ decode_prediction_bit) | jump | jr);

assign forward_id_rs = (memory_we_reg & ~memory_dm2reg & (memory_rd_reg == decode_rs_reg) & (memory_rd_reg != 5'b00000)) ? 2'b10 : 
                   ((writeback_we_reg & (writeback_rd_reg == decode_rs_reg) & (writeback_rd_reg != 5'b00000)) ? 2'b01 : 2'b00);

assign forward_id_rt = (memory_we_reg & ~memory_dm2reg & (memory_rd_reg == decode_rt_reg) & (memory_rd_reg != 5'b00000)) ? 2'b10 : 
                   ((writeback_we_reg & (writeback_rd_reg == decode_rt_reg) & (writeback_rd_reg != 5'b00000)) ? 2'b01 : 2'b00);

assign forward_ex_rs = (memory_we_reg & ~memory_dm2reg & (memory_rd_reg == execute_rs_reg) & (memory_rd_reg != 5'b00000)) ? 2'b10 : 
                   ((writeback_we_reg & (writeback_rd_reg == execute_rs_reg) & (writeback_rd_reg != 5'b00000)) ? 2'b01 : 2'b00);

assign forward_ex_rt = (memory_we_reg & ~memory_dm2reg & (memory_rd_reg == execute_rt_reg) & (memory_rd_reg != 5'b00000)) ? 2'b10 : 
                   ((writeback_we_reg & (writeback_rd_reg == execute_rt_reg) & (writeback_rd_reg != 5'b00000)) ? 2'b01 : 2'b00);

endmodule 