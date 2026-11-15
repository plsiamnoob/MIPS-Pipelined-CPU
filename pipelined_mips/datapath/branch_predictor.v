module branch_predictor(input wire clock, rst, branch, pc_src, 
input wire [31:0] pc_current_plus4, pc_plus4, bta, output wire taken,
output wire [31:0] predicted_pc);

reg [64:0] branch_target_buffer [3:0];
wire hit, hit1, hit2, hit3, hit4;
wire match1, match2, match3, match4;
wire [31:0] bta_pc;
wire [1:0] pc_prediction;

assign match1 = branch_target_buffer[0][64] & (pc_plus4[31:2] == branch_target_buffer[0][63:34]);
assign match2 = branch_target_buffer[1][64] & (pc_plus4[31:2] == branch_target_buffer[1][63:34]);
assign match3 = branch_target_buffer[2][64] & (pc_plus4[31:2] == branch_target_buffer[2][63:34]);
assign match4 = branch_target_buffer[3][64] & (pc_plus4[31:2] == branch_target_buffer[3][63:34]);


assign hit1 = branch_target_buffer[0][64] & (pc_current_plus4[31:2] == branch_target_buffer[0][63:34]);
assign hit2 = branch_target_buffer[1][64] & (pc_current_plus4[31:2] == branch_target_buffer[1][63:34]);
assign hit3 = branch_target_buffer[2][64] & (pc_current_plus4[31:2] == branch_target_buffer[2][63:34]);
assign hit4 = branch_target_buffer[3][64] & (pc_current_plus4[31:2] == branch_target_buffer[3][63:34]);

assign hit = hit1 | hit2 | hit3 | hit4;

assign pc_prediction = hit1 ? branch_target_buffer[0][1:0] : 
                      (hit2 ? branch_target_buffer[1][1:0] :
                      (hit3 ? branch_target_buffer[2][1:0] :
                      (hit4 ? branch_target_buffer[3][1:0] : 2'b00)));

assign bta_pc = hit1 ? branch_target_buffer[0][33:2] : 
                      (hit2 ? branch_target_buffer[1][33:2] :
                      (hit3 ? branch_target_buffer[2][33:2] :
                      (hit4 ? branch_target_buffer[3][33:2] : 32'h0)));

assign taken = (pc_prediction >= 2) & hit;
assign predicted_pc = taken ? bta_pc : pc_current_plus4;

always @(posedge clock, posedge rst) begin
    if(rst) begin
        branch_target_buffer[0] <= 65'h0;
        branch_target_buffer[1] <= 65'h0;
        branch_target_buffer[2] <= 65'h0;
        branch_target_buffer[3] <= 65'h0;
    end

    else if(branch & ~(match1 | match2 | match3 | match4)) begin
        branch_target_buffer[0] <= {1'b1, pc_plus4[31:2], bta, (pc_src ? 2'b10 : 2'b01)};
        branch_target_buffer[1] <= branch_target_buffer[0];
        branch_target_buffer[2] <= branch_target_buffer[1];
        branch_target_buffer[3] <= branch_target_buffer[2];
    end

    else if(branch & match1) branch_target_buffer[0][1:0] <= pc_src ? 
    ((branch_target_buffer[0][1:0] == 2'b11) ? 2'b11 : branch_target_buffer[0][1:0] + 1) : 
    ((branch_target_buffer[0][1:0] == 2'b00) ? 2'b00 : branch_target_buffer[0][1:0] - 1);
    
    else if(branch & match2) branch_target_buffer[1][1:0] <= pc_src ? 
    ((branch_target_buffer[1][1:0] == 2'b11) ? 2'b11 : branch_target_buffer[1][1:0] + 1) : 
    ((branch_target_buffer[1][1:0] == 2'b00) ? 2'b00 : branch_target_buffer[1][1:0] - 1);

    else if(branch & match3) branch_target_buffer[2][1:0] <= pc_src ? 
    ((branch_target_buffer[2][1:0] == 2'b11) ? 2'b11 : branch_target_buffer[2][1:0] + 1) : 
    ((branch_target_buffer[2][1:0] == 2'b00) ? 2'b00 : branch_target_buffer[2][1:0] - 1);

    else if(branch & match4) branch_target_buffer[3][1:0] <= pc_src ? 
    ((branch_target_buffer[3][1:0] == 2'b11) ? 2'b11 : branch_target_buffer[3][1:0] + 1) : 
    ((branch_target_buffer[3][1:0] == 2'b00) ? 2'b00 : branch_target_buffer[3][1:0] - 1);

end
endmodule