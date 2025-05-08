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
TB_TOP
2025 Annotation

Description:
- This module serves as the testbench for the CNN_TOP module.
- The signal has been modified to be more readable.
- Removing signal:out_pass, result, comp, pass (4)
- Adding signal:pass, num_pass (2)
- It is used for pre-simulation by the VCS simulator.However, you should use "negedge" to replace "posedge" in the testbench to use for post-simulation.
*/

module CNN_TOP_tb;

    // Parameters
    parameter CLK_PERIOD = 20; // clock frequency = 50MHz(/ˈmeɡəhɪrts/)
    parameter num_weight = 54; // the number of weights (CNN: 3*9=27, FC: 3*9=27)
    parameter num_data   = 12100; // the number of input data (11*11*100)
    parameter num_output = 100; // the number of output data (100)

    // Inputs
    reg sys_clk; // System clock signal
    reg sys_rst_n; // System reset signal, active low
    reg mode; // Mode selection signal: high for loading weights, low for loading data
    wire [7:0] in_data; // Input data to the chip, from weights or input data
    reg work_flag; // Work flag signal, high indicates the chip starts working

    // Memory arrays
    reg [7:0] weight[num_weight-1:0]; // Weight storage
    reg [7:0] data[num_data-1:0]; // Input data storage
    reg [7:0] outputs[num_output-1:0]; // Expected output storage
    wire pass; // Output verification flag, indicates if the current output is correct
    reg [14:0] cnt_data; // Data counter for iterating input data, range: 0~12100-1
    reg [5:0] cnt_weight; // Weight counter for iterating weights
    reg [6:0] cnt_output; // Output counter for iterating expected outputs
    reg [6:0] num_pass; // Number of correct outputs (pass count)

    // Initialize memory arrays
    initial $readmemb("./03204_weight.txt", weight); // Load weights from file
    initial $readmemb("./03205_data.txt", data); // Load input data from file
    initial $readmemb("./03206_output.txt", outputs); // Load expected outputs from file

    // Initialize counters
    initial cnt_data = 0;
    initial cnt_weight = 0;
    initial cnt_output = 0;
    initial num_pass = 0;

    // Outputs
    wire out_now; // Current output valid signal, high indicates valid output of the entire chip
    wire [7:0] out_data; // Current output data

    // Instantiate the unit under test (UUT)
    CNN_TOP uut (
        .clk(sys_clk),
        .rst_n(sys_rst_n),
        .mode(mode),
        .in_data(in_data),
        .work_flag(work_flag),
        .out_now(out_now),
        .out_data(out_data)
    );

    // Output verification logic
    assign pass = out_now ? (out_data == outputs[cnt_output]) : 1'b0; // Compare current output with expected value
    
    always @(posedge sys_clk) begin
        if (out_now) begin
            if (pass) begin
                $display("out %d : out = %b, true = %b, ***PASS***", cnt_output, out_data, outputs[cnt_output]);
                num_pass <= num_pass + 1; // Increment pass count
            end else begin
                $display("out %d : out = %b, true = %b, ***ERROR***", cnt_output, out_data, outputs[cnt_output]);
            end
        cnt_output <= cnt_output + 1; // Update output counter
        end
    end

    reg [31:0] cnt; // Global counter for controlling workflow

    // Clock generation
    always #(CLK_PERIOD/2) sys_clk = ~sys_clk;

    // Input data selection logic: select weights or input data based on mode
    assign in_data = mode ? weight[cnt_weight] : data[cnt_data];

    // Data and weight counter update logic
    always @(posedge sys_clk) begin
        if (work_flag) begin
            if (mode) begin
                cnt_weight <= cnt_weight + 1; // Update weight counter
            end else if (!mode) begin
                if (cnt_data < 14'd12100)
                    cnt_data <= cnt_data + 1; // Update data counter
            end
        end
    end

    // Global counter update logic
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            cnt <= 32'd0; // Reset counter
        end else begin
            cnt <= cnt + 1; // Increment counter
        end
    end

    // Workflow control logic
    always @(posedge sys_clk) begin
        if (cnt == 32'd20) begin
            work_flag <= 1; // Start working
            mode <= 1; // Set mode to load weights
        end else if (cnt == 32'd74) begin
            mode <= 0; // Set mode to load data
        end else if (cnt == 32'd12174) begin
            work_flag <= 0; // Stop working
        end else if (cnt == 32'd12674) begin
            if ((cnt_output == 100) && (num_pass == 100))
                $display("***************PASS**************"); 
            else
                $display("******There are some errors******");
            $finish; // End simulation
        end
    end

    // Simulation initialization
    initial begin
        sys_clk = 1; // Initialize clock
        sys_rst_n = 0; // Initialize reset signal
        mode = 0; // Initialize mode
        work_flag = 0; // Initialize work flag
        #100;
        sys_rst_n = 1; // Release reset signal
    end

    // Enable waveform generation (only use in VCS)
    // initial $vcdpluson;
    // initial $vcdplusmemon;

endmodule
