module main (
    input clk,
    input reset,
    input init,
    input [255:0] hash,
    output reg [31:0] password_count,
    output reg cracked,
    output reg done
);

top_sha sha256cu(clk,rst,byte_rdy,byte_stop,data_in [7:0],
					overflow_err,Hash_Digest, hashing_done);
reg rst;
reg [31:0] count;
reg [31:0] state;
reg [7:0] byte_addressable_memory [0:36000];
reg [31:0] memory_address;
reg [31:0] start_string;
reg [7:0] data_in;
reg [31:0] curr_index;
reg byte_rdy;
reg byte_stop;
reg [7:0] indices [0:1024];
reg [7:0] lengths [0:1024];
wire [255:0] Hash_digest;
wire hashing_done;
always @(posedge clk) begin
    if (reset) begin
        count <= 0;
        state <= 0;
        rst<=0;
        memory_address <=0;
        start_string <=0;
        curr_index=0;
        password_count<=0;
        cracked <=0;
        done <=0;
    end else begin
        case (state)
            0: begin // init state
                if (byte_addressable_memory[memory_address] == 8'ha) begin
                        indices[count] <= start_string;
                        start_string <= memory_address + 1;
                        memory_address <= memory_address+1;
                        lengths[count] <= memory_address - start_string;
                        count <= count + 1;
                end else if (byte_addressable_memory[memory_address] == 8'h5) begin
                        password_count<=count;
                        count <=0;
                        state <= 1;
                        byte_rdy <=1;
                        byte_stop <=0;
                end else begin
                        memory_address <= memory_address +1;
                end
            end
            1: begin // ready 
                if(count<password_count)begin
                    rst <=1;
                    if(lengths[count]>curr_index) begin
                        data_in <= byte_addressable_memory[indices[count]+curr_index];
                        curr_index <= curr_index +1;
                    end else begin
                        byte_rdy <=0;
                        byte_stop <=1;
                        state <=2;
                    end
                end else begin
                state <=3;
                end               
            end
          2: begin
             if(hashing_done==1'b1)begin
                rst<=0;
                if(Hash_Digest==hash)begin
                    cracked<=1;
                end else begin
                    byte_rdy <=1;
                    byte_stop <=0;
                    count<=count+1;
                    curr_index <=0;
                    state <=1;
                end
             end
          end
         3: begin
         done <=1;
         end
        endcase
    end
end

endmodule
