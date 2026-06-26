`timescale 1ns / 1ps

module tb_mux64_1;

    // 1. Declare Testbench Signals
    reg [63:0] data_in;
    reg [5:0] sel;
    wire y;

    // Testbench tracking variables
    integer i;
    integer errors;

    // 2. Instantiate the Unit Under Test (UUT)
    mux64_1 uut (
        .data_in(data_in),
        .sel(sel),
        .y(y)
    );

    // 3. Stimulus Block
    initial begin
        // =========================================================
        // VCD Waveform Generation Setup
        // =========================================================
        $dumpfile("mux_design.vcd"); // Creates the VCD file in your directory
        $dumpvars(0, tb_mux64_1);    // Dumps ALL signals (including internal tree stages)

        // Initialize Inputs with a highly varied binary test pattern
        // Hex A5A5... maps to alternating 10100101 patterns to test 0->1 and 1->0 transitions
        data_in = 64'hA5A5_0F0F_C3C3_5A5A; 
        sel = 0;
        errors = 0;

        $display("========================================");
        $display("   Starting 64-to-1 MUX Simulation      ");
        $display("========================================");

        #10; // Wait 10ns before commencing the test loop

        // Loop through all 64 possible select channel inputs
        for (i = 0; i < 64; i = i + 1) begin
            sel = i;
            
            #5; // Wait 5ns for combinational logic and stages to settle

            // Automated self-checking verification
            if (y !== data_in[i]) begin
                $display("❌ ERROR at sel = %2d: Expected %b, Got %b", i, data_in[i], y);
                errors = errors + 1;
            end else begin
                $display("✅ PASS: sel = %2d | data_in[%2d] = %b | output y = %b", sel, i, data_in[i], y);
            end
        end

        // 4. Final Verification Summary Output
        $display("========================================");
        if (errors == 0) begin
            $display("   SUCCESS: All 64 channels passed!     ");
            $display("   VCD data written to: mux_design.vcd  ");
        end else begin
            $display("   FAILED: Simulation completed with %0d errors.", errors);
        end
        $display("========================================");

        $finish; // Terminate simulation run cleanly
    end

endmodule
