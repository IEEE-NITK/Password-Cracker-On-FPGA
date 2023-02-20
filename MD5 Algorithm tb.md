module tb();
reg clk,rst;
reg[511:0]text;
wire [127:0]hash;
wire [31:0] next_a,next_b,next_c,next_d;
algo dut(clk,rst,text,hash,next_a,next_b,next_c,next_d);
initial begin
clk=1;
forever #5 clk=~clk;
end
initial begin
rst=1;
text='h100000;
#5 rst=0;
end
endmodule
