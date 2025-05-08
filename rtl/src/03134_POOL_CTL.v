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
POOL_CTL
2025 Annotation

Description:
- This module implements the control logic for max pooling in a CNN.
- Key: Pool_reg[0][x] comes from the first layer of the CNN core, pool_reg[1][x] comes from the second layer, and pool_reg[2][x] comes from the last layer.
- Removing signals: pool_ok(the same as pool_flag), cnn_out_data, change3(replaced by update_position), p_in_cnt_x(replaced by position_x), p_in_cnt_y(replaced by position_y).
*/

module POOL_CTL(
    input           rst_n,
    input           clk,
    input           cnn_out,        // CNN output flag
    input   [7:0]   cnn_data_out,
    output          pool_flag,      // Pooling completion flag
    output  [7:0]   pool_data       // Output data after pooling
);

    reg     [7:0]   pool_reg [0:2][0:6];// Registers to store unprocessed pooling data
    reg     [1:0]   state  ;// Recoding cunrrent layer of cnn_data_out (2'b00 - 2'b10)
    
    reg     [2:0]   position_x;// Recording the position of the procesing unit in the 6*2 matrix (/'meɪtrɪks/) 000-101
    reg             position_y;// 0-1
    wire            update_position;// Update the position
    assign  update_position = (state == 2'b10) && cnn_out;

    // The input to the pooling module (also the output of the Regfile) is a concatenation of REG0, REG1, REG6, and the current output of the CNN layer.
    wire    [31:0]  cnn_pool_data  ;
    assign cnn_pool_data = {
        pool_reg[state][0],pool_reg[state][1],
        pool_reg[state][6],cnn_data_out
    };

    assign pool_flag = position_x[0] && position_y;
    // When processing the (1,1), (1,3), (1,5) positions, the pool completes.
    // It is the same as this description: assign pool_flag = ((position_x == 3'b001) || (position_x == 3'b011) || (position_x == 3'b101)) && (position_y == 1'b1);

    // Counter for 'state'
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= 2'b00;
        end else begin
            if(cnn_out)
            begin
                case (state)
                    2'b00: state <= 2'b01;
                    2'b01: state <= 2'b10;
                    2'b10: state <= 2'b00;
                    default: state <= 2'b00;
                endcase
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
        begin
            pool_reg[0][0] <= 0;
            pool_reg[0][1] <= 0;
            pool_reg[0][2] <= 0;
            pool_reg[0][3] <= 0;
            pool_reg[0][4] <= 0;
            pool_reg[0][5] <= 0;
            pool_reg[0][6] <= 0;
            pool_reg[1][0] <= 0;
            pool_reg[1][1] <= 0;
            pool_reg[1][2] <= 0;
            pool_reg[1][3] <= 0;
            pool_reg[1][4] <= 0;
            pool_reg[1][5] <= 0;
            pool_reg[1][6] <= 0;
            pool_reg[2][0] <= 0;
            pool_reg[2][1] <= 0;
            pool_reg[2][2] <= 0;
            pool_reg[2][3] <= 0;
            pool_reg[2][4] <= 0;
            pool_reg[2][5] <= 0;
            pool_reg[2][6] <= 0;
        end
        else
        begin
            if(cnn_out)
            begin
                pool_reg[state][0] <= pool_reg[state][1];
                pool_reg[state][1] <= pool_reg[state][2];
                pool_reg[state][2] <= pool_reg[state][3];
                pool_reg[state][3] <= pool_reg[state][4];
                pool_reg[state][4] <= pool_reg[state][5];
                pool_reg[state][5] <= pool_reg[state][6];
                pool_reg[state][6] <= cnn_data_out;   
            end
            else
            begin
                pool_reg[state][0] <= pool_reg[state][0];
                pool_reg[state][1] <= pool_reg[state][1];
                pool_reg[state][2] <= pool_reg[state][2];
                pool_reg[state][3] <= pool_reg[state][3];
                pool_reg[state][4] <= pool_reg[state][4];
                pool_reg[state][5] <= pool_reg[state][5];
                pool_reg[state][6] <= pool_reg[state][6];
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
        begin
            position_x <= 3'b000;
            position_y <= 1'b0;
        end
        else begin
            if(update_position)
            begin
                if( position_x == 3'd5)
                begin
                    position_y <= !position_y;
                    position_x <= 3'b000;
                end
                else begin
                    position_x <= position_x + 3'b001;
                    position_y <= position_y;
                end
            end
            else
            begin
                position_x <= position_x;
                position_y <= position_y;        
            end
        end
    end

    POOL u_POOL(
    .cnn_data  (cnn_pool_data   ),
    .pool_data (pool_data       )
    );

endmodule

