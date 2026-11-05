// fir4.sv -- 4-tap symmetric FIR [1 3 3 1]/8, 3-stage pipeline

// ---------------- Stage 1: symmetric pre-adds ----------------
module fir4_stage1 (
    input  wire       clk,
    input  wire       rst_b,
    input  wire       valid_in,
    input  wire [7:0] x0, x1, x2, x3,   // x[n], x[n-1], x[n-2], x[n-3]
    output reg  [8:0] sum_a,            // x[n]   + x[n-3]
    output reg  [8:0] sum_b,            // x[n-1] + x[n-2]
    output reg        valid_out
);
    // sign-extend 8 -> 9 bits (exactly 1 extra bit)
    wire [8:0] e0 = {x0[7], x0};
    wire [8:0] e1 = {x1[7], x1};
    wire [8:0] e2 = {x2[7], x2};
    wire [8:0] e3 = {x3[7], x3};

    wire [8:0] sa = e0 + e3;
    wire [8:0] sb = e1 + e2;

    always @(posedge clk or negedge rst_b) begin
        if (!rst_b) begin
            sum_a     <= 9'd0;
            sum_b     <= 9'd0;
            valid_out <= 1'b0;
        end else begin
            valid_out <= valid_in;
            sum_a     <= sa;
            sum_b     <= sb;
        end
    end
endmodule

// ---------------- Stage 2: multiply sum_b by 3 ----------------
module fir4_stage2 (
    input  wire        clk,
    input  wire        rst_b,
    input  wire        valid_in,
    input  wire [8:0]  sum_a_in,
    input  wire [8:0]  sum_b_in,
    output reg  [8:0]  sum_a_out,       // passthrough
    output reg  [10:0] prod_b_out,      // 3 * sum_b
    output reg         valid_out
);
    wire [10:0] sb_wide = {{2{sum_b_in[8]}}, sum_b_in};  // sign-extend 9 -> 11
    wire [10:0] sb_x2   = {sb_wide[9:0], 1'b0};          // 2 * sum_b
    wire [10:0] pb      = sb_wide + sb_x2;               // 3 * sum_b

    always @(posedge clk or negedge rst_b) begin
        if (!rst_b) begin
            sum_a_out  <= 9'd0;
            prod_b_out <= 11'd0;
            valid_out  <= 1'b0;
        end else begin
            valid_out  <= valid_in;
            sum_a_out  <= sum_a_in;
            prod_b_out <= pb;
        end
    end
endmodule

// ---------------- Stage 3: final add + divide by 8 ----------------
module fir4_stage3 (
    input  wire        clk,
    input  wire        rst_b,
    input  wire        valid_in,
    input  wire [8:0]  sum_a_in,
    input  wire [10:0] prod_b_in,
    output reg  [7:0]  result,
    output reg         valid_out
);
    wire [10:0] sa_wide = {{2{sum_a_in[8]}}, sum_a_in};  // sign-extend 9 -> 11
    wire [10:0] total   = sa_wide + prod_b_in;

    always @(posedge clk or negedge rst_b) begin
        if (!rst_b) begin
            result    <= 8'd0;
            valid_out <= 1'b0;
        end else begin
            valid_out <= valid_in;
            result    <= total[10:3];   // arithmetic shift right by 3
        end
    end
endmodule

// ---------------- Top level ----------------
module fir4 (
    input  wire        clk,
    input  wire        rst_b,
    input  wire        valid_in,
    input  wire [7:0]  x,
    output wire        valid_out,
    output wire [10:0] y,
    input  wire        scan_en,
    input  wire        test_mode,
    input  wire        scan_in,
    output wire        scan_out
);
`ifndef DFT_INSERTION
    assign scan_out = 1'b0;   // Genus drives this with the scan chain instead
`endif

    // Delay line: x[n-1], x[n-2], x[n-3]
    reg [7:0] x_d1, x_d2, x_d3;
    always @(posedge clk or negedge rst_b) begin
        if (!rst_b) begin
            x_d1 <= 8'd0; x_d2 <= 8'd0; x_d3 <= 8'd0;
        end else if (valid_in) begin
            x_d1 <= x; x_d2 <= x_d1; x_d3 <= x_d2;
        end
    end

    wire [8:0]  s1_sum_a, s1_sum_b;  wire s1_valid;
    fir4_stage1 u_stage1 (
        .clk(clk), .rst_b(rst_b), .valid_in(valid_in),
        .x0(x), .x1(x_d1), .x2(x_d2), .x3(x_d3),
        .sum_a(s1_sum_a), .sum_b(s1_sum_b), .valid_out(s1_valid));

    wire [8:0]  s2_sum_a;  wire [10:0] s2_prod_b;  wire s2_valid;
    fir4_stage2 u_stage2 (
        .clk(clk), .rst_b(rst_b), .valid_in(s1_valid),
        .sum_a_in(s1_sum_a), .sum_b_in(s1_sum_b),
        .sum_a_out(s2_sum_a), .prod_b_out(s2_prod_b), .valid_out(s2_valid));

    wire [7:0]  s3_result;  wire s3_valid;
    fir4_stage3 u_stage3 (
        .clk(clk), .rst_b(rst_b), .valid_in(s2_valid),
        .sum_a_in(s2_sum_a), .prod_b_in(s2_prod_b),
        .result(s3_result), .valid_out(s3_valid));

    // sign-extend 8 -> 11 bits for the output (just wires, no flops)
    assign y         = {{3{s3_result[7]}}, s3_result};
    assign valid_out = s3_valid;
endmodule

