`timescale 1ns/1ps 
module Top(
    input CLK,
    input RST,
    output[31:0] PCout,//当前指令
    output[31:0] PCin,//下一条指令
    output[4:0] reg1_addr, //寄存器组1编号
    output[31:0] ReadData1,
    output[4:0] reg2_addr,
    output[31:0] ReadData2,
    output[31:0] result,
    output[31:0] DBout,
    output[2:0] state //状态1-5
);
    wire PCWre; //PC是否更改
    wire IRWre; //指令寄存器是否更改
    wire ALUSrcA;
    wire ALUSrcB;
    wire DBDataSrc; //0：ALU运算结果的输出，1：数据存储器的输出
    wire RegWre; //0：无写寄存器组寄存器 1：寄存器写
    wire InsMemRW;//0：写指令寄存器 0：读指令寄存器
    wire mRD;//1：lw
    wire mWR;//1：sw
    wire WrRegDSrc; //0：写入寄存器组寄存器来自pc+4，jal 1：alu
    wire[1:0] RegDst; //写寄存器寄存器的地址
    wire ExtSel;//立即数扩展
    wire[2:0] ALUOp;
    wire[1:0] PCSrc;
    wire[31:0] IDataOut;
    wire[4:0] WriteRegIn;
    wire[31:0] DBin;
    wire[31:0] WriteData;
    wire[31:0] ALUAin;
    wire[31:0] ALUBin;
    wire zero;
    wire sign;
    wire[31:0] ExtendOut;
    wire ifNeedOf;
    wire overflow;
    wire[31:0] IRout;
    wire[31:0] ADRout;
    wire[31:0] BDRout;
    wire[31:0] ALUoutDRout;
    wire[31:0] DataOut;
    assign reg1_addr=IRout[25:21];
    assign reg2_addr=IRout[20:16];
	
    controlUnit controlUnit_(PCWre, ALUSrcA, ALUSrcB, DBDataSrc, RegWre, WrRegDSrc, InsMemRW, mRD, mWR, IRWre, ExtSel, ALUOp, RegDst, PCSrc, ifNeedOf, zero, sign, IRout[31:26], IRout[5:0], RST, CLK, overflow, ALUBin, state, HALT);

    IR IR_(IDataOut, IRWre, CLK, RST, IRout);

    DR ADR(CLK, ReadData1, ADRout); //切分数据通路，将大组合逻辑
    DR BDR(CLK, ReadData2, BDRout);//切分为若干个小组合逻辑，大延迟变为多个分段小延迟
    DR DBDR(CLK, DBin, DBout);
    DR ALUoutDR(CLK, result, ALUoutDRout);

    Mux5 Mux5_1(RegDst, 5'b11111, IRout[20:16], IRout[15:11], WriteRegIn);

    Mux32 Mux32_1(WrRegDSrc, PCout+4, DBout, WriteData);
    Mux32 Mux32_2(ALUSrcA, ADRout, {27'b000000000000000000000000000,IRout[10:6]},ALUAin);
    Mux32 Mux32_3(ALUSrcB, BDRout, ExtendOut, ALUBin);
    Mux32 Mux32_4(DBDataSrc, result, DataOut, DBin);

    signzeroextend signzeroextend_(IRout[15:0], ExtSel, ExtendOut);


    ALU ALU_(ALUAin, ALUBin, ALUOp, ifNeedOf, sign, zero, overflow, result);

    RegisterFile RegisterFile_(CLK, RegWre, IRout[25:21], IRout[20:16], WriteRegIn, WriteData, RST, ReadData1, ReadData2);

    insMEM insMEM_(InsMemRW, PCout, IDataOut);

    PCchoose PCchoose_(PCSrc,ReadData1, ExtendOut, PCout, IRout, RST, HALT, PCin);

    PC PC_(PCWre, PCin, CLK, RST, PCout);

    DataMem DataMem_(CLK, mRD, mWR, ALUoutDRout, BDRout, DataOut);

endmodule