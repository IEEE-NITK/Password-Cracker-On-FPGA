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
    input wire output_full,
    output reg [7:0]output_byte,
    output reg output_write
    );
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
reg [63:0]zero_bits;
reg [31:0] hash_state [0:3]; //A, B, C, D
reg [31:0] hash_state_tmp [0:3];
reg add_padding_block;
reg [7:0] write_counter;
reg [7:0] round_counter;
reg START, INPUT_READ, BUSY, DONE;
wire [7:0]inverse_counter;
reg final_round;
parameter IDLE_STATE = 3'b000;
parameter READ_STATE = 3'b001;
parameter PADDING_STATE = 3'b010;
parameter ROUND_1_STATE = 3'b011;
parameter ROUND_2_STATE = 3'b100;
parameter ROUND_3_STATE = 3'b101;
parameter ROUND_F_STATE = 3'b110;
parameter WRITE_STAGE = 3'b111;

assign inverse_counter = ((16 - (round_counter)) %4);
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
zero_bits <= 64'h0000000000000000;
//input_size_counter <= 32'h00000000;
write_counter <= 8'h00;
round_counter <= 8'h00;
final_round <= 1'b0;
add_padding_block <= 1'b0;

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
hash_state[0] <= 32'h67452301;
hash_state[1] <= 32'hefcdab89;
hash_state[2] <= 32'h98badcfe;
hash_state[3] <= 32'h10325476;
hash_state_tmp[0] <= 32'h67452301;
hash_state_tmp[1] <= 32'hefcdab89;
hash_state_tmp[2] <= 32'h98badcfe;
hash_state_tmp[3] <= 32'h10325476;

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
                    // CHECK IF PADDING IS NEEDED (LAST BLOCK)
                    if (rc > 56) begin
                        add_padding_block <= 1'b1;
                        if (rc != 64)
                            data_block[rc] <= 8'h80;
                    end else begin
                        // TODO ADD PADDING
                        add_padding_block <= 1'b0;
                        data_block[rc] <= 8'h80;
                        data_block[56] <= zero_bits[07:00];
                        data_block[57] <= zero_bits[15:08];
                        data_block[58] <= zero_bits[23:16];
                        data_block[59] <= zero_bits[31:24];
                        data_block[60] <= zero_bits[39:32];
                        data_block[61] <= zero_bits[47:40];
                        data_block[62] <= zero_bits[55:48];
                        data_block[63] <= zero_bits[63:56];
                    end
                    FSM <= ROUND_1_STATE;
                end
                ROUND_1_STATE: begin
                    if (rc < 16) begin
                        rc <= rc +1;
                        hash_state_tmp[inverse_counter] <=  ((hash_state_tmp[inverse_counter] + f(hash_state_tmp[(inverse_counter +1) % 4], hash_state_tmp[(inverse_counter +2) % 4], hash_state_tmp[(inverse_counter +3) % 4]) + ({data_block[k1[(rc)]*4+3], data_block[k1[(rc)]*4+2], data_block[k1[(rc)]*4+1], data_block[k1[(rc)]*4]})) << s1[rc %4] | (hash_state_tmp[inverse_counter] + md4_F(hash_state_tmp[(inverse_counter +1) % 4], hash_state_tmp[(inverse_counter +2) % 4], hash_state_tmp[(inverse_counter +3) % 4]) + ({data_block[k1[(rc)]*4+3], data_block[k1[(rc)]*4+2], data_block[k1[(rc)]*4+1], data_block[k1[(rc)]*4]}))  >> (32-s1[rc %4]));

                    end else begin
                        rc <= 0;
                        FSM <= ROUND_2_STATE;
                    end
                end
                ROUND_2_STATE: begin
                    if (rc < 16) begin
                        rc <= rc +1;
                        hash_state_tmp[inverse_counter] <=  (((hash_state_tmp[inverse_counter] + md4_G(hash_state_tmp[(inverse_counter +1) % 4], hash_state_tmp[(inverse_counter +2) % 4], hash_state_tmp[(inverse_counter +3) % 4]) + ({data_block[k2[(rc)]*4+3], data_block[k2[(rc)]*4+2], data_block[k2[(rc)]*4+1], data_block[k2[(rc)]*4]})) + 32'h5a827999) << s2[rc %4] | ((hash_state_tmp[inverse_counter] + md4_G(hash_state_tmp[(inverse_counter +1) % 4], hash_state_tmp[(inverse_counter +2) % 4], hash_state_tmp[(inverse_counter +3) % 4]) + ({data_block[k2[(rc)]*4+3], data_block[k2[(rc)]*4+2], data_block[k2[(rc)]*4+1], data_block[k2[(rc)]*4]})) + 32'h5a827999) >> (32-s2[rc %4]));
                    end else begin
                        rc <= 0;
                        FSM <= ROUND_3_STATE;
                    end
                end
                ROUND_3_STATE: begin
                    if (fc < 16) begin
                        rc <= rc +1;
                        hash_state_tmp[inverse_counter] <=  (((hash_state_tmp[inverse_counter] + md4_H(hash_state_tmp[(inverse_counter +1) % 4], hash_state_tmp[(inverse_counter +2) % 4], hash_state_tmp[(inverse_counter +3) % 4]) + ({data_block[k3[(rc)]*4+3], data_block[k3[(rc)]*4+2], data_block[k3[(rc)]*4+1], data_block[k3[(rc)]*4]})) + 32'h6ed9eba1) << s3[rc %4] | ((hash_state_tmp[inverse_counter] + md4_H(hash_state_tmp[(inverse_counter +1) % 4], hash_state_tmp[(inverse_counter +2) % 4], hash_state_tmp[(inverse_counter +3) % 4]) + ({data_block[k3[(rc)]*4+3], data_block[k3[(rc)]*4+2], data_block[k3[(rc)]*4+1], data_block[k3[(rc)]*4]})) + 32'h6ed9eba1) >> (32-s3[rc %4]));
                    end else begin
                        rc <= 0;
                        FSM <= ROUND_F_STATE;
                    end
                end
                ROUND_F_STATE: begin
                    if (rc < 4) begin
                        rc <= rc +1;
                        hash_state_tmp[rc] <= hash_state[rc] + hash_state_tmp[rc];
                        hash_state[rc] = hash_state[rc] + hash_state_tmp[rc];
                        hash[(rc*4)] = hash_state[rc][07:00];
                        hash[(rc*4) +1] = hash_state[rc][15:08];
                        hash[(rc*4) +2] = hash_state[rc][23:16];
                        hash[(rc*4) +3] = hash_state[rc][31:24];
                       
                    end else begin
                        rc <= 0;
                        rc <= 0;

                        if (final_round) begin
                            if (add_padding_block) begin
                                FSM <= PADDING_STATE;
                            end else begin
                                FSM <= WRITE_STAGE;
                            end
                        end else begin
                            FSM <= READ_STATE;
                        end
                    end
                end
                WRITE_STAGE: begin
                    if(write_counter < 16) begin
                        if (output_full) begin
                            output_byte <= hash[write_counter];
                            write_counter <= write_counter +1;
                            output_write = 1'b1;
                        end else
                            output_write = 1'b0;
                    end else begin
                        output_write = 1'b0;
                        DONE <= 1'b1;
                        //reset_cycle <= 1'b1;
                    end
                end
            endcase
        end
    end // STOP MAIN BLOCK
endmodule // STOP MD4
