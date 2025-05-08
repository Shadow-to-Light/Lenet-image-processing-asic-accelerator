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
DATA_REG
2025 Annotation

Description:
- It is the most excenlent part of the chip!!!
- This module implements a 4x11 register array to store input data.
- Attention: cnn_busy is the same as fc_ready.
*/

module  DATA(
    input           clk             ,
    input           rst_n           ,
    input           mode            ,
    input   [7:0]   in_reg_data     ,
    input           work_flag       ,
    input           fc_ready        ,
    output          cnn_ready,
    output  [71:0]  cnn_data  
);
    reg [7:0]   reg_matrix [0:3][0:10];
    wire[3:0]   in_cnt_x_real;
    reg [1:0]   in_cnt_y_real;
    reg [1:0]   out_cnt_y_real;
    wire[1:0]   out_cnt_y0_real;
    wire[1:0]   out_cnt_y1_real;
    wire[1:0]   out_cnt_y2_real;
    reg [3:0]   in_cnt_x;
    reg [3:0]   in_cnt_y;
    reg [2:0]   out_x0;
    reg [2:0]   out_y0;
    wire [7:0]  out_data_max [0:2][0:2];
    wire can_do;
    reg can_reg;


    wire [3:0]  out_cnt_x0_real;
    wire [3:0]  out_cnt_x1_real;
    wire [3:0]  out_cnt_x2_real;
    wire change3;
    wire rf;
    wire re;
    wire cf;
    wire ce;
    reg  [5:0]  cnt_36;
    reg  [1:0]  state;
    assign out_cnt_y0_real = out_cnt_y_real + 2'b11 ;
    assign out_cnt_y1_real = out_cnt_y_real         ;
    assign out_cnt_y2_real = out_cnt_y_real + 2'b01 ;
    assign out_cnt_x0_real = {out_x0+ 3'b111 ,1'b1};
    assign out_cnt_x1_real = {out_x0 ,1'b0};
    assign out_cnt_x2_real = {out_x0 ,1'b1};
    assign in_cnt_x_real = in_cnt_x;
    assign cnn_ready = can_do;
    assign o_state   =state   ;
    assign o_change3 =change3  & can_do;
    assign  change3 = (state == 2'b10) && can_do;
    assign rf = (out_x0 == 3'b000);
    assign re = (out_x0 == 3'b101);
    assign cf = (out_y0 == 3'b000);
    assign ce = (out_y0 == 3'b101);
    assign cnn_data = { out_data_max[0][0],     out_data_max[0][1],     out_data_max[0][2], 
                        out_data_max[1][0],     out_data_max[1][1],     out_data_max[1][2], 
                        out_data_max[2][0],     out_data_max[2][1],     out_data_max[2][2] 
                        };
    assign out_data_max[0][0] = rf ? 8'b0 :(cf ? 8'b0 : reg_matrix[out_cnt_y0_real][out_cnt_x0_real]);
    assign out_data_max[1][0] = rf ? 8'b0 :             reg_matrix[out_cnt_y1_real][out_cnt_x0_real];
    assign out_data_max[2][0] = rf ? 8'b0 :(ce ? 8'b0 : reg_matrix[out_cnt_y2_real][out_cnt_x0_real]);
    assign out_data_max[0][1] =             cf ? 8'b0 : reg_matrix[out_cnt_y0_real][out_cnt_x1_real];
    assign out_data_max[1][1] =                         reg_matrix[out_cnt_y1_real][out_cnt_x1_real];
    assign out_data_max[2][1] =             ce ? 8'b0 : reg_matrix[out_cnt_y2_real][out_cnt_x1_real];
    assign out_data_max[0][2] = re ? 8'b0 :(cf ? 8'b0 : reg_matrix[out_cnt_y0_real][out_cnt_x2_real]);
    assign out_data_max[1][2] = re ? 8'b0 :             reg_matrix[out_cnt_y1_real][out_cnt_x2_real];
    assign out_data_max[2][2] = re ? 8'b0 :(ce ? 8'b0 : reg_matrix[out_cnt_y2_real][out_cnt_x2_real]);
    assign can_do = (!fc_ready) & can_reg;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
        begin
            state <= 2'b00;
        end
        else begin
            if(can_do)
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
            reg_matrix[0][0] <= 0;
            reg_matrix[0][1] <= 0;
            reg_matrix[0][2] <= 0;
            reg_matrix[0][3] <= 0;
            reg_matrix[0][4] <= 0;
            reg_matrix[0][5] <= 0;
            reg_matrix[0][6] <= 0;
            reg_matrix[0][7] <= 0;
            reg_matrix[0][8] <= 0;
            reg_matrix[0][9] <= 0;
            reg_matrix[0][10] <= 0;
            reg_matrix[1][0] <= 0;
            reg_matrix[1][1] <= 0;
            reg_matrix[1][2] <= 0;
            reg_matrix[1][3] <= 0;
            reg_matrix[1][4] <= 0;
            reg_matrix[1][5] <= 0;
            reg_matrix[1][6] <= 0;
            reg_matrix[1][7] <= 0;
            reg_matrix[1][8] <= 0;
            reg_matrix[1][9] <= 0;
            reg_matrix[1][10] <= 0;
            reg_matrix[2][0] <= 0;
            reg_matrix[2][1] <= 0;
            reg_matrix[2][2] <= 0;
            reg_matrix[2][3] <= 0;
            reg_matrix[2][4] <= 0;
            reg_matrix[2][5] <= 0;
            reg_matrix[2][6] <= 0;
            reg_matrix[2][7] <= 0;
            reg_matrix[2][8] <= 0;
            reg_matrix[2][9] <= 0;
            reg_matrix[2][10] <= 0;
            reg_matrix[3][0] <= 0;
            reg_matrix[3][1] <= 0;
            reg_matrix[3][2] <= 0;
            reg_matrix[3][3] <= 0;
            reg_matrix[3][4] <= 0;
            reg_matrix[3][5] <= 0;
            reg_matrix[3][6] <= 0;
            reg_matrix[3][7] <= 0;
            reg_matrix[3][8] <= 0;
            reg_matrix[3][9] <= 0;
            reg_matrix[3][10] <= 0;
            
            
        end
        else
        begin
            if( !mode & work_flag)
            begin
                reg_matrix[in_cnt_y_real][in_cnt_x_real] <= in_reg_data;
            end
            else
            begin
                reg_matrix[in_cnt_y_real][in_cnt_x_real] <= reg_matrix[in_cnt_y_real][in_cnt_x_real];
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
        begin
            in_cnt_x <= 4'b0000;
            in_cnt_y <= 4'b0000;
        end
        else begin
            if((!mode ) & work_flag)
            begin
                if(in_cnt_y == 4'd10 && in_cnt_x == 4'd10)
                begin
                    in_cnt_y <= 4'b0000;
                    in_cnt_x <= 4'b0000;
                end
                else if(in_cnt_x == 4'd10) begin
                    in_cnt_y <= in_cnt_y + 4'b0001;
                    in_cnt_x <= 4'b0000;
                end
                else begin
                    in_cnt_x <= in_cnt_x + 4'b0001;
                    in_cnt_y <= in_cnt_y;
                end
            end
            else
            begin
                in_cnt_x <= in_cnt_x;
                in_cnt_y <= in_cnt_y;        
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
        begin
            in_cnt_y_real <= 2'b00;
        end
        else begin
            if((!mode ) & work_flag)
            begin
                if(in_cnt_y_real == 2'b11 && in_cnt_x == 4'd10)
                begin
                    in_cnt_y_real <= 2'b00;
                end
                else if(in_cnt_x == 4'd10) begin
                    in_cnt_y_real <= in_cnt_y_real + 2'b01;
                end
                else begin
                    in_cnt_y_real <= in_cnt_y_real;
                end
            end
            else
            begin
                in_cnt_y_real <= in_cnt_y_real;        
            end
        end
    end



    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
        begin
            can_reg <= 1'b0;
        end
        else
        begin
            if(can_do && change3 && cnt_36 == 6'd35)
            begin
                can_reg <= 1'b0;
            end
            else if(in_cnt_x == 4'd5 && in_cnt_y == 4'd2)
            begin
                can_reg <= 1'b1;
            end
            else
            begin
                can_reg <= can_reg;
            end
        end
    end


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
        begin
            out_cnt_y_real <= 2'b0;
        end
        else begin
            if(can_do&&change3)
            begin
                if(ce && re)
                begin
                    out_cnt_y_real <=out_cnt_y_real+ 2'b1;
                end
                else if(re) begin
                    out_cnt_y_real <=out_cnt_y_real+ 2'b10;
                end
                else begin
                    out_cnt_y_real <= out_cnt_y_real;
                end
            end
            else
            begin
                out_cnt_y_real <= out_cnt_y_real;        
            end
        end
    end


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
        begin
            out_x0 <= 4'b0;
            out_y0 <= 4'b0;
        end
        else begin
            if(can_do&&change3)
            begin
                if(ce && re)
                begin
                    out_y0 <= 3'b0;
                    out_x0 <= 3'b0;
                end
                else if(re) begin
                    out_y0 <= out_y0 + 3'b001;
                    out_x0 <= 3'b0;
                end
                else begin
                    out_x0 <= out_x0 + 3'b001;
                    out_y0 <= out_y0;
                end
            end
            else
            begin
                out_x0 <= out_x0;
                out_y0 <= out_y0;        
            end
        end
    end


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
        begin
            cnt_36 <= 6'b0;
        end
        else begin
            if(can_do && change3)
            begin
                if(cnt_36 == 6'd35 )
                begin
                    cnt_36 <= 6'd0;
                end
                else begin
                    cnt_36 <= cnt_36 + 4'b001;
                end
            end
            else
            begin
                cnt_36 <= cnt_36;
            end
        end
    end




endmodule