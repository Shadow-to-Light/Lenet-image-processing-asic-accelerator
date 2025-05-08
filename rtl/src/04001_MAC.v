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
CNN_CORE
2025 Annotation

Description:
- The new edition removes some signals and add the 'for' loop to make the code more readable.
- This module implements a 3x3 convolutional core for CNN and outputs the 20-bit sum.
- 8bit * 8bit = 16bit, 16bit + 16bit + …… + 16bit (Num:9) = 20bit.
*/

module CNN_CORE (
    input   clk,
    input   rst_n,
    input   [71:0]  Kernel,
    input   [71:0]  Weight,
    output  [19:0]  o_sum_20
);

    // 3×3 的 8-bit 数据寄存器（用于存储 Kernel 和 Weight 的展开值）
    reg signed [7:0] mult_A_reg[0:8];
    reg signed [7:0] mult_B_reg[0:8];

    // 3×3 的 16-bit 乘积结果
    reg signed [15:0] product_reg[0:8];

    // 20-bit 求和结果
    reg signed [19:0] sum_20;

    assign o_sum_20 = sum_20;

    // 将 Kernel 和 Weight 展开并存入寄存器
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 9; i = i + 1) begin
                mult_A_reg[i] <= 0;
                mult_B_reg[i] <= 0;
            end
        end else begin
            {mult_A_reg[0], mult_A_reg[1], mult_A_reg[2], 
             mult_A_reg[3], mult_A_reg[4], mult_A_reg[5], 
             mult_A_reg[6], mult_A_reg[7], mult_A_reg[8]} <= Kernel;

            {mult_B_reg[0], mult_B_reg[1], mult_B_reg[2], 
             mult_B_reg[3], mult_B_reg[4], mult_B_reg[5], 
             mult_B_reg[6], mult_B_reg[7], mult_B_reg[8]} <= Weight;
        end
    end

    // 计算乘积并存储
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 9; i = i + 1)
                product_reg[i] <= 0;
        end else begin
            for (i = 0; i < 9; i = i + 1)
                product_reg[i] <= mult_A_reg[i] * mult_B_reg[i];
        end
    end

    // 累加乘积求和
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_20 <=   0;
        end else begin
            sum_20 <=   product_reg[0] + product_reg[1] + product_reg[2] +
                        product_reg[3] + product_reg[4] + product_reg[5] +
                        product_reg[6] + product_reg[7] + product_reg[8];
        end
    end

endmodule
