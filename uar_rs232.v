`timescale 1ns/1ps
 
module uar_rs232(
    Clk                  ,
    Rst_n                ,
    RxEn                 ,
    RxData               ,
    RxDone               ,
    Rx                   ,
    TxEn                 ,
    TxData               ,
    TxDone               ,
    Tx                   ,
    nBits                ,
    baudRate
    );

input           Clk                 ; // Clock
input           Rst_n               ; // Reset

input           RxEn                ; // Enable rx operation. Active high.
output [ 7: 0]  RxData              ; // Received data
output          RxDone              ; // Reception completed. Data is valid.
input           Rx                  ; // RS232 RX line.
input           TxEn                ; // Enable Tx operation. Active high.
input [ 7: 0]   TxData              ; // Data to transmit.
output          TxDone              ; // Trnasmission completed. Data sent.
output          Tx                  ; // RS232 TX line.
input [3:0]     nBits               ;
input [15:0]    baudRate            ;
wire            tick                ; // Baud rate clock

uar_rs232_rx I_RS232RX(
    .Clk(Clk)             ,
    .Rst_n(Rst_n)         ,
    .RxEn(RxEn)           ,
    .RxData(RxData)       ,
    .RxDone(RxDone)       ,
    .Rx(Rx)               ,
    .tick(tick)           ,
    .nBits(nBits)
    );

uar_rs232_tx I_RS232TX(
    .Clk(Clk)             ,
    .Rst_n(Rst_n)         ,
    .TxEn(TxEn)           ,
    .TxData(TxData)       ,
    .TxDone(TxDone)       ,
    .Tx(Tx)               ,
    .tick(tick)           ,
    .nBits(nBits)
    );
    
uar_baudrate_generator I_BAUDGEN(
    .Clk(Clk)              ,
    .Rst_n(Rst_n)          ,
    .tick(tick)            ,
    .baudRate(baudRate)
    );

endmodule