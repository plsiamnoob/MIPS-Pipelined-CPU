module datapath (
        input  wire        clk,
        input  wire        rst,
        input  wire        branch,
        input  wire        jump,
        input  wire        jal,
        input  wire        jr,
        input  wire        reg_dst,
        input  wire        we_reg,
        input  wire        alu_src,
        input  wire        dm2reg,
        input  wire        hilo_we, 
        input  wire        update_regfile,
        input  wire        shift_sel, 
        input  wire        shift_dir,
        input  wire        we_dm,  
        input  wire [1:0]  hilo_sel,
        input  wire [2:0]  alu_ctrl,
        input  wire [4:0]  ra3,
        input  wire [31:0] instr,
        input  wire [31:0] rd_dm,
        output wire        memory_we_dm,
        output wire [31:0] pc_current,
        output wire [31:0] alu_out,
        output wire [31:0] memory_result_reg,
        output wire [31:0] memory_source_reg2,
        output wire [31:0] decode_instr,
        output wire [31:0] rd3
    );
    
    wire [4:0]  rf_wa;
    wire [4:0] wr_out;
    wire [4:0] final_ex_rs_reg_in;
    wire [4:0] final_ex_rt_reg_in;
    wire        pc_src;
    wire [31:0] pc_plus4;
    wire [31:0] pc_pre;
    wire [31:0] pc_next;
    wire [31:0] pc_next1;
    wire [31:0] pc_next2;
    wire [31:0] pc_next3;
    wire [31:0] sext_imm;
    wire [31:0] final_ex_source_reg3_in;
    wire [31:0] ba;
    wire [31:0] bta;
    wire [31:0] jta;
    wire [31:0] alu_pa;
    wire [31:0] source_reg1;
    wire [31:0] alu_pb;
    wire [31:0] wd_rf;
    wire [31:0] final_result;
    wire [63:0] mult_out;
    wire [31:0] shift_out;
    wire [31:0] hi;
    wire [31:0] lo;
    wire [31:0] hilo_reg_sel;
    wire [31:0] wd_out;
    wire [31:0] wd_dm;
    wire        zero;
    
    wire decode_taken; 
    wire [31:0] decode_pc_plus4;

    wire execute_we_reg, execute_alu_src, execute_we_dm, execute_dm2reg, 
    execute_hilo_we, execute_update_regfile, execute_shift_sel, execute_shift_dir; 
    wire [1:0] execute_hilo_sel;
    wire [2:0] execute_alu_ctrl;
    wire [31:0] execute_source_reg1, execute_source_reg2, execute_source_reg3; 
    wire [4:0] execute_shamt, execute_rs_reg, execute_rt_reg, execute_dst_reg;

    wire memory_dm2reg, memory_update_reg;
    wire [4:0] memory_dst_reg;
    
    wire writeback_dm2reg, writeback_update_reg;
    wire [4:0] writeback_dst_reg;
    wire [31:0] writeback_result_reg, writeback_rd_dm;

    wire stall, flush; 
    wire [1:0] forward_ex_rs, forward_ex_rt, forward_id_rs, forward_id_rt;

    wire taken;
    wire [31:0] predicted_pc;

    wire [31:0] ex_rs_mux_out1, ex_rs_mux_out2, ex_rt_mux_out1, ex_rt_mux_out2;
    wire [31:0] id_rs_mux_out1, id_rs_mux_out2, id_rt_mux_out1, id_rt_mux_out2;

    assign pc_src = branch & zero;
    assign ba = {sext_imm[29:0], 2'b00};
    assign jta = {decode_pc_plus4[31:28], decode_instr[25:0], 2'b00};
    
    // --- Fetch Stage --- //  
    dreg pc_reg (
            .clk            (clk),
            .rst            (rst),
            .d              (pc_next3),
            .q              (pc_current)
        );

    adder pc_plus_4 (
            .a              (pc_current),
            .b              (32'd4),
            .y              (pc_plus4)
        );
 
    branch_predictor predictor (
            .clock          (clk),
            .rst            (rst),
            .branch         (branch & ~stall),
            .pc_src         (branch & zero),
            .pc_current_plus4 (pc_plus4),
            .pc_plus4       (decode_pc_plus4),
            .bta            (bta),
            .taken          (taken),
            .predicted_pc   (predicted_pc)
        );

    decode_reg decode (
            .clock          (clk), 
            .rst            (rst), 
            .en             (~stall), 
            .clr            (flush),
            .taken          (taken), 
            .instr          (instr),
            .pc_plus4       (pc_plus4), 
            .taken_out      (decode_taken),
            .instr_out      (decode_instr),
            .pc_plus4_out   (decode_pc_plus4)
        );

    // --- Decode Stage --- //
     
    hazard_unit hdu (
            .branch            (branch),
            .jump              (jump),
            .jr                (jr),
            .execute_dm2reg    (execute_dm2reg),
            .memory_dm2reg     (memory_dm2reg),
            .execute_we_reg    (execute_update_regfile & execute_we_reg),
            .decode_prediction_bit (decode_taken),
            .pc_src         (pc_src),
            .memory_we_reg  (memory_update_reg),
            .writeback_we_reg (writeback_update_reg),
            .decode_rs_reg  (final_ex_rs_reg_in),
            .decode_rt_reg  (final_ex_rt_reg_in),
            .execute_rd_reg (execute_dst_reg),
            .execute_rs_reg (execute_rs_reg),
            .execute_rt_reg (execute_rt_reg),
            .memory_rd_reg  (memory_dst_reg),
            .writeback_rd_reg (writeback_dst_reg),
            .stall          (stall),
            .flush          (flush),
            .forward_ex_rs  (forward_ex_rs),
            .forward_ex_rt  (forward_ex_rt),
            .forward_id_rs  (forward_id_rs),
            .forward_id_rt  (forward_id_rt)
    );

    mux2 #(32) id_rs_mux1 (
            .sel            (forward_id_rs[0]),
            .a              (source_reg1),
            .b              (final_result),
            .y              (id_rs_mux_out1)
        );

    mux2 #(32) id_rs_mux2 (
            .sel            (forward_id_rs[1]),
            .a              (id_rs_mux_out1),
            .b              (memory_result_reg),
            .y              (id_rs_mux_out2)
        );

    mux2 #(32) id_rt_mux1 (
            .sel            (forward_id_rt[0]),
            .a              (wd_dm),
            .b              (final_result),
            .y              (id_rt_mux_out1)
        );
    mux2 #(32) id_rt_mux2 (
            .sel            (forward_id_rt[1]),
            .a              (id_rt_mux_out1),
            .b              (memory_result_reg),
            .y              (id_rt_mux_out2)
        );

    mux2 #(5) id_hazard_mux1 (
            .sel            (jump & ~jr),
            .a              (decode_instr[25:21]),
            .b              (5'b00000),
            .y              (final_ex_rs_reg_in)
        );

    mux2 #(5) id_hazard_mux2 (
            .sel            (jump & ~jr),
            .a              (decode_instr[20:16]),
            .b              (5'b00000),
            .y              (final_ex_rt_reg_in)
        );


    adder pc_plus_br (
            .a              (decode_pc_plus4),
            .b              (ba),
            .y              (bta)
        );

    mux2 #(32) pc_src_mux (
            .sel            (pc_src),
            .a              (decode_pc_plus4),
            .b              (bta),
            .y              (pc_pre)
        );

    mux2 #(32) pc_flush_mux (
            .sel            (flush),
            .a              (predicted_pc),
            .b              (pc_pre),
            .y              (pc_next)
        );

    mux2 #(32) pc_jmp_mux1 (
            .sel            (jump),
            .a              (pc_next),
            .b              (jta),
            .y              (pc_next1)
        );
    
    mux2 #(32) pc_jmp_mux2 (
            .sel            (jr),
            .a              (pc_next1),
            .b              (id_rs_mux_out2),
            .y              (pc_next2)
        );

    mux2 #(32) pc_stall_mux (
            .sel            (stall),
            .a              (pc_next2),
            .b              (pc_current),
            .y              (pc_next3)
        );

    mux2 #(32) jal_mux (
            .sel            (jal),
            .a              (alu_pa),
            .b              (decode_pc_plus4),
            .y              (source_reg1)
    );

    mux2 #(5) rf_wa_mux (
            .sel            (reg_dst),
            .a              (decode_instr[20:16]),
            .b              (decode_instr[15:11]),
            .y              (wr_out)
        );
    
     mux2 #(5) final_rf_mux (
            .sel            (jal),
            .a              (wr_out),
            .b              (5'b11111),
            .y              (rf_wa)
        ); 
    
    regfile rf (
            .clk            (clk),
            .we             (writeback_update_reg),
            .ra1            (decode_instr[25:21]),
            .ra2            (decode_instr[20:16]),
            .ra3            (ra3),
            .wa             (writeback_dst_reg),
            .wd             (final_result),
            .rd1            (alu_pa),
            .rd2            (wd_dm),
            .rd3            (rd3),
            .rst            (rst)
        );

    signext se (
            .a              (decode_instr[15:0]),
            .y              (sext_imm)
        );

     mux2 #(32) final_source_reg3_mux (
            .sel            (jal),
            .a              (sext_imm),
            .b              (32'h0),
            .y              (final_ex_source_reg3_in)
        ); 

    comparator comp (
            .operand1       (id_rs_mux_out2),
            .operand2       (id_rt_mux_out2),
            .eq             (zero)
        );

    execute_reg execute (
            .clock          (clk), 
            .rst            (rst), 
            .clr            (stall),
            .we_reg         (we_reg),
            .alu_src        (alu_src),
            .we_dm          (we_dm),
            .dm2reg         (dm2reg),
            .hilo_we        (hilo_we),
            .update_regfile (update_regfile),
            .shift_sel      (shift_sel),
            .shift_dir      (shift_dir),
            .hilo_sel       (hilo_sel),
            .alu_ctrl       (alu_ctrl),
            .source_reg1    (id_rs_mux_out2),
            .source_reg2    (id_rt_mux_out2),
            .source_reg3    (final_ex_source_reg3_in),
            .shamt          (decode_instr[10:6]),
            .rs_reg         (final_ex_rs_reg_in),
            .rt_reg         (final_ex_rt_reg_in),
            .dst_reg        (rf_wa),
            .we_reg_out     (execute_we_reg),
            .alu_src_out    (execute_alu_src),
            .we_dm_out      (execute_we_dm),
            .dm2reg_out     (execute_dm2reg),
            .hilo_we_out    (execute_hilo_we),
            .update_regfile_out (execute_update_regfile),
            .shift_sel_out  (execute_shift_sel),
            .shift_dir_out  (execute_shift_dir),
            .hilo_sel_out   (execute_hilo_sel),
            .alu_ctrl_out   (execute_alu_ctrl),
            .source_reg1_out (execute_source_reg1),
            .source_reg2_out (execute_source_reg2),
            .source_reg3_out (execute_source_reg3),
            .shamt_out      (execute_shamt),
            .rs_reg_out     (execute_rs_reg),
            .rt_reg_out     (execute_rt_reg),
            .dst_reg_out    (execute_dst_reg)      
        );

    // --- Execute Stage --- //
    mux2 #(32) ex_rs_mux1 (
            .sel            (forward_ex_rs[0]),
            .a              (execute_source_reg1),
            .b              (final_result),
            .y              (ex_rs_mux_out1)
        );

    mux2 #(32) ex_rs_mux2 (
            .sel            (forward_ex_rs[1]),
            .a              (ex_rs_mux_out1),
            .b              (memory_result_reg),
            .y              (ex_rs_mux_out2)
        );

    mux2 #(32) ex_rt_mux1 (
            .sel            (forward_ex_rt[0]),
            .a              (execute_source_reg2),
            .b              (final_result),
            .y              (ex_rt_mux_out1)
        );

    mux2 #(32) ex_rt_mux2 (
            .sel            (forward_ex_rt[1]),
            .a              (ex_rt_mux_out1),
            .b              (memory_result_reg),
            .y              (ex_rt_mux_out2)
        );

    mux2 #(32) alu_pb_mux (
            .sel            (execute_alu_src),
            .a              (ex_rt_mux_out2),
            .b              (execute_source_reg3),
            .y              (alu_pb)
        );

    alu alu (
            .op             (execute_alu_ctrl),
            .a              (ex_rs_mux_out2),
            .b              (alu_pb),
            .y              (alu_out)
        );
    
    multiplier mul (
            .operand1       (ex_rs_mux_out2),
            .operand2       (ex_rt_mux_out2),
            .mult_out       (mult_out)
    );
    
    hilo_reg hilo (
            .clk            (clk),
            .rst            (rst),
            .hilo_we        (execute_hilo_we),
            .in             (mult_out),
            .hi             (hi),
            .lo             (lo)
    );
    
    mux2 #(32) hilo_select (
            .sel            (execute_hilo_sel[1]),
            .a              (lo),
            .b              (hi),
            .y              (hilo_reg_sel)
    );
  
    shifter shift (
            .direction      (execute_shift_dir),
            .shamt          (execute_shamt),
            .operand        (ex_rt_mux_out2),
            .shift_out      (shift_out)
    );

    mux2 #(32) shifter_mux (
            .sel            (execute_shift_sel),
            .a              (shift_out),
            .b              (alu_out),
            .y              (wd_out)
    );
    
    mux2 #(32) hilo_mux (
            .sel            (execute_hilo_sel[0]),
            .a              (wd_out),
            .b              (hilo_reg_sel),
            .y              (wd_rf)
    );

    memory_reg memory (
            .clock          (clk),
            .rst            (rst),
            .we_dm          (execute_we_dm),
            .dm2reg         (execute_dm2reg),
            .update_reg     (execute_update_regfile & execute_we_reg),
            .dst_reg        (execute_dst_reg),
            .result         (wd_rf),
            .source_reg2    (ex_rt_mux_out2),
            .we_dm_out      (memory_we_dm),
            .dm2reg_out     (memory_dm2reg),
            .update_reg_out (memory_update_reg),
            .dst_reg_out    (memory_dst_reg),
            .result_out     (memory_result_reg),
            .source_reg2_out (memory_source_reg2)
    );
    
    // --- Memory Stage --- // 
    writeback_reg writeback (
            .clock          (clk),
            .rst            (rst),
            .dm2reg         (memory_dm2reg),
            .update_reg     (memory_update_reg),
            .dst_reg        (memory_dst_reg),
            .result         (memory_result_reg),
            .rd_dm          (rd_dm),
            .dm2reg_out     (writeback_dm2reg),
            .update_reg_out (writeback_update_reg),
            .dst_reg_out    (writeback_dst_reg),
            .result_out     (writeback_result_reg),
            .rd_dm_out      (writeback_rd_dm)
    );

    // --- Writeback Stage --- // 
    mux2 #(32) rf_wd_mux (
            .sel            (writeback_dm2reg),
            .a              (writeback_result_reg),
            .b              (writeback_rd_dm),
            .y              (final_result)
    );

endmodule