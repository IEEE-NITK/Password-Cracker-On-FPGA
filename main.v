module password_storage (
    input clk,
    input reset,
    input init,
    output reg [31:0] indices [0:30*1000*1000-1],
    output reg [31:0] lengths [0:30*1000*1000-1],
    output reg [31:0] password_count,
    output reg [31:0] ready
);

top_sha sha256cu(clk,rst,byte_rdy,byte_stop,data_in [7:0],
					overflow_err,Hash_Digest);
reg rst;
reg [31:0] count;
reg [31:0] state;
reg [7:0] byte_addressable_memory [0:256*1024*1024-1]; // 256MB byte addressable memory
reg [31:0] memory_address;
reg [31:0] start_string;
always @(posedge clk) begin
    if (reset) begin
        count <= 0;
        state <= 0;
        rst<=0;
        ready <= 0;
        memory_address <=0;
        start_string <=0;
    end else begin
        case (state)
            0: begin // init state
                if (byte_addressable_memory[memory_address] == EOL) begin
                        indices[count] <= start_string;
                        count <= count + 1;
                        start_string <= memory_address + 1;
                        memory_address <= memory_address+1;
                        lengths <= memory_address - start_string;
                end else if (byte_addressable_memory[memory_address] == EOF) begin
                        state <= 1;
                end else begin
                        memory_address <= memory_address +1;
                end
            end
            1: begin // ready state
                ready <= 1;
                rst <=1;
                if(lengths[0]>curr_index) begin
                    byte_rdy <=1;
                    data_in <= byte_addressable_memory[indices[0]+curr_index];
                    curr_index <= curr_index +1;
                end
                else begin
                byte_rdy <=0;
                byte_stop <=1;
                end
            end
        endcase
    end
end

endmodule
