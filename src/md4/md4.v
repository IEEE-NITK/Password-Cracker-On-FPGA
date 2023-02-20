`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.01.2023 13:22:01
// Design Name: 
// Module Name: md4
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


module md4(
    input clk,
    input reset,
    input input_data,
    input input_size,
    output reg [7:0]output_byte
    );
reg [31:0]A, B, C, D;
reg [7:0]rc;
reg [7:0]s1[0:3];
reg [7:0]s2[0:3];
reg [7:0]s3[0:3];
reg [7:0]k1[0:15];
reg [7:0]k2[0:15];
reg [7:0]k3[0:15];
reg [7:0]hash[0:15];
reg [2:0]FSM;
reg [7:0]data_block[0:63];
reg START, INPUT_READ, BUSY, DONE;
parameter IDLE_STATE = 3'b000;
parameter READ_STATE = 3'b001;
parameter PADDING_STATE = 3'b010;
parameter ROUND_1_STATE = 3'b011;
parameter ROUND_2_STATE = 3'b100;
parameter ROUND_3_STATE = 3'b101;
parameter ROUND_F_STATE = 3'b110;
parameter WRITE_STAGE = 3'b111;

//Functions which are used in further rounds of hashing the message
function [31:0]f;
input [31:0]x, y, z;
begin
f = ((x&y) | ((~x)&z));
end
endfunction

function [31:0]g;
input [31:0]x, y, z;
begin
g = ((x&y) | (y&z) | (x&z));
end
endfunction

function [31:0]h;
input x, y, z;
begin
h = (x^y^z);
end
endfunction

always @(posedge clk) begin
if(reset) begin
FSM <= IDLE_STATE;
INPUT_READ <= 1'b0;
BUSY <= 1'b0;
DONE <= 1'b0;
rc <= 0;

//Shift Variables
s1[0] = 8'h03;
s1[1] = 8'h07;
s1[2] = 8'h0b;
s1[3] = 8'h13;
s2[0] = 8'h03;
s2[1] = 8'h05;
s2[2] = 8'h09;
s2[3] = 8'h0d;
s3[0] = 8'h03;
s3[1] = 8'h09;
s3[2] = 8'h0b;
s3[3] = 8'h0f;

//Hash Variables
hash[8'h00] <= 8'h00; hash[8'h01] <= 8'h00; hash[8'h02] <= 8'h00; hash[8'h03] <= 8'h00; hash[8'h04] <= 8'h00; hash[8'h05] <= 8'h00; hash[8'h06] <= 8'h00; hash[8'h07] <= 8'h00;
hash[8'h08] <= 8'h00; hash[8'h09] <= 8'h00; hash[8'h0a] <= 8'h00; hash[8'h0b] <= 8'h00; hash[8'h0c] <= 8'h00; hash[8'h0d] <= 8'h00; hash[8'h0e] <= 8'h00; hash[8'h0f] <= 8'h00;

//Keys
k1[8'h00] = 8'h00; k1[8'h01] = 8'h01; k1[8'h02] = 8'h02; k1[8'h03] = 8'h03; k1[8'h04] = 8'h04; k1[8'h05] = 8'h05; k1[8'h06] = 8'h06; k1[8'h07] = 8'h07;
k1[8'h08] = 8'h08; k1[8'h09] = 8'h09; k1[8'h0a] = 8'h0a; k1[8'h0b] = 8'h0b; k1[8'h0c] = 8'h0c; k1[8'h0d] = 8'h0d; k1[8'h0e] = 8'h0e; k1[8'h0f] = 8'h0f;
k2[8'h00] = 8'h00; k2[8'h01] = 8'h04; k2[8'h02] = 8'h08; k2[8'h03] = 8'h0c; k2[8'h04] = 8'h01; k2[8'h05] = 8'h05; k2[8'h06] = 8'h09; k2[8'h07] = 8'h0d;
k2[8'h08] = 8'h02; k2[8'h09] = 8'h06; k2[8'h0a] = 8'h0a; k2[8'h0b] = 8'h0e; k2[8'h0c] = 8'h03; k2[8'h0d] = 8'h07; k2[8'h0e] = 8'h0b; k2[8'h0f] = 8'h0f;
k3[8'h00] = 8'h00; k3[8'h01] = 8'h08; k3[8'h02] = 8'h04; k3[8'h03] = 8'h0c; k3[8'h04] = 8'h02; k3[8'h05] = 8'h0a; k3[8'h06] = 8'h06; k3[8'h07] = 8'h0e;
k3[8'h08] = 8'h01; k3[8'h09] = 8'h09; k3[8'h0a] = 8'h05; k3[8'h0b] = 8'h0c; k3[8'h0c] = 8'h03; k3[8'h0d] = 8'h0b; k3[8'h0e] = 8'h07; k3[8'h0f] = 8'h0f;

//MD4 Buffers
A <= 32'h67452301;
B <= 32'hefcdab89;
C <= 32'h98badcfe;
D <= 32'h10325476;

data_block[8'h00] <= 8'h00; data_block[8'h01] <= 8'h00; data_block[8'h02] <= 8'h00; data_block[8'h03] <= 8'h00; data_block[8'h04] <= 8'h00; data_block[8'h05] <= 8'h00; data_block[8'h06] <= 8'h00; data_block[8'h07] <= 8'h00;
data_block[8'h08] <= 8'h00; data_block[8'h09] <= 8'h00; data_block[8'h0a] <= 8'h00; data_block[8'h0b] <= 8'h00; data_block[8'h0c] <= 8'h00; data_block[8'h0d] <= 8'h00; data_block[8'h0e] <= 8'h00; data_block[8'h0f] <= 8'h00;
data_block[8'h10] <= 8'h00; data_block[8'h11] <= 8'h00; data_block[8'h12] <= 8'h00; data_block[8'h13] <= 8'h00; data_block[8'h14] <= 8'h00; data_block[8'h15] <= 8'h00; data_block[8'h16] <= 8'h00; data_block[8'h17] <= 8'h00;
data_block[8'h18] <= 8'h00; data_block[8'h19] <= 8'h00; data_block[8'h1a] <= 8'h00; data_block[8'h1b] <= 8'h00; data_block[8'h1c] <= 8'h00; data_block[8'h1d] <= 8'h00; data_block[8'h1e] <= 8'h00; data_block[8'h1f] <= 8'h00;
data_block[8'h20] <= 8'h00; data_block[8'h21] <= 8'h00; data_block[8'h22] <= 8'h00; data_block[8'h23] <= 8'h00; data_block[8'h24] <= 8'h00; data_block[8'h25] <= 8'h00; data_block[8'h26] <= 8'h00; data_block[8'h27] <= 8'h00;
data_block[8'h28] <= 8'h00; data_block[8'h29] <= 8'h00; data_block[8'h2a] <= 8'h00; data_block[8'h2b] <= 8'h00; data_block[8'h2c] <= 8'h00; data_block[8'h2d] <= 8'h00; data_block[8'h2e] <= 8'h00; data_block[8'h2f] <= 8'h00;
data_block[8'h30] <= 8'h00; data_block[8'h31] <= 8'h00; data_block[8'h32] <= 8'h00; data_block[8'h33] <= 8'h00; data_block[8'h34] <= 8'h00; data_block[8'h35] <= 8'h00; data_block[8'h36] <= 8'h00; data_block[8'h37] <= 8'h00;
data_block[8'h38] <= 8'h00; data_block[8'h39] <= 8'h00; data_block[8'h3a] <= 8'h00; data_block[8'h3b] <= 8'h00; data_block[8'h3c] <= 8'h00; data_block[8'h3d] <= 8'h00; data_block[8'h3e] <= 8'h00; data_block[8'h3f] <= 8'h00; 
end
else begin
case(FSM)
IDLE_STATE: begin
if(START) begin
FSM <= READ_STATE;
BUSY <= 1;
end
end
READ_STATE: begin
if(rc < input_size && rc < 64) begin
data_block[rc] <= input_data;
rc <= rc + 1;
end
else begin
INPUT_READ <= 1;
FSM <= PADDING_STATE;
end
end
PADDING_STATE: begin
if(rc > 56 && rc != 64) begin
data_block[rc] <= 8'h80;
end
else begin
data_block[rc] <= 8'h80;
data_block[56] <= 8'h00;
data_block[57] <= 8'h00;
data_block[58] <= 8'h00;
data_block[59] <= 8'h00;
data_block[60] <= 8'h00;
data_block[61] <= 8'h00;
data_block[62] <= 8'h00;
data_block[63] <= 8'h00;
end
FSM <= ROUND_1_STATE;
end
endcase
end
end
endmodule