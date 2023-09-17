`timescale 1ns/1ps

module uar_baudrate_generator(
    Clk                   ,
    Rst_n                 ,
    tick                  ,
    baudRate
    );

input           Clk                 ; // Clock
input           Rst_n               ; // Reset
input [15:0]    baudRate            ;

output          tick                ;

reg [15:0]      baudRateReg         ;

always @(posedge Clk or negedge Rst_n)
    if (!Rst_n) baudRateReg <= 16'b1;
    else if (tick) baudRateReg <= 16'b1;
         else baudRateReg <= baudRateReg + 1'b1;

assign tick = (baudRateReg == baudRate);

endmodule