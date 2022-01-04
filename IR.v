 `timescale 1ns / 1ps
 //在时钟上升沿输出发生变化
 module IR(
    input[31:0] ins_in,
    input IRWre, //0：IR不更改 1：IR写使能，
    //向指令存储器发出读指令代码后，这个信号也接着发出，
    //在时钟上升沿， IR 接收从指令存储器送来的指令代码。
    //与每条指令都相关。
    input CLK,
    input RST,
    output reg[31:0] IRout
 );
    always@(posedge CLK or negedge RST)begin
        if(RST==0) IRout<=ins_in; //0：初始化 PC 为程序首地址
        else if(IRWre) IRout<=ins_in;
    end 
 endmodule