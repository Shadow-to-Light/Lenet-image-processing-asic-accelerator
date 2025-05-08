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
FC_REG
2025 Annotation

Description:
- This module implements a 9-stage shift register that strores the pooling data.
- When there is 9 pooling data, the fc_ready signal will be high to tackle the CNN layer.
*/

module  FC_DATA(
    input           rst_n           ,
    input           clk             ,
    input           pool_flag       ,
    input   [7:0]   i_pool_data     ,
    output          fc_ready        ,
    output  [71:0]  fc_data  
);

    reg [7:0] FC_REG[8:0]; // 9-stage shift register storing 8-bit values
    reg [3:0] cnt; // 4-bit counter to track shift operations (0-9)

    assign fc_ready = (cnt == 4'h9);// Assign `fc_ready` high when counter reaches 9

    // Reorganizing register data into a 72-bit output
    assign fc_data = {
        FC_REG[0], FC_REG[3], FC_REG[6], 
        FC_REG[1], FC_REG[4], FC_REG[7], 
        FC_REG[2], FC_REG[5], FC_REG[8]
    };

    // Counter logic for tracking shift operations
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 4'b0; // Reset counter to zero
        end else if (cnt == 4'h9) begin
            cnt <= 4'b0; // Reset when count reaches 9
        end else if (pool_flag) begin
            cnt <= cnt + 4'b1; // Increment on valid pool_flag signal
        end
    end
    
    integer i, j;
    // Shift register logic: shifts left on `pool_flag`
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 9; i = i + 1) begin
                FC_REG[i] <= 8'h0;
            end
        end else if (pool_flag) begin
            for (j = 0; j < 8; j = j + 1) begin
                FC_REG[j] <= FC_REG[j + 1]; // Shift left
            end
            FC_REG[8] <= i_pool_data; // Load new data
        end
    end
    
endmodule