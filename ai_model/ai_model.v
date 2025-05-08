// behavioral module 
// designed by WYW
// 2023-12-3
// 2024-11-19 update

// `define CO_VALUE
// `define QU_VALUE
// `define PO_VALUE
// `define FC_VALUE
// `define QF_VALUE
`define DATA_NUM 100

module uestc_AI_module;

reg signed [7:0] img  [0:12099];         // 1 img 11x11
initial begin
    $readmemb ("./data.txt",img);
end

reg signed [7:0] wht       [0:53];
reg signed [7:0] wht_conv  [0:26];    // 3x3x3   weight  for convolution
reg signed [7:0] wht_fc    [0:26];    // 3x3x3   weight  for full connection
initial begin
    $readmemb ("./weight.txt",wht);
    wht_conv = wht[0:26];
    wht_fc   = wht[27:53];
end


reg signed [7:0] answer  [0:99];     // answer
initial begin
    $readmemb ("./output.txt",answer);
end

//*********************************CNN flow ************

    integer img_nu;  // img number(0-99)
    integer i;

    reg signed [7:0]    img_tmp [0:120]; //11*11
    reg signed [7:0]    img_tmp_padding [0:168]; //13*13
    reg signed [19:0]   conv0   [0:35];
    reg signed [19:0]   conv1   [0:35];
    reg signed [19:0]   conv2   [0:35];
    reg signed [7:0]    quanti0 [0:35];
    reg signed [7:0]    quanti1 [0:35];
    reg signed [7:0]    quanti2 [0:35];

    reg signed [7:0]    pool0   [0:8];  
    reg signed [7:0]    pool1   [0:8];  
    reg signed [7:0]    pool2   [0:8];  

    reg signed [19:0]   result0,result1,result2;
    reg signed [20:0]   result;
    reg signed [7:0]    result_out;


initial begin


    for (img_nu=0;img_nu<`DATA_NUM;img_nu=img_nu+1) begin
        get_one_img(img_nu,img_tmp[0:120]); //11*11
    
        padding(img_tmp[0:120],img_tmp_padding [0:168]); //11*11 -> 13*13

    // convoluton (3 layers)
        conv_task(img_tmp_padding[0:168],wht_conv[0:8],  conv0[0:35]);    // conv layer0
        conv_task(img_tmp_padding[0:168],wht_conv[9:17], conv1[0:35]);    // conv layer1
        conv_task(img_tmp_padding[0:168],wht_conv[18:26],conv2[0:35]);    // conv layer2

    // quantization
        quanti_task(conv0[0:35],quanti0[0:35]);
        quanti_task(conv1[0:35],quanti1[0:35]);
        quanti_task(conv2[0:35],quanti2[0:35]);

    // pooling   
        pool_task(quanti0[0:35],pool0[0:8]);    
        pool_task(quanti1[0:35],pool1[0:8]);    
        pool_task(quanti2[0:35],pool2[0:8]);  

    // full_connection (3 layers)
        fc_task(pool0[0:8],wht_fc[0:8]  ,result0);
        fc_task(pool1[0:8],wht_fc[9:17] ,result1);
        fc_task(pool2[0:8],wht_fc[18:26],result2); 

        result = {result0[19],{result0}}+{result1[19],{result1}}+{result2[19],{result2}};
    // quantization_fc
        quanti_task_fc(result,result_out);

    // check result
        if(result_out == answer[img_nu])
            $display ("result_out= %b ; answer = %b",result_out,answer[img_nu],"   ***** PASS *****");
        else   $display ("result_out= %b ; answer = %b",result_out,answer[img_nu],"   ***** FAIL *****");
end
end


//******below are tasks for each operation********************* 
// convolution --1 layer
task conv_task;
    input   signed [7:0]   img       [0:168]; //13*13
    input   signed [7:0]   wht_conv  [0:8]; 
    output  signed [19:0]  conv     [0:35]; //6*6

    reg signed [19:0] sum ;
    reg signed [15:0] temp          [0:8];
    reg signed [19:0] temp_20bit    [0:8];
    integer size = 13;
    integer i,j;
integer k;
    begin
        for (j=0;j<=5;j=j+1) begin          // 6 columns
            for (i=0;i<=5;i=i+1) begin      // 6 rows
                sum =0;
                temp[0] = img[0+i*2+j*2*13]        * wht_conv[0];   
                temp[1] = img[1+i*2+j*2*13]        * wht_conv[1];   
                temp[2] = img[2+i*2+j*2*13]        * wht_conv[2];   
                temp[3] = img[0+size+i*2+j*2*13]   * wht_conv[3];   
                temp[4] = img[1+size+i*2+j*2*13]   * wht_conv[4];   
                temp[5] = img[2+size+i*2+j*2*13]   * wht_conv[5];    
                temp[6] = img[0+size*2+i*2+j*2*13] * wht_conv[6];   
                temp[7] = img[1+size*2+i*2+j*2*13] * wht_conv[7];   
                temp[8] = img[2+size*2+i*2+j*2*13] * wht_conv[8];  
                // $display (img[0+i*2+j*2*13],img[1+i*2+j*2*13],img[2+i*2+j*2*13]);
                // $display (img[0+size+i*2+j*2*13],img[1+size+i*2+j*2*13],img[2+size+i*2+j*2*13]);
                // $display (img[0+size*2+i*2+j*2*13],img[1+size*2+i*2+j*2*13],img[2+size*2+i*2+j*2*13]);
                temp_20bit[0] = {{4{temp[0][15]}},{temp[0]}};
                temp_20bit[1] = {{4{temp[1][15]}},{temp[1]}};
                temp_20bit[2] = {{4{temp[2][15]}},{temp[2]}};
                temp_20bit[3] = {{4{temp[3][15]}},{temp[3]}};
                temp_20bit[4] = {{4{temp[4][15]}},{temp[4]}};
                temp_20bit[5] = {{4{temp[5][15]}},{temp[5]}};
                temp_20bit[6] = {{4{temp[6][15]}},{temp[6]}};
                temp_20bit[7] = {{4{temp[7][15]}},{temp[7]}};
                temp_20bit[8] = {{4{temp[8][15]}},{temp[8]}};
                sum = temp_20bit[0]+temp_20bit[1]+temp_20bit[2]+temp_20bit[3]+temp_20bit[4]+temp_20bit[5]+temp_20bit[6]+temp_20bit[7]+temp_20bit[8];
                conv[i+j*6] = sum;          
                `ifdef CO_VALUE            $display ("conv[",i+j*6,"]= %d",sum);  `endif
            end
        end   
    end

endtask

//quantization
task quanti_task;
    input signed      [19:0] conv         [0:35];
    output reg signed [7:0]  quanti       [0:35]; 
    reg signed        [11:0] quanti_ext   [0:35];
    integer i;
    begin

    for (i=0;i<=35;i=i+1) begin
        quanti_ext[i]   = conv[i][19:8];
        if (quanti_ext[i] > 127) 
            quanti[i]     = 127;
        else if (quanti_ext[i] < -128) 
            quanti[i]     = -128;    
        else       
            quanti[i] ={{quanti_ext[i][11]},{quanti_ext[i][6:0]}};      
        `ifdef QU_VALUE $display ("quanti[",i,"]= %d %d",quanti_ext[i],quanti[i]); `endif  
    end
    end
endtask

//pooling(max)
task pool_task;
input signed      [7:0] quanti [0:35];
output reg signed [7:0] pool   [0:8];  

reg signed [7:0] tmp1,tmp2,tmp;
begin
integer i,j;
            for (j=0;j<=2;j=j+1) begin
                for (i=0;i<=2;i=i+1) begin
                    tmp1 = (quanti[0+i*2+j*12] > quanti[1+i*2+j*12]) ? quanti[0+i*2+j*12]:quanti[1+i*2+j*12];
                    tmp2 = (quanti[6+i*2+j*12] > quanti[7+i*2+j*12]) ? quanti[6+i*2+j*12]:quanti[7+i*2+j*12];
                    pool[i+j*3] = (tmp1 > tmp2) ? tmp1:tmp2;
 `ifdef PO_VALUE       $display ("pool[",i+j*3,"]=%d", pool[i+j*3]);  `endif
                end
            end
end
endtask


// full_connection --1 layer
task fc_task;
    input signed   [7:0]  pool    [0:8];  
    input signed   [7:0]  wht_fc  [0:8]; 
    output  signed [19:0] result; 

    reg  signed [19:0]  sum ;
    reg  signed [15:0]  temp;
    reg  signed [19:0]  temp_20bit;

    integer i;

    begin
        sum =0;
        for (i=0;i<=8;i=i+1) begin    
                temp          = pool[i] * wht_fc[i];   
                temp_20bit    = {{4{temp[15]}},{temp}};
            sum = sum + temp_20bit;

        `ifdef FC_VALUE            $display ("sum[",i,"]= %b",sum);  `endif 
        end
        result = sum;
    end

endtask

//quantization fc
task quanti_task_fc;
    input signed      [20:0] conv;
    output reg signed [7:0]  quanti; 
    reg signed        [12:0] quanti_ext;
    begin
        quanti_ext  = conv[20:8];
            if (quanti_ext > 127) 
                quanti     = 127;
            else if (quanti_ext < -128) 
                quanti     = -128;    
            else       
              quanti ={{quanti_ext[12]},{quanti_ext[6:0]}};      
`ifdef QF_VALUE    $display ("quanti= %b %b ",quanti_ext,quanti); `endif             
    end
endtask

// copy 1 img from 100
task get_one_img;
input  integer img_nu;
output reg signed [7:0] img_out [0:120];
integer i;
    begin
        for (i=0; i <=120; i=i+1) begin 
            img_out[i] = img[i+img_nu*121]; 
        end
    end
endtask

// Padding task
task padding(
    input signed [7:0] img_in[0:120],
    output reg signed [7:0] img_out[0:168]
);
    integer i, j; // 用于遍历的循环变量
    begin
        // 初始化输出图像为零
        for (i = 0; i < 13; i = i + 1) begin
            for (j = 0; j < 13; j = j + 1) begin
                img_out[i * 13 + j] = 8'd0;
            end
        end

        // 将输入图像复制到中心区域
        for (i = 0; i < 11; i = i + 1) begin
            for (j = 0; j < 11; j = j + 1) begin
                img_out[(i + 1) * 13 + (j + 1)] = img_in[i * 11 + j];
            end
        end
    end
endtask

endmodule