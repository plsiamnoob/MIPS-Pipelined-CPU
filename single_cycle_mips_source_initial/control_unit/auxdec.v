module auxdec (
        input  wire [1:0] alu_op,
        input  wire [5:0] funct,
        output wire hilo_we,
        output wire update_regfile,
        output wire shift_sel,
        output wire shift_dir,
        output wire jr,
        output wire [1:0] hilo_sel,
        output wire [2:0] alu_ctrl
    );

    reg [2:0] ctrl;
    reg hilo_we_reg;
    reg update_regfile_reg;
    reg shift_sel_reg;
    reg shift_dir_reg;
    reg jr_reg;
    reg [1:0] hilo_sel_reg;
   
    assign {alu_ctrl} = ctrl;
    assign hilo_we = hilo_we_reg;
    assign shift_sel = shift_sel_reg;
    assign shift_dir = shift_dir_reg;
    assign update_regfile = update_regfile_reg;
    assign jr = jr_reg;
    assign hilo_sel = hilo_sel_reg;

    always @ (alu_op, funct) begin
        ctrl = 3'b000;
        hilo_we_reg = 1'b0;
        hilo_sel_reg = 2'b10;
        update_regfile_reg = 1'b1;
        shift_sel_reg = 1'b1;
        shift_dir_reg = 1'b0;
        jr_reg = 1'b0;
        case (alu_op)
            2'b00: ctrl = 3'b010;          // ADD
            2'b01: ctrl = 3'b110;          // SUB
            default: case (funct)
                6'b10_0100: ctrl = 3'b000; // AND
                6'b10_0101: ctrl = 3'b001; // OR
                6'b10_0000: ctrl = 3'b010; // ADD
                6'b10_0010: ctrl = 3'b110; // SUB
                6'b10_1010: ctrl = 3'b111; // SLT
                6'b01_1001: begin 
                    hilo_we_reg = 1'b1; //MULTU
                    update_regfile_reg = 1'b0;
                end
                6'b01_0000: hilo_sel_reg = 2'b11; //MFHI
                6'b01_0010: hilo_sel_reg = 2'b01; //MFLO 
                6'b00_0000: begin
                    shift_sel_reg = 1'b0;
                    shift_dir_reg = 1'b1; //SLL
                end    
                6'b00_0010: begin
                    shift_sel_reg = 1'b0;
                    shift_dir_reg = 1'b0; //SRL
                end 
                6'b00_1000: begin
                    update_regfile_reg = 1'b0;
                    jr_reg = 1'b1; //jr      
                end   
                default: begin
                    ctrl = 3'bxxx;
                    hilo_we_reg = 1'b0;
                    hilo_sel_reg = 2'bxx;
                    update_regfile_reg = 1'b1;
                    shift_dir_reg = 1'bx;
                    shift_sel_reg = 1'bx;
                    jr_reg = 1'bx;
                end
            endcase
        endcase
    end

endmodule