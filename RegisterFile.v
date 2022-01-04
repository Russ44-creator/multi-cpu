`timescale 1ns / 1ps
module RegisterFile(
    input CLK,
    input WE,
    input[4:0] ReadReg1,
    input[4:0] ReadReg2,
    input[4:0] WriteReg, //写入寄存器端口
    input[31:0] WriteData, //写入寄存器输出端口
    input RST,
    output [31:0] ReadData1, //rs寄存器数据输出端口
    output [31:0] ReadData2 //rt输出
);
    reg[31:0] register[0:31];
    integer i;
    initial begin
      for(i=0;i<32;i=i+1)register[i]<=0;
    end

    assign ReadData1=(ReadReg1==0)?0:register[ReadReg1];
    assign ReadData2=(ReadReg2==0)?0:register[ReadReg2];
    
    always@(posedge CLK or  negedge RST)begin
        if(RST==0)begin
          for(i=0;i<32;i=i+1)register[i]<=0;
        end
        else if (WriteReg && WE) begin
             register[WriteReg]<=WriteData;
        end
    end
endmodule