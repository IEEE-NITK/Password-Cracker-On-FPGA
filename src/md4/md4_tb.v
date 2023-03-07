`timescale 1ns / 1ps

module md4_tb;
    reg CLK;
    reg RESET_N;
    integer x, error;
    parameter DATA_SIZE=1;
    parameter HASH_SIZE=16;
    
    reg [7:0] data [0:255];
    reg [15:0] data_counter;
    reg [7:0] hash [0:15];
    reg [7:0] hash_counter;
    reg [7:0] known_hash [0:15];

    reg MD4_START;
    wire MD4_BUSY;
    wire MD4_DONE;
    reg [63:0] MD4_DATA_SIZE;

    reg [7:0] MD4_DATA_BYTE;
    reg MD4_DATA_EMPTY;
    wire MD4_DATA_READ;
    wire [7:0] MD4_HASH_BYTE;
    reg MD4_HASH_FULL;
    wire MD4_HASH_WRITE;
    
    md4 md4_interface(
        .CLK(CLK),
        .RESET_N(RESET_N),

        .START_IN(MD4_START),
        .BUSY_OUT(MD4_BUSY),
        .DONE_OUT(MD4_DONE),
        .INPUT_SIZE_IN(MD4_DATA_SIZE),

        .INPUT_BYTE(MD4_DATA_BYTE),
        .INPUT_EMPTY(MD4_DATA_EMPTY),

        .OUTPUT_BYTE(MD4_HASH_BYTE),
        .OUTPUT_FULL(MD4_HASH_FULL),
        .OUTPUT_WRITE(MD4_HASH_WRITE)
    );

    always
    begin
        CLK = 1'b0; 
        #1;
        CLK = 1'b1;
        #1;
    end

    always @(posedge CLK) begin
        if (MD4_DATA_READ) begin
            if (data_counter == MD4_DATA_SIZE) begin
                data_counter <= 0;
                MD4_DATA_BYTE <= 8'b00;
            end
            else begin
                data_counter <= data_counter +1;
                MD4_DATA_BYTE <= data[data_counter];
            end
        end
    end

    always @(posedge CLK) begin
        if (MD4_HASH_WRITE) begin
            hash[hash_counter] <= MD4_HASH_BYTE;
            if (hash_counter == HASH_SIZE-1)
                hash_counter <= 0;
            else
                hash_counter <= hash_counter +1;
        end
    end

    always @(posedge CLK) begin
        if (MD4_DONE) begin
            MD4_START = 0;
        end
    end

    initial begin

        RESET_N = 0;
        x = 0;
        error = 0;
        hash_counter = 0;
        MD4_DATA_SIZE = DATA_SIZE;   
        MD4_DATA_EMPTY = 1;
        MD4_HASH_FULL = 1;
        
        data[8'h00] = 8'h01;// data[8'h01] = 8'h11; data[8'h02] = 8'h11; data[8'h03] = 8'h11; data[8'h04] = 8'h11; data[8'h05] = 8'h11; data[8'h06] = 8'h11; data[8'h07] = 8'h11;
        //data[8'h08] = 8'h11; data[8'h09] = 8'h11; data[8'h0a] = 8'h11; data[8'h0b] = 8'h11; data[8'h0c] = 8'h11; data[8'h0d] = 8'h11; data[8'h0e] = 8'h11; data[8'h0f] = 8'h11;

        for (x=0; x < HASH_SIZE; x = x+1)
        begin
            hash[x] = 0;
        end
        
        data_counter = 1;
        MD4_DATA_BYTE = data[8'h00];

        #5;
        RESET_N = 1;
        #1;
        MD4_START = 1;
        #4500;
        for (x=0; x < HASH_SIZE; x = x+1)
        begin
            if (known_hash[x] != hash[x])
            begin
                $display("[!] The known ciphertext does not match the captured ciphertext --> Element ID: %d / Known: 0x%H / Captured: 0x%H ", x, hash[x], hash[x]);
                error = error +1;
            end
        end

        $display("---- ---- ---- ---- ---- ---- ---- ---- ---- RESULT ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----");
        if (error == 0)
            $display("[*] ... PASSED ...");
        else
            $display("[!] ... FAILED ...");
        $display("---- ---- ---- ---- ---- ---- ---- ---- ---- RESULT ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----");
        $stop;
    end
endmodule