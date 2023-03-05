`timescale 1ns / 1ps

module md4_tb;
    reg CLK;
    reg RESET_N;
    integer x, error;
    parameter DATA_SIZE=16;
    parameter HASH_SIZE=16;
    
    reg [7:0] data [0:255];
    reg [15:0] data_counter;
    reg [7:0] hash [0:15];
    reg [7:0] hash_counter;
    reg [7:0] known_hash [0:15];
    
    
    
    // ---- ---- ---- ---- ---- ---- ---- ----
    //              MD4 INTERFACE
    // ---- ---- ---- ---- ---- ---- ---- ----
    reg MD4_START;
    wire MD4_BUSY;
    wire MD4_DONE;
    reg [63:0] MD4_DATA_SIZE;
    // FIFOs
    reg [7:0] MD4_DATA_BYTE;
    reg MD4_DATA_EMPTY;
    wire MD4_DATA_READ;
    wire [7:0] MD4_HASH_BYTE;
    reg MD4_HASH_FULL;
    wire MD4_HASH_WRITE;
    
    md4 md4_interface(
        .CLK(CLK),
        .RESET_N(RESET_N),
        // CONTROL
        .START_IN(MD4_START),
        .BUSY_OUT(MD4_BUSY),
        .DONE_OUT(MD4_DONE),
        .INPUT_SIZE_IN(MD4_DATA_SIZE),
        // INPUT FIFO
        .INPUT_BYTE(MD4_DATA_BYTE),
        .INPUT_EMPTY(MD4_DATA_EMPTY),
        .INPUT_READ(MD4_DATA_READ),
        // OUTPUT FIFO
        .OUTPUT_BYTE(MD4_HASH_BYTE),
        .OUTPUT_FULL(MD4_HASH_FULL),
        .OUTPUT_WRITE(MD4_HASH_WRITE)
    ); // STOP MD4
    
    
    
    // ---- ---- ---- ---- ---- ---- ---- ----
    //                  CLOCK
    // ---- ---- ---- ---- ---- ---- ---- ----
    always
    begin
        CLK = 1'b0; 
        #1;
        CLK = 1'b1;
        #1;
    end // STOP CLOCK
    
    
    
    // ---- ---- ---- ---- ---- ---- ---- ----
    //              DATA TRANSFARE
    // ---- ---- ---- ---- ---- ---- ---- ----
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
    end // STOP DATA TRANSFARE
    
    
    
    // ---- ---- ---- ---- ---- ---- ---- ----
    //              HASH TRNASFARE
    // ---- ---- ---- ---- ---- ---- ---- ----
    always @(posedge CLK) begin
        if (MD4_HASH_WRITE) begin
            hash[hash_counter] <= MD4_HASH_BYTE;
            if (hash_counter == HASH_SIZE-1)
                hash_counter <= 0;
            else
                hash_counter <= hash_counter +1;
        end
    end // STOP HASH TRANSFARE
    
    
    
    // ---- ---- ---- ---- ---- ---- ---- ----
    //              MD4 STOP SIGNAL
    // ---- ---- ---- ---- ---- ---- ---- ----
    always @(posedge CLK) begin
        if (MD4_DONE) begin
            MD4_START = 0;
        end
    end // STOP MD4 STOP SIGNAL
    
    
    
    // ---- ---- ---- ---- ---- ---- ---- ----
    //                  MAIN
    // ---- ---- ---- ---- ---- ---- ---- ----
    initial begin
        // ---- ---- ---- ---- ---- ---- ---- ----
        //              SETUP
        // ---- ---- ---- ---- ---- ---- ---- ----
        $display("[*] SYSTEM RESET ...");
        RESET_N = 0;
        x = 0;
        error = 0;
        hash_counter = 0;
        MD4_DATA_SIZE = DATA_SIZE;   
        // SET THE FIFO PINS
        MD4_DATA_EMPTY = 1;
        MD4_HASH_FULL = 1;
        
        // DATA = 123456 --> 0x31323334353637383931323334353637
        data[8'h00] = 8'h31; data[8'h01] = 8'h32; data[8'h02] = 8'h33; data[8'h03] = 8'h34; data[8'h04] = 8'h35; data[8'h05] = 8'h36; data[8'h06] = 8'h37; data[8'h07] = 8'h38;
        data[8'h08] = 8'h39; data[8'h09] = 8'h31; data[8'h0a] = 8'h32; data[8'h0b] = 8'h33; data[8'h0c] = 8'h34; data[8'h0d] = 8'h35; data[8'h0e] = 8'h36; data[8'h0f] = 8'h37;
        $display("[*] INPUT DATA: (SIZE: 0x%H)", DATA_SIZE);
        $display("[+]    DATA[0:15]={0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H}", data[8'h00], data[8'h01], data[8'h02], data[8'h03], data[8'h04], data[8'h05], data[8'h06], data[8'h07], data[8'h08], data[8'h09], data[8'h0a], data[8'h0b], data[8'h0c], data[8'h0d], data[8'h0e], data[8'h0f]);
        
        // HASH = 0x2baa0645e8c33c14022716e6da14b81c
        known_hash[8'h00] = 8'h2b; known_hash[8'h01] = 8'haa; known_hash[8'h02] = 8'h06; known_hash[8'h03] = 8'h45; known_hash[8'h04] = 8'he8; known_hash[8'h05] = 8'hc3; known_hash[8'h06] = 8'h3c; known_hash[8'h07] = 8'h14;
        known_hash[8'h08] = 8'h02; known_hash[8'h09] = 8'h27; known_hash[8'h0a] = 8'h16; known_hash[8'h0b] = 8'he6; known_hash[8'h0c] = 8'hda; known_hash[8'h0d] = 8'h14; known_hash[8'h0e] = 8'hb8; known_hash[8'h0f] = 8'h1c;
        $display("[*] KNOWN HASH: (SIZE: 0x%H)", HASH_SIZE);
        $display("[+]    KNOWN_HASH[0:15]={0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H}", known_hash[8'h00], known_hash[8'h01], known_hash[8'h02], known_hash[8'h03], known_hash[8'h04], known_hash[8'h05], known_hash[8'h06], known_hash[8'h07], known_hash[8'h08], known_hash[8'h09], known_hash[8'h0a], known_hash[8'h0b], known_hash[8'h0c], known_hash[8'h0d], known_hash[8'h0e], known_hash[8'h0f]);
        
        // Null the ciphertext
        for (x=0; x < HASH_SIZE; x = x+1)
        begin
            hash[x] = 0;
        end
        
        data_counter = 1;
        MD4_DATA_BYTE = data[8'h00];
        // STOP SETUP
        
        
        
        // ---- ---- ---- ---- ---- ---- ---- ----
        //              START SIGNAL
        // ---- ---- ---- ---- ---- ---- ---- ----
        #5;
        RESET_N = 1;
        #1;
        MD4_START = 1;
        // STOP START SIGNAL
        
        
        
        // ---- ---- ---- ---- ---- ---- ---- ----
        //                ANALYSIS
        // ---- ---- ---- ---- ---- ---- ---- ----
        #4500;
        $display("[*] CAPTURED HASH: (SIZE: 0x%H)", HASH_SIZE);
        $display("[+]    CAPTURED_HASH[00:15]={0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H 0x%H}", hash[8'h00], hash[8'h01], hash[8'h02], hash[8'h03], hash[8'h04], hash[8'h05], hash[8'h06], hash[8'h07], hash[8'h08], hash[8'h09], hash[8'h0a], hash[8'h0b], hash[8'h0c], hash[8'h0d], hash[8'h0e], hash[8'h0f]);
    
        for (x=0; x < HASH_SIZE; x = x+1)
        begin
            if (known_hash[x] != hash[x])
            begin
                $display("[!] The known ciphertext does not match the captured ciphertext --> Element ID: %d / Known: 0x%H / Captured: 0x%H ", x, hash[x], hash[x]);
                error = error +1;
            end
        end
        // STOP ANALYSIS        
        
        
        
        // ---- ---- ---- ---- ---- ---- ---- ----
        //                  RESULT
        // ---- ---- ---- ---- ---- ---- ---- ----
        $display("---- ---- ---- ---- ---- ---- ---- ---- ---- RESULT ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----");
        if (error == 0)
            $display("[*] ... PASSED ...");
        else
            $display("[!] ... FAILED ...");
        $display("---- ---- ---- ---- ---- ---- ---- ---- ---- RESULT ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----");
        // STOP RESULT
        $stop;
    end // STOP MAIN
endmodule // STOP MD4_TB
