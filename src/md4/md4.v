`timescale 1ns / 1ps

module md4(
    input wire CLK,
    input wire RESET_N,
    input wire START_IN,
    output reg BUSY_OUT,
    output reg DONE_OUT,
    input wire [63:0] INPUT_SIZE_IN,
    input wire [7:0] INPUT_BYTE,
    input wire INPUT_EMPTY,
    output reg INPUT_READ,
    output reg [7:0] OUTPUT_BYTE,
    input wire OUTPUT_FULL,
    output reg OUTPUT_WRITE
);



    localparam [2:0]
        IDLE_STATE = 3'b000,
        READ_STATE = 3'b001,
        PADDING_STATE = 3'b010,
        ROUND_1_STATE = 3'b011,
        ROUND_2_STATE = 3'b100,
        ROUND_3_STATE = 3'b101,
        ROUND_F_STATE = 3'b110,
        WRITE_STAGE = 3'b111;
        
    reg [2:0] FSM;
    reg [31:0] hash_state [0:3];
    reg [31:0] hash_state_tmp [0:3];
    reg [7:0] hash [0:16];
    reg [63:0] input_size;
    reg [63:0] input_size_bits;
    reg [63:0] input_size_counter;
    reg [7:0] data_block [0:63];
    reg [7:0] read_counter;
    reg [7:0] write_counter;
    reg [7:0] round_counter;
    wire [7:0] inverse_counter;
    reg final_round;
    reg add_padding_block;
    reg reset_cycle;
    reg [7:0] s1 [0:3];
    reg [7:0] s2 [0:3];
    reg [7:0] s3 [0:3];
    reg [7:0] k1 [0:15];
    reg [7:0] k2 [0:15];
    reg [7:0] k3 [0:15];
    
    assign inverse_counter = ((16 - (round_counter)) %4);

    function [31:0] md4_F;
        input [31:0] X,Y,Z;
        begin
            md4_F = ((X & Y) | ((~X) & Z));
        end
    endfunction
    
    function [31:0] md4_G;
        input [31:0] X,Y,Z;
        begin
            md4_G = ((X & Y) | (X & Z) | (Y & Z));
        end
    endfunction
    
    function [31:0] md4_H;
        input [31:0] X,Y,Z;
        begin
            md4_H = (X ^ Y ^ Z);
        end
    endfunction
    
    always @(posedge CLK) begin
        if (!RESET_N || reset_cycle) begin

            FSM <= IDLE_STATE;
            INPUT_READ <= 1'b0;
            BUSY_OUT <= 1'b0;
            DONE_OUT <= 1'b0;
            OUTPUT_BYTE <= 8'h00;
            OUTPUT_WRITE <= 1'b0;
            input_size <= 64'h0000000000000000;
            input_size_bits <= 64'h0000000000000000;
            input_size_counter <= 32'h00000000;
            read_counter <= 8'h00;
            write_counter <= 8'h00;
            round_counter <= 8'h00;
            final_round <= 1'b0;
            add_padding_block <= 1'b0;
            reset_cycle <= 1'b0;

            hash[8'h00] <= 8'h00; hash[8'h01] <= 8'h00; hash[8'h02] <= 8'h00; hash[8'h03] <= 8'h00; hash[8'h04] <= 8'h00; hash[8'h05] <= 8'h00; hash[8'h06] <= 8'h00; hash[8'h07] <= 8'h00;
            hash[8'h08] <= 8'h00; hash[8'h09] <= 8'h00; hash[8'h0a] <= 8'h00; hash[8'h0b] <= 8'h00; hash[8'h0c] <= 8'h00; hash[8'h0d] <= 8'h00; hash[8'h0e] <= 8'h00; hash[8'h0f] <= 8'h00;

            hash_state[0] <= 32'h67452301;
            hash_state[1] <= 32'hefcdab89;
            hash_state[2] <= 32'h98badcfe;
            hash_state[3] <= 32'h10325476;
            hash_state_tmp[0] <= 32'h67452301;
            hash_state_tmp[1] <= 32'hefcdab89;
            hash_state_tmp[2] <= 32'h98badcfe;
            hash_state_tmp[3] <= 32'h10325476;

            s1[8'h00] <= 8'h03; s1[8'h01] <= 8'h07; s1[8'h02] <= 8'h0b; s1[8'h03] <= 8'h13;
            s2[8'h00] <= 8'h03; s2[8'h01] <= 8'h05; s2[8'h02] <= 8'h09; s2[8'h03] <= 8'h0d;
            s3[8'h00] <= 8'h03; s3[8'h01] <= 8'h09; s3[8'h02] <= 8'h0b; s3[8'h03] <= 8'h0f;

            k1[8'h00] <= 8'h00; k1[8'h01] <= 8'h01; k1[8'h02] <= 8'h02; k1[8'h03] <= 8'h03; k1[8'h04] <= 8'h04; k1[8'h05] <= 8'h05; k1[8'h06] <= 8'h06; k1[8'h07] <= 8'h07;
            k1[8'h08] <= 8'h08; k1[8'h09] <= 8'h09; k1[8'h0a] <= 8'h0a; k1[8'h0b] <= 8'h0b; k1[8'h0c] <= 8'h0c; k1[8'h0d] <= 8'h0d; k1[8'h0e] <= 8'h0e; k1[8'h0f] <= 8'h0f;
            k2[8'h00] <= 8'h00; k2[8'h01] <= 8'h04; k2[8'h02] <= 8'h08; k2[8'h03] <= 8'h0c; k2[8'h04] <= 8'h01; k2[8'h05] <= 8'h05; k2[8'h06] <= 8'h09; k2[8'h07] <= 8'h0d;
            k2[8'h08] <= 8'h02; k2[8'h09] <= 8'h06; k2[8'h0a] <= 8'h0a; k2[8'h0b] <= 8'h0e; k2[8'h0c] <= 8'h03; k2[8'h0d] <= 8'h07; k2[8'h0e] <= 8'h0b; k2[8'h0f] <= 8'h0f;
            k3[8'h00] <= 8'h00; k3[8'h01] <= 8'h08; k3[8'h02] <= 8'h04; k3[8'h03] <= 8'h0c; k3[8'h04] <= 8'h02; k3[8'h05] <= 8'h0a; k3[8'h06] <= 8'h06; k3[8'h07] <= 8'h0e;
            k3[8'h08] <= 8'h01; k3[8'h09] <= 8'h09; k3[8'h0a] <= 8'h05; k3[8'h0b] <= 8'h0c; k3[8'h0c] <= 8'h03; k3[8'h0d] <= 8'h0b; k3[8'h0e] <= 8'h07; k3[8'h0f] <= 8'h0f;

            data_block[8'h00] <= 8'h00; data_block[8'h01] <= 8'h00; data_block[8'h02] <= 8'h00; data_block[8'h03] <= 8'h00; data_block[8'h04] <= 8'h00; data_block[8'h05] <= 8'h00; data_block[8'h06] <= 8'h00; data_block[8'h07] <= 8'h00;
            data_block[8'h08] <= 8'h00; data_block[8'h09] <= 8'h00; data_block[8'h0a] <= 8'h00; data_block[8'h0b] <= 8'h00; data_block[8'h0c] <= 8'h00; data_block[8'h0d] <= 8'h00; data_block[8'h0e] <= 8'h00; data_block[8'h0f] <= 8'h00;
            data_block[8'h10] <= 8'h00; data_block[8'h11] <= 8'h00; data_block[8'h12] <= 8'h00; data_block[8'h13] <= 8'h00; data_block[8'h14] <= 8'h00; data_block[8'h15] <= 8'h00; data_block[8'h16] <= 8'h00; data_block[8'h17] <= 8'h00;
            data_block[8'h18] <= 8'h00; data_block[8'h19] <= 8'h00; data_block[8'h1a] <= 8'h00; data_block[8'h1b] <= 8'h00; data_block[8'h1c] <= 8'h00; data_block[8'h1d] <= 8'h00; data_block[8'h1e] <= 8'h00; data_block[8'h1f] <= 8'h00;
            data_block[8'h20] <= 8'h00; data_block[8'h21] <= 8'h00; data_block[8'h22] <= 8'h00; data_block[8'h23] <= 8'h00; data_block[8'h24] <= 8'h00; data_block[8'h25] <= 8'h00; data_block[8'h26] <= 8'h00; data_block[8'h27] <= 8'h00;
            data_block[8'h28] <= 8'h00; data_block[8'h29] <= 8'h00; data_block[8'h2a] <= 8'h00; data_block[8'h2b] <= 8'h00; data_block[8'h2c] <= 8'h00; data_block[8'h2d] <= 8'h00; data_block[8'h2e] <= 8'h00; data_block[8'h2f] <= 8'h00;
            data_block[8'h30] <= 8'h00; data_block[8'h31] <= 8'h00; data_block[8'h32] <= 8'h00; data_block[8'h33] <= 8'h00; data_block[8'h34] <= 8'h00; data_block[8'h35] <= 8'h00; data_block[8'h36] <= 8'h00; data_block[8'h37] <= 8'h00;
            data_block[8'h38] <= 8'h00; data_block[8'h39] <= 8'h00; data_block[8'h3a] <= 8'h00; data_block[8'h3b] <= 8'h00; data_block[8'h3c] <= 8'h00; data_block[8'h3d] <= 8'h00; data_block[8'h3e] <= 8'h00; data_block[8'h3f] <= 8'h00;           
        end else begin
            case(FSM)
                IDLE_STATE: begin
                    if (START_IN) begin
                        FSM <= READ_STATE;
                        BUSY_OUT <= 1'b1;
                        input_size <= INPUT_SIZE_IN;
                        input_size_bits <= INPUT_SIZE_IN *8;
                    end
                end
                READ_STATE: begin
                    if (read_counter < (input_size - input_size_counter) && read_counter < 64) begin
                        if (INPUT_EMPTY  && INPUT_READ) begin
                            data_block[read_counter] <= INPUT_BYTE;
                            read_counter <= read_counter +1;
                         end else  begin
                            INPUT_READ <= 1'b1;
                            data_block[8'h00] <= 8'h00; data_block[8'h01] <= 8'h00; data_block[8'h02] <= 8'h00; data_block[8'h03] <= 8'h00; data_block[8'h04] <= 8'h00; data_block[8'h05] <= 8'h00; data_block[8'h06] <= 8'h00; data_block[8'h07] <= 8'h00;
                            data_block[8'h08] <= 8'h00; data_block[8'h09] <= 8'h00; data_block[8'h0a] <= 8'h00; data_block[8'h0b] <= 8'h00; data_block[8'h0c] <= 8'h00; data_block[8'h0d] <= 8'h00; data_block[8'h0e] <= 8'h00; data_block[8'h0f] <= 8'h00;
                            data_block[8'h10] <= 8'h00; data_block[8'h11] <= 8'h00; data_block[8'h12] <= 8'h00; data_block[8'h13] <= 8'h00; data_block[8'h14] <= 8'h00; data_block[8'h15] <= 8'h00; data_block[8'h16] <= 8'h00; data_block[8'h17] <= 8'h00;
                            data_block[8'h18] <= 8'h00; data_block[8'h19] <= 8'h00; data_block[8'h1a] <= 8'h00; data_block[8'h1b] <= 8'h00; data_block[8'h1c] <= 8'h00; data_block[8'h1d] <= 8'h00; data_block[8'h1e] <= 8'h00; data_block[8'h1f] <= 8'h00;
                            data_block[8'h20] <= 8'h00; data_block[8'h21] <= 8'h00; data_block[8'h22] <= 8'h00; data_block[8'h23] <= 8'h00; data_block[8'h24] <= 8'h00; data_block[8'h25] <= 8'h00; data_block[8'h26] <= 8'h00; data_block[8'h27] <= 8'h00;
                            data_block[8'h28] <= 8'h00; data_block[8'h29] <= 8'h00; data_block[8'h2a] <= 8'h00; data_block[8'h2b] <= 8'h00; data_block[8'h2c] <= 8'h00; data_block[8'h2d] <= 8'h00; data_block[8'h2e] <= 8'h00; data_block[8'h2f] <= 8'h00;
                            data_block[8'h30] <= 8'h00; data_block[8'h31] <= 8'h00; data_block[8'h32] <= 8'h00; data_block[8'h33] <= 8'h00; data_block[8'h34] <= 8'h00; data_block[8'h35] <= 8'h00; data_block[8'h36] <= 8'h00; data_block[8'h37] <= 8'h00;
                            data_block[8'h38] <= 8'h00; data_block[8'h39] <= 8'h00; data_block[8'h3a] <= 8'h00; data_block[8'h3b] <= 8'h00; data_block[8'h3c] <= 8'h00; data_block[8'h3d] <= 8'h00; data_block[8'h3e] <= 8'h00; data_block[8'h3f] <= 8'h00;
                         end
                    end else begin
                        FSM <= PADDING_STATE;
                        INPUT_READ <= 1'b0;
                        input_size_counter = input_size_counter + read_counter;
                        
                        if ((input_size - input_size_counter) == 0) begin
                            final_round <= 1'b1;
                            FSM <= PADDING_STATE;
                        end else begin
                            final_round <= 1'b0;
                            FSM <= ROUND_1_STATE;
                        end
                    end
                end
                PADDING_STATE: begin
                    if (read_counter > 56) begin
                        add_padding_block <= 1'b1;
                        if (read_counter != 64)
                            data_block[read_counter] <= 8'h80;
                    end else begin
                        add_padding_block <= 1'b0;
                        data_block[read_counter] <= 8'h80;
                        data_block[56] <= input_size_bits[07:00];
                        data_block[57] <= input_size_bits[15:08];
                        data_block[58] <= input_size_bits[23:16];
                        data_block[59] <= input_size_bits[31:24];
                        data_block[60] <= input_size_bits[39:32];
                        data_block[61] <= input_size_bits[47:40];
                        data_block[62] <= input_size_bits[55:48];
                        data_block[63] <= input_size_bits[63:56];
                    end
                    FSM <= ROUND_1_STATE;
                end
                ROUND_1_STATE: begin
                    if (round_counter < 16) begin
                        round_counter <= round_counter +1;
                        hash_state_tmp[inverse_counter] <=  ((hash_state_tmp[inverse_counter] + md4_F(hash_state_tmp[(inverse_counter +1) % 4], hash_state_tmp[(inverse_counter +2) % 4], hash_state_tmp[(inverse_counter +3) % 4]) + ({data_block[k1[(round_counter)]*4+3], data_block[k1[(round_counter)]*4+2], data_block[k1[(round_counter)]*4+1], data_block[k1[(round_counter)]*4]})) << s1[round_counter %4] | (hash_state_tmp[inverse_counter] + md4_F(hash_state_tmp[(inverse_counter +1) % 4], hash_state_tmp[(inverse_counter +2) % 4], hash_state_tmp[(inverse_counter +3) % 4]) + ({data_block[k1[(round_counter)]*4+3], data_block[k1[(round_counter)]*4+2], data_block[k1[(round_counter)]*4+1], data_block[k1[(round_counter)]*4]}))  >> (32-s1[round_counter %4]));

                    end else begin
                        round_counter <= 0;
                        FSM <= ROUND_2_STATE;
                    end
                end
                ROUND_2_STATE: begin
                    if (round_counter < 16) begin
                        round_counter <= round_counter +1;
                        hash_state_tmp[inverse_counter] <=  (((hash_state_tmp[inverse_counter] + md4_G(hash_state_tmp[(inverse_counter +1) % 4], hash_state_tmp[(inverse_counter +2) % 4], hash_state_tmp[(inverse_counter +3) % 4]) + ({data_block[k2[(round_counter)]*4+3], data_block[k2[(round_counter)]*4+2], data_block[k2[(round_counter)]*4+1], data_block[k2[(round_counter)]*4]})) + 32'h5a827999) << s2[round_counter %4] | ((hash_state_tmp[inverse_counter] + md4_G(hash_state_tmp[(inverse_counter +1) % 4], hash_state_tmp[(inverse_counter +2) % 4], hash_state_tmp[(inverse_counter +3) % 4]) + ({data_block[k2[(round_counter)]*4+3], data_block[k2[(round_counter)]*4+2], data_block[k2[(round_counter)]*4+1], data_block[k2[(round_counter)]*4]})) + 32'h5a827999) >> (32-s2[round_counter %4]));
                    end else begin
                        round_counter <= 0;
                        FSM <= ROUND_3_STATE;
                    end
                end
                ROUND_3_STATE: begin
                    if (round_counter < 16) begin
                        round_counter <= round_counter +1;
                        hash_state_tmp[inverse_counter] <=  (((hash_state_tmp[inverse_counter] + md4_H(hash_state_tmp[(inverse_counter +1) % 4], hash_state_tmp[(inverse_counter +2) % 4], hash_state_tmp[(inverse_counter +3) % 4]) + ({data_block[k3[(round_counter)]*4+3], data_block[k3[(round_counter)]*4+2], data_block[k3[(round_counter)]*4+1], data_block[k3[(round_counter)]*4]})) + 32'h6ed9eba1) << s3[round_counter %4] | ((hash_state_tmp[inverse_counter] + md4_H(hash_state_tmp[(inverse_counter +1) % 4], hash_state_tmp[(inverse_counter +2) % 4], hash_state_tmp[(inverse_counter +3) % 4]) + ({data_block[k3[(round_counter)]*4+3], data_block[k3[(round_counter)]*4+2], data_block[k3[(round_counter)]*4+1], data_block[k3[(round_counter)]*4]})) + 32'h6ed9eba1) >> (32-s3[round_counter %4]));
                    end else begin
                        round_counter <= 0;
                        FSM <= ROUND_F_STATE;
                    end
                end
                ROUND_F_STATE: begin
                    if (round_counter < 4) begin
                        round_counter <= round_counter +1;
                        hash_state_tmp[round_counter] <= hash_state[round_counter] + hash_state_tmp[round_counter];
                        hash_state[round_counter] = hash_state[round_counter] + hash_state_tmp[round_counter];
                        hash[(round_counter*4)] = hash_state[round_counter][07:00];
                        hash[(round_counter*4) +1] = hash_state[round_counter][15:08];
                        hash[(round_counter*4) +2] = hash_state[round_counter][23:16];
                        hash[(round_counter*4) +3] = hash_state[round_counter][31:24];
                       
                    end else begin
                        round_counter <= 0;
                        read_counter <= 0;

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
                        if (OUTPUT_FULL) begin
                            OUTPUT_BYTE <= hash[write_counter];
                            write_counter <= write_counter +1;
                            OUTPUT_WRITE = 1'b1;
                        end else
                            OUTPUT_WRITE = 1'b0;
                    end else begin
                        OUTPUT_WRITE = 1'b0;
                        DONE_OUT <= 1'b1;
                        reset_cycle <= 1'b1;
                    end
                end
            endcase
        end
    end
endmodule