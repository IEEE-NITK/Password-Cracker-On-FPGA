`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.11.2022 14:36:12
// Design Name: 
// Module Name: cutb
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


module cutb(output overflow_err,
    output [254:0]Hash_Digest,
    output hashing_done
    );
    
reg reset, byte_rdy,byte_stop, clk, start, ready;
reg [63:0] data_length;
reg [255:0] data;
wire overflow_err;
wire [255:0]Hash_Digest;
cu  cracking_unit(clk, reset, data, data_length,Hash_Digest, overflow_err, hashing_done);
initial forever #5 clk = ~clk;
initial
begin
    data_length = 3;
    data = "abc";
    clk = 0;
    reset=0;
    #10;
    reset=1;
end
endmodule
