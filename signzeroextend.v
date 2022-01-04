//对16位的数据进行零扩展或符号位扩展，成为32位的数据
`timescale 1ns / 1ns
module signzeroextend(
    input wire[15:0] immediate, // 16位立即数
    input ExtSel, // 控制补位，如果为1，进行符号扩展，如果为0，全补0
    output reg[31:0] extended // 输出的32位立即数
);
    always@(*)begin
      extended[15:0]<=immediate;
      if(ExtSel==0)begin
        extended[31:16]<=16'h0000;
      end
      else begin
        extended[31:16]<=immediate[15] ? 16'hffff : 16'h0000;
      end
    end
endmodule