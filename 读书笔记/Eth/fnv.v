// FNV哈希算法全名为Fowler-Noll-Vo算法，
// 是以三位发明人Glenn Fowler，Landon Curt Noll，Phong Vo的名字来命名的，最早在1991年提出
// 特点和用途：FNV能快速hash大量数据并保持较小的冲突率，它的高度分散使它适用于hash一些非常相近的字符串，
// 比如URL，hostname，文件名，text，IP地址等。
// 适用范围：比较适用于字符串比较短的哈希场景
`include "define.v"
module fnv (
    input wire clk ,  
    input wire rst_n , 
    input  wire [`UINT32_BIT*4-1:0]  a ,
    input  wire [`UINT32_BIT*4-1:0]  b ,
    output  reg [`UINT32_BIT*4-1:0]  c 
);


always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        c[`UINT32_BIT*4-1:0] <= 128'd0;
    end
    else begin
        c[`UINT32_BIT-1:0] <= a[`UINT32_BIT-1:0]*`FNV_PRIME^b[`UINT32_BIT-1:0];
        c[`UINT32_BIT*2-1:`UINT32_BIT] <= a[`UINT32_BIT-1:0]*`FNV_PRIME^b[`UINT32_BIT-1:0];
        c[`UINT32_BIT*3-1:`UINT32_BIT*2] <= a[`UINT32_BIT-1:0]*`FNV_PRIME^b[`UINT32_BIT-1:0];
        c[`UINT32_BIT*4-1:`UINT32_BIT*3] <= a[`UINT32_BIT-1:0]*`FNV_PRIME^b[`UINT32_BIT-1:0];
    end
end

endmodule