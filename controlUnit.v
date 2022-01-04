`timescale 1ns / 1ns
//根据指令和输入的zero、 sign来决定输出控制其他各个单元的控制信号
//加有限状态机，控制state的变化
module controlUnit(
	output PCWre,  //0：pc不修改
    output ALUSrcA, //0：寄存器堆data1输出 1：移位数sa，指令：sll
    output ALUSrcB,//0：寄存器堆data2输出，1：来自sign和zero扩展的立即数
    output DBDataSrc, //alu运算结果的输出，1：数据存储器（data mem）的输出，指令：lw
    output RegWre, //0：无写寄存器组寄存器，1：寄存器组寄存器写使能
    output WrRegDSrc, //0：pc=pc+4 1：写入寄存器组寄存器的数据来自alu
    output InsMemRW,//0：写指令存储器 1：读指令存储器
    output mRD, //0：存储器高阻态，1：读数据存储器，lw
    output mWR,//0：无 1：写数据存储器，sw
    output IRWre, //0：IR不改，1：IR写使能，IR接受从指令存储器送来的指令代码
    output ExtSel,  //0：zero-extend immediate 1：sign-extend
    output [2:0] ALUOp, //8种
    output [1:0] RegDst, //写寄存器组寄存器的地址，00：保存返回地址，01：rt字段，10：rd字段，11：未用
    output [1:0] PCSrc,//四种pc变化
    output ifNeedOf, 
    input zero,
    input sign,
    input[5:0] OP,
    input[5:0] func,
    input RST,
    input CLK,
    input overflow, //判断溢出
    input[31:0] B,
    output reg[2:0] state,
    output HALT
);	
    reg [2:0] nextstate;
    parameter Rtype=6'b000000, addiu=6'b001001, andi=6'b001100, ori=6'b001101, slti=6'b001010, sw=6'b101011, lw=6'b100011, beq=6'b000100, bne=6'b000101, bltz=6'b000001, j=6'b000010, halt=6'b111111;
    parameter add=6'b100000, addu = 6'b100001, sub=6'b100010, and_=6'b100100, or_=6'b100101, nor_ = 6'b100110, sll=6'b000000;
    parameter IF=3'b000, ID=3'b001, EXEa=3'b110, EXEb=3'b101, EXEls=3'b010, MEM=3'b011, WBa=3'b111, WBm=3'b100; 
    
    always@(posedge CLK)begin
        if(RST) state<=nextstate;
        else state<=IF;
    end

    always@(*)begin
      if(RST)begin
        case(state)
            IF:nextstate=ID;  //取指令
            ID:begin  //指令译码
                if(OP==beq||OP==bne||OP==bltz) nextstate<=EXEb;
                else if(OP==sw||OP==lw) nextstate<=EXEls;//存储器读写
                else if(OP==j) nextstate<=IF; //跳转指令
                else if(OP==halt);
                else nextstate<=EXEa;
            end
            EXEa:nextstate<=WBa; //结果写回
            EXEb:nextstate<=IF; //取指令
            EXEls:nextstate<=MEM;  //存储器访问
            MEM:begin
                if(OP==lw) nextstate<=WBm;  //读存储器
                else nextstate<=IF;
            end
            WBa:nextstate<=IF;  //结果写回
            WBm:nextstate<=IF;
            default:nextstate<=IF;
        endcase   
      end 
    end
    //按照真值表来写出控制单元模块的代码
    assign HALT=(OP==halt);
    assign PCWre=(nextstate==IF && OP!=halt);
    assign ALUSrcA=(OP==Rtype&&func==sll);
    assign ALUSrcB=(OP==addiu||OP==andi||OP==ori||OP==sw||OP==lw||OP==slti);
    assign DBDataSrc=(OP==lw);
    assign RegWre=((state==WBa&&(!overflow))||(state==WBm));
    assign WrRegDSrc=1;
    assign InsMemRW=1;
    assign mRD=(state==MEM&&(OP==lw));
    assign mWR=(state==MEM&&OP==sw);
    assign RegDst[0]=(OP==lw||OP==addiu||OP==andi||OP==ori||OP==slti);
    assign RegDst[1]=(OP==Rtype);
    assign IRWre=(state==IF);
    assign ExtSel=(OP!=andi&&OP!=ori);
    assign ALUOp[0]=(OP==Rtype&&func==sub||OP==Rtype&&func==or_||OP==Rtype&&func==nor_||OP==ori||OP==beq||OP==bne||OP==bltz||OP==Rtype&&func==addu);
    assign ALUOp[1]=(OP==Rtype&&func==or_||OP==Rtype&&func==sll||OP==slti||OP==ori||OP==Rtype&&func==nor_);
    assign ALUOp[2]=(OP==andi||OP==Rtype&&func==and_||OP==Rtype&&func==nor_||OP==Rtype&&func==addu||OP==slti||OP==Rtype&&func==addu); //alu 8种运算功能选择
    assign PCSrc[0]=(OP==beq&&zero==1||OP==bne&&zero==0||OP==bltz&&sign==1||OP==j);
    assign PCSrc[1]=(OP==j);
    assign ifNeedOf=(OP==add||OP==sub); //溢出
endmodule
