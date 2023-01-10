module password_storage (
    input clk,
    input rst,
    input init,
    output reg [31:0] indices [0:30*1000*1000-1],
    output reg [31:0] password_count,
    output reg [31:0] ready
);

reg [31:0] count;
reg [31:0] state;
reg [7:0] byte_addressable_memory [0:256*1024*1024-1]; // 256MB byte addressable memory
reg [31:0] memory_address;
reg [31:0] start_string;
always @(posedge clk) begin
    if (rst) begin
        count <= 0;
        state <= 0;
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
                end else if (byte_addressable_memory[memory_address] == EOF) begin
                        indices[count] <= start_string;
                        state <= 1;
                        count <= count + 1;
                        start_string <=1;
                        memory_address <= memory_address +1;
                end else begin
                        memory_address <= memory_address +1;
                end
            end
            1: begin // ready state
                ready <= 1;
            end
        endcase
    end
end

endmodule
