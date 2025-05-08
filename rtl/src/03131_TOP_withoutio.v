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
CNN_TOP
2025 Annotation

Description:
- This module is the top-level controller for the CNN accelerator chip.
- Both the Fully Connected (FC) layer and Convolutional (CNN) layer share the CNN computation module.
- The FC layer has higher priority and can preempt the CNN operation.
- Removing signal:cnn_busy, in_reg_data (2)
- Attention: cnn_busy is the same as fc_ready.
*/

module CNN_TOP(
    input           clk,         // System clock
    input           rst_n,       // Active-low reset
    input           mode,        // Mode selection (0: load input data, 1: load weights)
    input   [7:0]   in_data,     // Either weights or data
    input           work_flag,   // Active high indicates the chip is in operational mode.
    output          out_now,     // Active high indicates output is valid.
    output  [7:0]   out_data     // Final output data
);

    // ---- Internal Data Signals ----
    wire [71:0] cnn_data;       // Input data for CNN computation
    wire [71:0] filter_data;    // CNN weight data
    wire [71:0] fc_data;        // Input data for FC computation
    wire [71:0] weight_data;    // FC weight data

    wire [7:0]  pool_data;      // Data from pooling layer
    wire [7:0]  cnn_data_out;   // CNN module output

    // ---- Control Signals ----
    wire        cnn_ready;      // CNN ready to receive new data from DATA module
    wire        fc_ready;       // FC ready signal (FC preempts CNN)
    wire        cnn_out;        // CNN core output valid flag
    wire        pool_flag;      // Pooling data valid flag

    // ---- DATA Module: Handles data input & CNN state control ----
    DATA DATA_inst (
        .clk          (clk),
        .rst_n        (rst_n),
        .mode         (mode),
        .in_reg_data  (in_data),
        .work_flag    (work_flag),
        .fc_ready     (fc_ready),   // FC has higher priority and preempts CNN
        .cnn_ready    (cnn_ready),
        .cnn_data     (cnn_data)
    );

    // ---- WEIGHT Module: Stores weights for CNN and FC layers ----
    WEIGHT WEIGHT_inst (
        .rst_n        (rst_n),
        .clk          (clk),
        .mode         (mode),
        .cnn_mode     (cnn_ready),
        .fc_mode      (fc_ready),
        .in_reg_data  (in_data),
        .work_flag    (work_flag),
        .filter_data  (filter_data),
        .weight_data  (weight_data)
    );

    // ---- POOL_CTL Module: Handles pooling layer control ----
    POOL_CTL POOL_CTL_inst (
        .rst_n        (rst_n),
        .clk          (clk),
        .cnn_out      (cnn_out),
        .cnn_data_out (cnn_data_out),
        .pool_flag    (pool_flag),
        .pool_data    (pool_data)
    );

    // ---- FC_DATA Module: Manages FC layer data buffering ----
    FC_DATA FC_DATA_inst (
        .rst_n        (rst_n),
        .clk          (clk),
        .pool_flag    (pool_flag),
        .i_pool_data  (pool_data),
        .fc_ready     (fc_ready),
        .fc_data      (fc_data)
    );

    // ---- CNN_CORE_CTL: Controls CNN computation and FC preemption ----
    CNN_CORE_CTL CNN_CORE_CTL_inst (
        .rst_n        (rst_n),
        .clk          (clk),
        .fc_ready     (fc_ready),
        .cnn_ready    (cnn_ready),
        .cnn_data     (cnn_data),
        .filter_data  (filter_data),
        .fc_data      (fc_data),
        .weight_data  (weight_data),
        .out_data     (out_data),
        .out_now      (out_now),
        .cnn_out      (cnn_out),
        .cnn_data_out (cnn_data_out)
    );

endmodule