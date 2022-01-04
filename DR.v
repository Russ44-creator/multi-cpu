 `timescale 1ns / 1ps
 //在时钟上升沿输出发生变化
module DR(
    input CLK,
    input [31:0] in,
    output reg[31:0] out
);
    always@(posedge CLK)begin
        out<=in;
    end
endmodule