module hilo_reg(input clk, rst, hilo_we, input [63:0] in,  output wire [31:0] hi, lo);

reg [31:0] hi_reg;
reg [31:0] lo_reg;

assign hi = hi_reg;
assign lo = lo_reg;

always @(posedge clk, posedge rst) begin
    if(rst) {hi_reg, lo_reg} = 64'h0;
    else if (hilo_we) {hi_reg, lo_reg} = in;
end

endmodule
