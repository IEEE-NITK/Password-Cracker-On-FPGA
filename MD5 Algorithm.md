`timescale 1ns / 1ps

module algo(
input clk,rst,
input[511:0]text,
output reg [127:0]hash,
output reg [31:0] next_a,next_b,next_c,next_d
    );

reg [31:0]M[15:0];
reg [31:0]msg;
reg [31:0]t;
reg [31:0] a,b,c,d,func;
reg [31:0] aux,rotate1,rotate2,step;
reg [7:0]s;
parameter add= 'h100000000;
parameter A='h67452301,B='hefcdab89,C='h98badcfe,D='h10325476;
reg [31:0] next_A,next_B,next_C,next_D;
always @(posedge clk or posedge rst)//rst and step increment+initialize
begin

   if(rst)
   begin
     a='h67452301;
     b='hefcdab89;
     c='h98badcfe;
     d='h10325476;
     step=0;
   M[0]=text[511:480];  //initializing before all rounds and operations
   M[1]=text[479:448]; 
   M[2]=text[447:416]; 
   M[3]=text[415:384]; 
   M[4]=text[383:352]; 
   M[5]=text[351:320]; 
   M[6]=text[319:288]; 
   M[7]=text[287:256]; 
   M[8]=text[255:224]; 
   M[9]=text[223:192]; 
   M[10]=text[191:160]; 
   M[11]=text[159:128]; 
   M[12]=text[127:96]; 
   M[13]=text[95:64]; 
   M[14]=text[63:32]; 
   M[15]=text[31:0];
   end 	   
   else
   begin
     step=step+1;
     a=next_a;
     b=next_b;
     c=next_c;
     d=next_d;
   end
end  

always@(step or a or b or c or d)begin //t,msg,s
case(step)
0:begin t='hD76AA478;
msg=M[0];
s=7;
end
1:begin t='hE8C7B756;
msg=M[1];
s=12;
end
2:begin t='h242070DB;
msg=M[2];
s=17;
end
3:begin t='hC1BDCEEE;
msg=M[3];
s=22;
end
4:begin t='hF57C0FAF;
msg=M[4];
s=7;
end
5:begin t='h4787C62A;
msg=M[5];
s=12;
end
6:begin t='hA8304613;
msg=M[6];
s=17;
end
7:begin t='hFD469501;
msg=M[7];
s=22;
end
8:begin t='h698098D8;
msg=M[8];
s=7;
end
9:begin t='h8B44F7AF;
msg=M[9];
s=12;
end
10:begin t='hFFFF5BB1;
msg=M[10];
s=17;
end
11:begin t='h895CD7BE;
msg=M[11];
s=22;
end
12:begin t='h6B901122;
msg=M[12];
s=7;
end
13:begin t='hFD987193;
msg=M[13];
s=12;
end
14:begin t='hA679438E;
msg=M[14];
s=17;
end
15:begin t='h49B40821;
msg=M[15];
s=22;
end
16:begin t='hF61E2562;
msg=M[1];
s=5;
end
17:begin t='hC040B340;
msg=M[6];
s=9;
end
18:begin t='h265E5A51;
msg=M[11];
s=14;
end
19:begin t='hE9B6C7AA;
msg=M[0];
s=20;
end
20:begin t='hD62F105D;
msg=M[5];
s=5;
end
21:begin t='h02441453;
msg=M[10];
s=9;
end
22:begin t='hD8A1E681;
msg=M[15];
s=14;
end
23:begin t='hE7D3FBC8;
msg=M[4];
s=20;
end
24:begin t='h21E1CDE6;
msg=M[9];
s=5;
end
25:begin t='hC33707D6;
msg=M[14];
s=9;
end
26:begin t='hF4D50D87;
msg=M[3];
s=14;
end
27:begin t='h455A14ED;
msg=M[8];
s=20;
end
28:begin t='hA9E3E905;
msg=M[13];
s=5;
end
29:begin t='hFCEFA3F8;
msg=M[2];
s=9;
end
30:begin t='h676F02D9;
msg=M[7];
s=14;
end
31:begin t='h8D2A4C8A;
msg=M[12];
s=20;
end
32:begin t='hFFFA3942;
msg=M[5];
s=4;
end
33:begin t='h8771F681;
msg=M[8];
s=11;
end
34:begin t='h699D6122;
msg=M[11];
s=16;
end
35:begin t='hFDE5380C;
msg=M[14];
s=23;
end
36:begin t='hA4BEEA44;
msg=M[1];
s=4;
end
37:begin t='h4BDECFA9;
msg=M[4];
s=11;
end
38:begin t='hF6BB4B60;
msg=M[7];
s=16;
end
39:begin t='hBEBFBC70;
msg=M[10];
s=23;
end
40:begin t='h289B7EC6;
msg=M[13];
s=4;
end
41:begin t='hEAA127FA;
msg=M[0];
s=11;
end
42:begin t='hD4EF3085;
msg=M[3];
s=16;
end
43:begin t='h04881D05;
msg=M[6];
s=23;
end
44:begin t='hD9D4D039;
msg=M[9];
s=4;
end
45:begin t='hE6DB99E5;
msg=M[12];
s=11;
end
46:begin t='h1FA27CF8;
msg=M[15];
s=16;
end
47:begin t='hC4AC5665;
msg=M[2];
s=23;
end
48:begin t='hF4292244;
msg=M[0];
s=6;
end
49:begin t='h432AFF97;
msg=M[7];
s=10;
end
50:begin t='hAB9423A7;
msg=M[14];
s=15;
end
51:begin t='hFC93A039;
msg=M[5];
s=21;
end
52:begin t='h655B59C3;
msg=M[12];
s=6;
end
53:begin t='h8F0CCC92;
msg=M[3];
s=10;
end
54:begin t='hFFEFF47D;
msg=M[10];
s=15;
end
55:begin t='h85845DD1;
msg=M[1];
s=21;
end
56:begin t='h6FA87E4F;
msg=M[8];
s=6;
end
57:begin t='hFE2CE6E0;
msg=M[15];
s=10;
end
58:begin t='hA3014314;
msg=M[6];
s=15;
end
59:begin t='h4E0811A1;
msg=M[13];
s=21;
end
60:begin t='hF7537E82;
msg=M[4];
s=6;
end
61:begin t='hBD3AF235;
msg=M[11];
s=10;
end
62:begin t='h2AD7D2BB;
msg=M[2];
s=15;
end
63:begin t='hEB86D391;
msg=M[9];
s=21;
end
endcase

if(step<16) //f
func=((b&c)|(~b&d)); 
else if(step<32) //g
func=((b&d)|(c& (~d)));
else if(step<48) //h
func=(b^c^d);
else //i
func=(c^(b|~d));

aux=(((((a+func)%add)+msg)%add)+t)%add;
rotate1=aux << s;
rotate2=aux >> (32-s);
next_b=(b+(rotate1 | rotate2))%add;
next_a=d;
next_c=b;
next_d=c;

if(step==63)begin
next_A=(next_a+A)%add;
next_B=(next_b+B)%add;
next_C=(next_c+C)%add;
next_D=(next_d+D)%add;
hash={next_A,next_B,next_C,next_D};
end
end
endmodule
