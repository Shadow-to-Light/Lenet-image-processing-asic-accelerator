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
POOL
2025 Annotation

Description:
- This module implements the max pooling operation for CNN data. 4 8-bit --> 1 8-bit.
*/

module  POOL(
    input   [31:0]  cnn_data,
    output  [7:0]   pool_data        
);
    wire    signed [7:0] comp00[3:0];
    wire    signed [7:0] comp01[1:0];

    assign  {comp00[3],comp00[2],comp00[1],comp00[0]} = cnn_data;
    assign  pool_data = (comp01[1] > comp01[0]) ? comp01[1] : comp01[0];
    assign  comp01[0] = (comp00[1] > comp00[0]) ? comp00[1] : comp00[0];
    assign  comp01[1] = (comp00[3] > comp00[2]) ? comp00[3] : comp00[2];

endmodule