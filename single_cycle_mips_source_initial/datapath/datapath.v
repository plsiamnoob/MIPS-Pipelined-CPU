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
        input  wire [1:0]  hilo_sel,
        input  wire [2:0]  alu_ctrl,
        input  wire [4:0]  ra3,
        input  wire [31:0] instr,
        input  wire [31:0] rd_dm,
        output wire [31:0] pc_current,
        output wire [31:0] alu_out,
        output wire [31:0] wd_dm,
        output wire [31:0] rd3
    );
    
    wire [4:0]  rf_wa;
    wire [4:0] wr_out;
    wire        pc_src;
    wire [31:0] pc_plus4;
    wire [31:0] pc_pre;
    wire [31:0] pc_next1;
    wire [31:0] pc_next2;
    wire [31:0] sext_imm;
    wire [31:0] ba;
    wire [31:0] bta;
    wire [31:0] jta;
    wire [31:0] alu_pa;
    wire [31:0] alu_pb;
    wire [31:0] wd_rf;
    wire [63:0] mult_out;
    wire [31:0] shift_out;
    wire [31:0] hi;
    wire [31:0] lo;
    wire [31:0] hilo_reg_sel;
    wire [31:0] wd_out1;
    wire [31:0] wd_out2;
    wire [31:0] wd_out3;
    wire        zero;
    
    assign pc_src = branch & zero;
    assign ba = {sext_imm[29:0], 2'b00};
    assign jta = {pc_plus4[31:28], instr[25:0], 2'b00};
    
    // --- PC Logic --- //  
    dreg pc_reg (
            .clk            (clk),
            .rst            (rst),
            .d              (pc_next2),
            .q              (pc_current)
        );

    adder pc_plus_4 (
            .a              (pc_current),
            .b              (32'd4),
            .y              (pc_plus4)
        );

    adder pc_plus_br (
            .a              (pc_plus4),
            .b              (ba),
            .y              (bta)
        );

    mux2 #(32) pc_src_mux (
            .sel            (pc_src),
            .a              (pc_plus4),
            .b              (bta),
            .y              (pc_pre)
        );

    mux2 #(32) pc_jmp_mux1 (
            .sel            (jump),
            .a              (pc_pre),
            .b              (jta),
            .y              (pc_next1)
        );
    
    mux2 #(32) pc_jmp_mux2 (
            .sel            (jr),
            .a              (pc_next1),
            .b              (alu_pa),
            .y              (pc_next2)
        );

    // --- RF Logic --- //
    mux2 #(5) rf_wa_mux (
            .sel            (reg_dst),
            .a              (instr[20:16]),
            .b              (instr[15:11]),
            .y              (wr_out)
        );
    
    // --- JAL Logic --- //
     mux2 #(5) final_rf_mux (
            .sel            (jal),
            .a              (wr_out),
            .b              (5'b11111),
            .y              (rf_wa)
        ); 
    
    regfile rf (
            .clk            (clk),
            .we             ((we_reg & update_regfile)),
            .ra1            (instr[25:21]),
            .ra2            (instr[20:16]),
            .ra3            (ra3),
            .wa             (rf_wa),
            .wd             (wd_rf),
            .rd1            (alu_pa),
            .rd2            (wd_dm),
            .rd3            (rd3),
            .rst            (rst)
        );

    signext se (
            .a              (instr[15:0]),
            .y              (sext_imm)
        );

    // --- ALU Logic --- //
    mux2 #(32) alu_pb_mux (
            .sel            (alu_src),
            .a              (wd_dm),
            .b              (sext_imm),
            .y              (alu_pb)
        );

    alu alu (
            .op             (alu_ctrl),
            .a              (alu_pa),
            .b              (alu_pb),
            .zero           (zero),
            .y              (alu_out)
        );
    
    // --- Multiplier Logic --- //
    multiplier mul (
            .operand1       (alu_pa),
            .operand2       (wd_dm),
            .mult_out       (mult_out)
    );
    
    // --- HILO REG LOGIC --- //
    hilo_reg hilo (
            .clk            (clk),
            .rst            (rst),
            .hilo_we        (hilo_we),
            .in             (mult_out),
            .hi             (hi),
            .lo             (lo)
    );
    
    mux2 #(32) hilo_select (
            .sel            (hilo_sel[1]),
            .a              (lo),
            .b              (hi),
            .y              (hilo_reg_sel)
    );
  
  // --- Shifter Logic --- //
    shifter shift (
            .direction      (shift_dir),
            .shamt          (instr[10:6]),
            .operand        (wd_dm),
            .shift_out      (shift_out)
    );
   
            
    // --- MEM Logic --- //
    mux2 #(32) rf_wd_mux (
            .sel            (dm2reg),
            .a              (alu_out),
            .b              (rd_dm),
            .y              (wd_out1)
    );
    
    mux2 #(32) shifter_mux (
            .sel            (shift_sel),
            .a              (shift_out),
            .b              (wd_out1),
            .y              (wd_out2)
    );
    
    mux2 #(32) jal_mux (
            .sel            (jal),
            .a              (wd_out2),
            .b              (pc_plus4),
            .y              (wd_out3)
    );
    
    mux2 #(32) final_output (
            .sel            (hilo_sel[0]),
            .a              (wd_out3),
            .b              (hilo_reg_sel),
            .y              (wd_rf)
    );

endmodule