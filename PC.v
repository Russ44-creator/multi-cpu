//存放当前执行指令的地址，接受pc choose传进来的下一跳pc并等待输出
`timescale 1ns / 1ns
module PC(
    input PCWre, // PC是否更改，如果为0，PC不更改
    input[31:0] inPC, // 新指令
    input CLK, // 时钟
    input Reset, // 重置信号
    output reg[31:0] nextPC // 当前指令
    );
    initial begin
        nextPC=0; // 非阻塞赋值
    end
    always@(posedge CLK or negedge Reset)begin
        if(Reset==0)begin
            nextPC<=0;  //pc清零
        end
        if(Reset!=0&&PCWre==1)begin
            nextPC<=inPC;  //通过pc choose
        end
    end
endmodule