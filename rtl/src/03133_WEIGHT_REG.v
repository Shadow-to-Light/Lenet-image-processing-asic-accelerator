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
WEIGHT_REG
2025 Annotation

Important changes!!:
@@ -139,7 +139,7 @@ module  WEIGHT(
                filter_REG[0][6] <= filter_REG[0][6];
                filter_REG[0][7] <= filter_REG[0][7];
                filter_REG[0][8] <= filter_REG[0][8];
-               filter_REG[1][0] <= filter_REG[0][0];
+               filter_REG[1][0] <= filter_REG[1][0];
                filter_REG[1][1] <= filter_REG[1][1];
                filter_REG[1][2] <= filter_REG[1][2];
                filter_REG[1][3] <= filter_REG[1][3];
 @@ -264,7 +264,7 @@ module  WEIGHT(
                weight_REG[0][6] <= weight_REG[0][6];
                weight_REG[0][7] <= weight_REG[0][7];
                weight_REG[0][8] <= weight_REG[0][8];
-               weight_REG[1][0] <= weight_REG[0][0];
+               weight_REG[1][0] <= weight_REG[1][0];
                weight_REG[1][1] <= weight_REG[1][1];
                weight_REG[1][2] <= weight_REG[1][2];
                weight_REG[1][3] <= weight_REG[1][3];
Description:
- This module is the weight register for the CNN accelerator chip.
*/

module  WEIGHT(
    input           rst_n           ,
    input           clk             ,
    input           mode            ,
    input           cnn_mode        ,
    input           fc_mode        ,
    input   [7:0]   in_reg_data     ,
    input           work_flag       ,
    output  [71:0]  filter_data          ,
    output  [71:0]  weight_data          
);

    reg     [7:0]   weight_REG  [2:0][8:0];
    reg     [7:0]   filter_REG  [2:0][8:0];
    reg     [2:0]   mux_sel;

    reg     [5:0]   cnt;
    
    assign  filter_data =   {
        filter_REG[0][0],  filter_REG[0][1],  filter_REG[0][2],  
        filter_REG[0][3],  filter_REG[0][4],  filter_REG[0][5],  
        filter_REG[0][6],  filter_REG[0][7],  filter_REG[0][8]   
        };
    assign  weight_data =   {
        weight_REG[0][0],  weight_REG[0][1],  weight_REG[0][2],  
        weight_REG[1][0],  weight_REG[1][1],  weight_REG[1][2],  
        weight_REG[2][0],  weight_REG[2][1],  weight_REG[2][2]   
        };

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
        begin
            filter_REG[0][0] <= 0;
            filter_REG[0][1] <= 0;
            filter_REG[0][2] <= 0;
            filter_REG[0][3] <= 0;
            filter_REG[0][4] <= 0;
            filter_REG[0][5] <= 0;
            filter_REG[0][6] <= 0;
            filter_REG[0][7] <= 0;
            filter_REG[0][8] <= 0;
            filter_REG[1][0] <= 0;
            filter_REG[1][1] <= 0;
            filter_REG[1][2] <= 0;
            filter_REG[1][3] <= 0;
            filter_REG[1][4] <= 0;
            filter_REG[1][5] <= 0;
            filter_REG[1][6] <= 0;
            filter_REG[1][7] <= 0;
            filter_REG[1][8] <= 0;
            filter_REG[2][0] <= 0;
            filter_REG[2][1] <= 0;
            filter_REG[2][2] <= 0;
            filter_REG[2][3] <= 0;
            filter_REG[2][4] <= 0;
            filter_REG[2][5] <= 0;
            filter_REG[2][6] <= 0;
            filter_REG[2][7] <= 0;
            filter_REG[2][8] <= 0;
        end
        else
        begin
            if (cnn_mode) begin
                filter_REG[0][0] <= filter_REG[1][0];
                filter_REG[0][1] <= filter_REG[1][1];
                filter_REG[0][2] <= filter_REG[1][2];
                filter_REG[0][3] <= filter_REG[1][3];
                filter_REG[0][4] <= filter_REG[1][4];
                filter_REG[0][5] <= filter_REG[1][5];
                filter_REG[0][6] <= filter_REG[1][6];
                filter_REG[0][7] <= filter_REG[1][7];
                filter_REG[0][8] <= filter_REG[1][8];
                filter_REG[1][0] <= filter_REG[2][0];
                filter_REG[1][1] <= filter_REG[2][1];
                filter_REG[1][2] <= filter_REG[2][2];
                filter_REG[1][3] <= filter_REG[2][3];
                filter_REG[1][4] <= filter_REG[2][4];
                filter_REG[1][5] <= filter_REG[2][5];
                filter_REG[1][6] <= filter_REG[2][6];
                filter_REG[1][7] <= filter_REG[2][7];
                filter_REG[1][8] <= filter_REG[2][8];
                filter_REG[2][0] <= filter_REG[0][0];
                filter_REG[2][1] <= filter_REG[0][1];
                filter_REG[2][2] <= filter_REG[0][2];
                filter_REG[2][3] <= filter_REG[0][3];
                filter_REG[2][4] <= filter_REG[0][4];
                filter_REG[2][5] <= filter_REG[0][5];
                filter_REG[2][6] <= filter_REG[0][6];
                filter_REG[2][7] <= filter_REG[0][7];
                filter_REG[2][8] <= filter_REG[0][8];
            end
            else if( mode & work_flag &(!cnt[5]))
            begin
                filter_REG[0][0] <= filter_REG[0][1];
                filter_REG[0][1] <= filter_REG[0][2];
                filter_REG[0][2] <= filter_REG[0][3];
                filter_REG[0][3] <= filter_REG[0][4];
                filter_REG[0][4] <= filter_REG[0][5];
                filter_REG[0][5] <= filter_REG[0][6];
                filter_REG[0][6] <= filter_REG[0][7];
                filter_REG[0][7] <= filter_REG[0][8];
                filter_REG[0][8] <= filter_REG[1][0];
                filter_REG[1][0] <= filter_REG[1][1];
                filter_REG[1][1] <= filter_REG[1][2];
                filter_REG[1][2] <= filter_REG[1][3];
                filter_REG[1][3] <= filter_REG[1][4];
                filter_REG[1][4] <= filter_REG[1][5];
                filter_REG[1][5] <= filter_REG[1][6];
                filter_REG[1][6] <= filter_REG[1][7];
                filter_REG[1][7] <= filter_REG[1][8];
                filter_REG[1][8] <= filter_REG[2][0];
                filter_REG[2][0] <= filter_REG[2][1];
                filter_REG[2][1] <= filter_REG[2][2];
                filter_REG[2][2] <= filter_REG[2][3];
                filter_REG[2][3] <= filter_REG[2][4];
                filter_REG[2][4] <= filter_REG[2][5];
                filter_REG[2][5] <= filter_REG[2][6];
                filter_REG[2][6] <= filter_REG[2][7];
                filter_REG[2][7] <= filter_REG[2][8];
                filter_REG[2][8] <= in_reg_data;
            end
            else 
            begin
                filter_REG[0][0] <= filter_REG[0][0];
                filter_REG[0][1] <= filter_REG[0][1];
                filter_REG[0][2] <= filter_REG[0][2];
                filter_REG[0][3] <= filter_REG[0][3];
                filter_REG[0][4] <= filter_REG[0][4];
                filter_REG[0][5] <= filter_REG[0][5];
                filter_REG[0][6] <= filter_REG[0][6];
                filter_REG[0][7] <= filter_REG[0][7];
                filter_REG[0][8] <= filter_REG[0][8];
                filter_REG[1][0] <= filter_REG[1][0];
                filter_REG[1][1] <= filter_REG[1][1];
                filter_REG[1][2] <= filter_REG[1][2];
                filter_REG[1][3] <= filter_REG[1][3];
                filter_REG[1][4] <= filter_REG[1][4];
                filter_REG[1][5] <= filter_REG[1][5];
                filter_REG[1][6] <= filter_REG[1][6];
                filter_REG[1][7] <= filter_REG[1][7];
                filter_REG[1][8] <= filter_REG[1][8];
                filter_REG[2][0] <= filter_REG[2][0];
                filter_REG[2][1] <= filter_REG[2][1];
                filter_REG[2][2] <= filter_REG[2][2];
                filter_REG[2][3] <= filter_REG[2][3];
                filter_REG[2][4] <= filter_REG[2][4];
                filter_REG[2][5] <= filter_REG[2][5];
                filter_REG[2][6] <= filter_REG[2][6];
                filter_REG[2][7] <= filter_REG[2][7];
                filter_REG[2][8] <= filter_REG[2][8];
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
        begin
            weight_REG[0][0] <= 0;
            weight_REG[0][1] <= 0;
            weight_REG[0][2] <= 0;
            weight_REG[0][3] <= 0;
            weight_REG[0][4] <= 0;
            weight_REG[0][5] <= 0;
            weight_REG[0][6] <= 0;
            weight_REG[0][7] <= 0;
            weight_REG[0][8] <= 0;
            weight_REG[1][0] <= 0;
            weight_REG[1][1] <= 0;
            weight_REG[1][2] <= 0;
            weight_REG[1][3] <= 0;
            weight_REG[1][4] <= 0;
            weight_REG[1][5] <= 0;
            weight_REG[1][6] <= 0;
            weight_REG[1][7] <= 0;
            weight_REG[1][8] <= 0;
            weight_REG[2][0] <= 0;
            weight_REG[2][1] <= 0;
            weight_REG[2][2] <= 0;
            weight_REG[2][3] <= 0;
            weight_REG[2][4] <= 0;
            weight_REG[2][5] <= 0;
            weight_REG[2][6] <= 0;
            weight_REG[2][7] <= 0;
            weight_REG[2][8] <= 0;
        end
        else
        begin
            if (fc_mode) begin
                weight_REG[0][0] <= weight_REG[0][3];
                weight_REG[0][1] <= weight_REG[0][4];
                weight_REG[0][2] <= weight_REG[0][5];
                weight_REG[0][3] <= weight_REG[0][6];
                weight_REG[0][4] <= weight_REG[0][7];
                weight_REG[0][5] <= weight_REG[0][8];
                weight_REG[0][6] <= weight_REG[0][0];
                weight_REG[0][7] <= weight_REG[0][1];
                weight_REG[0][8] <= weight_REG[0][2];
                weight_REG[1][0] <= weight_REG[1][3];
                weight_REG[1][1] <= weight_REG[1][4];
                weight_REG[1][2] <= weight_REG[1][5];
                weight_REG[1][3] <= weight_REG[1][6];
                weight_REG[1][4] <= weight_REG[1][7];
                weight_REG[1][5] <= weight_REG[1][8];
                weight_REG[1][6] <= weight_REG[1][0];
                weight_REG[1][7] <= weight_REG[1][1];
                weight_REG[1][8] <= weight_REG[1][2];
                weight_REG[2][0] <= weight_REG[2][3];
                weight_REG[2][1] <= weight_REG[2][4];
                weight_REG[2][2] <= weight_REG[2][5];
                weight_REG[2][3] <= weight_REG[2][6];
                weight_REG[2][4] <= weight_REG[2][7];
                weight_REG[2][5] <= weight_REG[2][8];
                weight_REG[2][6] <= weight_REG[2][0];
                weight_REG[2][7] <= weight_REG[2][1];
                weight_REG[2][8] <= weight_REG[2][2];
            end
            else if( mode & work_flag &(cnt[5]))
            begin
                weight_REG[0][0] <= weight_REG[0][1];
                weight_REG[0][1] <= weight_REG[0][2];
                weight_REG[0][2] <= weight_REG[0][3];
                weight_REG[0][3] <= weight_REG[0][4];
                weight_REG[0][4] <= weight_REG[0][5];
                weight_REG[0][5] <= weight_REG[0][6];
                weight_REG[0][6] <= weight_REG[0][7];
                weight_REG[0][7] <= weight_REG[0][8];
                weight_REG[0][8] <= weight_REG[1][0];
                weight_REG[1][0] <= weight_REG[1][1];
                weight_REG[1][1] <= weight_REG[1][2];
                weight_REG[1][2] <= weight_REG[1][3];
                weight_REG[1][3] <= weight_REG[1][4];
                weight_REG[1][4] <= weight_REG[1][5];
                weight_REG[1][5] <= weight_REG[1][6];
                weight_REG[1][6] <= weight_REG[1][7];
                weight_REG[1][7] <= weight_REG[1][8];
                weight_REG[1][8] <= weight_REG[2][0];
                weight_REG[2][0] <= weight_REG[2][1];
                weight_REG[2][1] <= weight_REG[2][2];
                weight_REG[2][2] <= weight_REG[2][3];
                weight_REG[2][3] <= weight_REG[2][4];
                weight_REG[2][4] <= weight_REG[2][5];
                weight_REG[2][5] <= weight_REG[2][6];
                weight_REG[2][6] <= weight_REG[2][7];
                weight_REG[2][7] <= weight_REG[2][8];
                weight_REG[2][8] <= in_reg_data;
            end
            else
            begin
                weight_REG[0][0] <= weight_REG[0][0];
                weight_REG[0][1] <= weight_REG[0][1];
                weight_REG[0][2] <= weight_REG[0][2];
                weight_REG[0][3] <= weight_REG[0][3];
                weight_REG[0][4] <= weight_REG[0][4];
                weight_REG[0][5] <= weight_REG[0][5];
                weight_REG[0][6] <= weight_REG[0][6];
                weight_REG[0][7] <= weight_REG[0][7];
                weight_REG[0][8] <= weight_REG[0][8];
                weight_REG[1][0] <= weight_REG[1][0];
                weight_REG[1][1] <= weight_REG[1][1];
                weight_REG[1][2] <= weight_REG[1][2];
                weight_REG[1][3] <= weight_REG[1][3];
                weight_REG[1][4] <= weight_REG[1][4];
                weight_REG[1][5] <= weight_REG[1][5];
                weight_REG[1][6] <= weight_REG[1][6];
                weight_REG[1][7] <= weight_REG[1][7];
                weight_REG[1][8] <= weight_REG[1][8];
                weight_REG[2][0] <= weight_REG[2][0];
                weight_REG[2][1] <= weight_REG[2][1];
                weight_REG[2][2] <= weight_REG[2][2];
                weight_REG[2][3] <= weight_REG[2][3];
                weight_REG[2][4] <= weight_REG[2][4];
                weight_REG[2][5] <= weight_REG[2][5];
                weight_REG[2][6] <= weight_REG[2][6];
                weight_REG[2][7] <= weight_REG[2][7];
                weight_REG[2][8] <= weight_REG[2][8];
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 6'b0;
        end
        else
        begin
            if(mode & work_flag)
            begin
                if(cnt[4:0] == 5'd26)begin
                    cnt[5]   <= !cnt[5];
                    cnt[4:0] <= 5'b0;
                end
                else begin
                    cnt[4:0] <= cnt[4:0] + 1;
                    cnt[5]   <= cnt[5];
                end
            end
            else
            begin
                cnt <= cnt;
            end
        end
    end

endmodule