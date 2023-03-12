`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.03.2023 14:19:17
// Design Name: 
// Module Name: main_tb
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


module main_tb();

reg clk, reset, init;
wire [31:0] password_count;
wire cracked;
wire done;
reg [255:0] hash;
// Instantiate DUT
main dut(
    .clk(clk),
    .reset(reset),
    .init(init),
    .hash(hash),    
    .password_count(password_count),
    .cracked(cracked),
    .done(done)
);

// Generate clock signal
initial clk = 0;
always #5 clk = ~clk;

// Initialize memory with passwords
initial begin
    dut.byte_addressable_memory[0] = "d";
    dut.byte_addressable_memory[1] = "e";
    dut.byte_addressable_memory[2] = "f";
    dut.byte_addressable_memory[3] = 8'ha;
    dut.byte_addressable_memory[4] = "a";
    dut.byte_addressable_memory[5] = "b";
    dut.byte_addressable_memory[6] = "c";
    dut.byte_addressable_memory[7] = 8'ha;
    dut.byte_addressable_memory[8] = "a";
    dut.byte_addressable_memory[9] = "b";
    dut.byte_addressable_memory[10] = "c";
    dut.byte_addressable_memory[11] = 8'ha;
    dut.byte_addressable_memory[12] = 8'h05; // end delimiter
end

// Reset and initialize DUT
initial begin
    hash= 8'hcb8379ac2098aa165029e3938a51da0bcecfc008fd6795f401178647f96c5b34;
    reset = 1;
    init = 0;
    #10 reset = 0;
    #20 init = 1;
    #50 init = 0;
end

// Wait for module to indicate readiness
endmodule
