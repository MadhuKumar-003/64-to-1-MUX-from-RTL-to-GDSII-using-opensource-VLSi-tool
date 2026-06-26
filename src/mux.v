// --- Building Block: 2-to-1 MUX ---
module mux2_1 (
    input wire a, b,
    input wire sel,
    output wire y
);
    assign y = sel ? b : a;
endmodule

// --- Top Level: 64-to-1 MUX (Binary Tree) ---
module mux64_1 (
    input wire [63:0] data_in,
    input wire [5:0] sel, 
    output wire y
);

    // Intermediate wires for tree stages
    wire [31:0] stage1;
    wire [15:0] stage2;
    wire [7:0]  stage3;
    wire [3:0]  stage4;
    wire [1:0]  stage5;
    wire        final_out; // Explicit wire to clear the Yosys warning

    // Stage 1: 32 MUXes
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : stage1_gen
            mux2_1 m (.a(data_in[2*i]), .b(data_in[2*i+1]), .sel(sel[0]), .y(stage1[i]));
        end
    endgenerate

    // Stage 2: 16 MUXes
    generate
        for (i = 0; i < 16; i = i + 1) begin : stage2_gen
            mux2_1 m (.a(stage1[2*i]), .b(stage1[2*i+1]), .sel(sel[1]), .y(stage2[i]));
        end
    endgenerate

    // Stage 3: 8 MUXes
    generate
        for (i = 0; i < 8; i = i + 1) begin : stage3_gen
            mux2_1 m (.a(stage2[2*i]), .b(stage2[2*i+1]), .sel(sel[2]), .y(stage3[i]));
        end
    endgenerate

    // Stage 4: 4 MUXes
    generate
        for (i = 0; i < 4; i = i + 1) begin : stage4_gen
            mux2_1 m (.a(stage3[2*i]), .b(stage3[2*i+1]), .sel(sel[3]), .y(stage4[i]));
        end
    endgenerate

    // Stage 5: 2 MUXes
    generate
        for (i = 0; i < 2; i = i + 1) begin : stage5_gen
            mux2_1 m (.a(stage4[2*i]), .b(stage4[2*i+1]), .sel(sel[4]), .y(stage5[i]));
        end
    endgenerate

    // Final Stage: 1 MUX driving the intermediate wire
    mux2_1 final_mux (
        .a(stage5[0]), 
        .b(stage5[1]), 
        .sel(sel[5]), 
        .y(final_out)
    );

    // Explicit continuous assignment guarantees Yosys sees a valid driver
    assign y = final_out;

endmodule
