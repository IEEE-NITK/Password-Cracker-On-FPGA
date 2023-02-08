`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.11.2022 14:20:26
// Design Name: 
// Module Name: cu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cu(input clk, reset, input [255:0] data, input [63:0]data_length, output [255:0] Hash_Digest, output overflow_err, output hashing_done);
    reg byte_rdy, byte_stop;
    reg [7:0] data_in;
    reg [255:0] data_str;
    reg [255:0] data_rev_str;
    reg rst;
    reg [1:0] state;
    reg [63:0] input_length;
    top_sha sha256cu(clk,rst,byte_rdy,byte_stop,data_in [7:0],
					overflow_err,Hash_Digest, hashing_done);
    always @(posedge clk)begin
    if(reset==0) begin
        input_length <=data_length;
        byte_rdy <=0;
        byte_stop <=0;
        rst<=0;
        state<=0;
        data_str<=0;
        data_rev_str<=0;
        data_in<=0;
    end
    else begin
        if(state==2)begin
            rst <=1;
            if(input_length>0) begin
                byte_rdy <=1;
                data_in <= data_str[7:0];
                input_length <= input_length-1;
                data_str <= data_str >> 8;
            end
            else begin
            byte_rdy <=0;
            byte_stop <=1;
            end
        end else begin
            if(state==1)begin
                if(input_length>0) begin
                    data_str = data_str << 8;
                    data_str  = data_str +  data_rev_str[7:0];
                    data_rev_str = data_rev_str  >> 8;
                    input_length = input_length-1;
                end else begin
                    state<=2;
                    rst<=1;
                    input_length <= data_length;
                end
            end else begin
            rst<=0;
            state<=1;
            data_rev_str <= data;
            input_length <= data_length;
            end
        end 
        end
    end
    
endmodule
