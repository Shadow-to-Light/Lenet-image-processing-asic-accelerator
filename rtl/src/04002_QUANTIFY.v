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
QUANTIFY
2025 Annotation

Description:
- This module quantizes the 21-bit signed input to an 8-bit signed output.
*/

module QUANTIFY (
    input                   clk,
    input  signed [20:0]    quantify_in ,
    output reg    [7:0]     quantify_out
);

    reg         [7:0]   result;
    wire signed [12:0]  truncation;

    // It is very important to use the regsiter to isolate combinational logic from subsequent circuits.
    always @(posedge clk) begin
        quantify_out <= result;
    end

    assign truncation = quantify_in[20:8];

    always @(*) begin
        if (truncation > 127) begin
        // beyond the positive range, set to 127
            result = 8'b0111_1111;
        end else if (truncation < -128) begin
        // beyond the negative range, set to -128
            result = 8'b1000_0000;
        end else begin
            result = {truncation[12],truncation[6:0]}; // The normal case, just take the lower 8 bits.
        end
    end

endmodule