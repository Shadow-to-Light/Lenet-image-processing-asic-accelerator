`timescale 1ns/1ps

//////////////////////////////////////////////////////////////////////////////////
// Copyright 2025 University of Electronic Science and Technology of China.     //
// All rights reserved.                                                         //
//                                                                              //
// This file is part of the research work by LI'S TEAM (Z. Li, J. Deng, Z. Xu,  //
// M. Kuang) at the AI_CHIP_PROJECT_2024, UESTC.                                //
//                                                                              //
// Redistribution and use, with or without modification, are permitted          //
// provided that this notice remains in all copies.                             //
//                                                                              //
// THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY WARRANTIES.                    //
//////////////////////////////////////////////////////////////////////////////////
/*
CNN_CORE_CTL
2025 Annotation

Description:
- This module is the core controller for the CNN accelerator chip.
- Removing signals: fc_out_now(the same as out_now), cnn_result(the same as out_data) (2)
- The use of cnn_ready_reg and fc_ready_reg is very important and excellent for timing control.
*/

// `include "03104_CNN_CORE.v"
// `include "03105_QUANTIFY.v"
module CNN_CORE_CTL (
    input               rst_n,
    input               clk,
    input               fc_ready,       // FC ready signal (FC preempts CNN)
    input               cnn_ready,      // CNN ready to receive new data from DATA module
    input       [71:0]  cnn_data,       // Input data for CNN computation
    input       [71:0]  filter_data,    // CNN weight data
    input       [71:0]  fc_data,        // Input data for FC computation
    input       [71:0]  weight_data,    // FC weight data
    output  reg         out_now,        // Active high indicates output of THE ENTIRE CHIP is valid
    output  reg [7:0]   out_data,       // Final output data
    output              cnn_out,        // Active high indicates output of CNN module is valid
    output      [7:0]   cnn_data_out    // CNN module output
);

    wire [19:0] sum_20;
    wire [20:0] fc_sum, cnn_sum, quantify_in;
    wire [7:0] quantify_out;
    wire [71:0] Kernel, Weight;

    // FC counter：00 -> 01 -> 10 -> 00
    reg [1:0] fc_state;
    // To store the FC computation results temporarily
    reg [19:0] fc_out [1:0];

    // Very important: 4-bit register to store the FC and CNN ready signals.The key to design the synchronous system!
    reg [3:0] fc_ready_reg, cnn_ready_reg;

    // MAC module needs 2 cycles and QUANTIFY module needs 1 cycle to process data so that we need to delay the cnn_ready signal by 3 cycles to make sure the output of CNN module is valid.
    assign cnn_out = cnn_ready_reg[3] & ~fc_ready_reg[3];
    assign cnn_data_out = quantify_out;

    // Delaying the fc_ready and cnn_ready signals.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fc_ready_reg  <= 4'b0;
            cnn_ready_reg <= 4'b0;
        end else begin
            fc_ready_reg  <= {fc_ready_reg[2:0], fc_ready};
            cnn_ready_reg <= {cnn_ready_reg[2:0], cnn_ready};
        end
    end

    // FC layer has higher priority 
    assign Kernel = fc_ready ? fc_data : cnn_data;
    assign Weight = fc_ready ? weight_data : filter_data;

    CNN_CORE u_CNN_CORE0 (
        .clk      (clk),
        .rst_n    (rst_n),
        .Kernel   (Kernel),
        .Weight   (Weight),
        .o_sum_20 (sum_20)
    );

    // The sum of the FC layer (Add 3 values together)
    assign fc_sum = {fc_out[0][19], fc_out[0]} + {fc_out[1][19], fc_out[1]} + {sum_20[19], sum_20};

    // The sum of the CNN layer (Just extend the output of MAC)
    assign cnn_sum = {sum_20[19], sum_20};

    // MAC module needs 2 cycles to process data, so we need to delay the fc_sum signal by 2 cycles.
    assign quantify_in = fc_ready_reg[2] & (fc_state == 2'b10) ? fc_sum : cnn_sum;

    // QUANTIFY module
    QUANTIFY QUANTIFY_inst (
        .clk(clk),
        .quantify_in  (quantify_in),
        .quantify_out (quantify_out)
    );

    // FC counter: 00 -> 01 -> 10 -> 00
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            fc_state <= 2'b00;
        else if (fc_ready_reg[3]) begin
            case (fc_state)
                2'b00: fc_state <= 2'b01;
                2'b01: fc_state <= 2'b10;
                2'b10: fc_state <= 2'b00;
                default: fc_state <= 2'b00;
            endcase
        end
    end

    // Store the FC computation results temporarily
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fc_out[0] <= 20'b0;
            fc_out[1] <= 20'b0;
        end else if (fc_ready_reg[2]) begin
            case (fc_state)
                2'b00: fc_out[0] <= sum_20;
                2'b01: fc_out[1] <= sum_20;
                default: ;
            endcase
        end
    end

    // The output of FC layer (out_data)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_data <= 8'b0;
            out_now <= 1'b0;
        end else if (fc_ready_reg[3] && fc_state == 2'b10) begin
            out_data <= quantify_out;// The output of THE ENTIRE CHIP.
            out_now <= 1'b1;
        end else begin
            out_now <= 1'b0;
        end
    end

endmodule
