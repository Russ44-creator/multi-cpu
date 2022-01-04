/*数据储存器负责在时钟下降沿时， 
根据控制信号将传入的数据根据传入的地址写入并保存，
当读取时根据控制信号和传入的地址输出正确的数据。*/
`timescale 1ns / 1ns
module DataMem(
    input CLK,
    input RD,  //读信号，1读
    input WR,  //写信号，1写
    input[31:0] DAddr, // 数据存储器地址输入端口
    input[31:0] DataIn, // 数据存储器数据输入端口
    output reg[31:0] DataOut // 数据存储器数据输出端口
);
    // initial begin
    //     DataOut<=31'b0;
    // end
    // 模拟内存，以8位为一字节存储，共512字节
    reg[7:0] data[0:511];
    //读内存
    //“<=”是非阻塞赋值，“=”是阻塞赋值
    always@(RD or DAddr)begin
        if(RD)begin
            DataOut[31:24]=data[DAddr]; 
            DataOut[23:16]=data[DAddr+1];
            DataOut[15:8]=data[DAddr+2];
            DataOut[7:0]=data[DAddr+3];
        end
    end
    //写内存
    always@(negedge CLK)begin
        if(WR)begin
            data[DAddr]=DataIn[31:24];
            data[DAddr+1]=DataIn[23:16];
            data[DAddr+2]=DataIn[15:8];
            data[DAddr+3]=DataIn[7:0];
        end
    end
endmodule