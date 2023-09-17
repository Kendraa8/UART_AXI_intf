`timescale 1ns/1ps

module uart_cntrl_fm(
    Clk,
    RxEn,
    RxDone,
    RxData,
    TxEn,
    TxData,
    TxDone,
    nBits,
    baudRate
    );

input           Clk                 ; // Clock

output          RxEn                ; // Enable rx operation. Active high.
input           RxDone              ; // Reception completed. Data is valid.
output          TxEn                ; // Enable Tx operation. Active high.
output [7: 0]   TxData              ; // Data to transmit.
input           TxDone              ; // Transmission completed. Data sent.
input  [7:0]    RxData              ; // Received data through RX channel.
output [3:0]    nBits               ;
output [15:0]   baudRate            ;

reg             RxEn                ; // Enable RX operation. Active high.
reg             TxEn                ; // Enable TX operation. Active high.
reg   [3:0]     nBits               ;
reg   [15:0]    baudRate            ;
reg   [7:0]     TxData              ;
reg   [7:0]     receivedData        ;

task enableRx;
  
  begin
  @(posedge Clk)
   #2 RxEn = 1'b1;
  $display("DUT: Rx channel disabled!");
  end
endtask

task disableRx;
  
  begin
  @(posedge Clk)
   #2 RxEn = 1'b0;
  $display("DUT: Rx channel disabled!");
  end
endtask

task transmit;
  input [7:0] Data;
  
  begin
  @(posedge Clk)
  #2 TxData = Data;
  $display("DUT: starting transmission of %h", Data);
  @(posedge Clk)
  #2 TxEn = 1'b1;
  @(posedge Clk)
  #2 TxEn = 1'b0;
  wait(TxDone)
  $display("DUT: Data transmited!");
  end
endtask

task setBaudRate;

input[15:0] bdRate;

  begin
    @(posedge Clk)
    #2
    case(bdRate)
      16'd2400:   baudRate <= 16'd656;
      16'd4800:   baudRate <= 16'd328;
      16'd9600:   baudRate <= 16'd162; 
      16'd19200:  baudRate <= 16'd81; 
     default: baudRate <= 16'd0;
    endcase
    $display("DUT: Baud rate set to %d", bdRate);
  end
endtask

task setNbits;

input[3:0] numberOfBits;
  
  begin
    @(posedge Clk)
    #2 nBits <= numberOfBits;
    $display("DUT: Number of bits set to %d", nBits);
  end
endtask

task waitIncommingData;
  
  begin
    $display("Waiting incomming Data");
    wait(RxDone)
    #2 receivedData <= RxData;
    $display("DUT: Data received! Data = %h", RxData);
  end 
endtask

initial
 begin
   RxEn <= 1'b0;
   TxEn <= 1'b0;
   nBits <= 4'd0;
   baudRate <= 16'd0;
   TxData <= 8'd0;
 end
 
endmodule