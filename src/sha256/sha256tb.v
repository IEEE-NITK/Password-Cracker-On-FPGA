`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.11.2022 13:38:32
// Design Name: 
// Module Name: sha256tb
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


module sha256tb(
    output overflow_err, Hash_Digest
    );
reg byte_rdy,byte_stop, clk, start, rst;
reg [7:0] data_in;
wire overflow_err;
wire [255:0]Hash_Digest;
reg[8*3:1] str;
integer i;
top_sha sha256cu(clk,rst,byte_rdy,byte_stop,data_in,
					overflow_err,Hash_Digest);
					
initial forever #5 clk = ~clk;
initial
begin
    clk = 0;
    byte_rdy=1;
    byte_stop=0;
    str = "abc";
    rst=0;
    data_in=0;
    #15
//cyclic inputs x and y transversing the above values.
    rst=1;
	data_in=8'h61;
	#10;
	data_in=8'h62;
	#10;
	data_in=8'h63;
	#10;
	byte_rdy=0;
    byte_stop=1;
end
endmodule
