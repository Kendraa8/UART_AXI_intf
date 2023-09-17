`timescale 1ns/1ps

module uart_fm(
    Tx                    ,
    Rx                    
    );

input           Rx         ; // Receive channel
output          Tx         ; // Transmit channel
reg             Tx         ;

reg [15:0]      baudRate   ;
reg [3:0]       nBits      ;
reg [7:0]       RxData     ;

//always @(nededge TX)
 
//______________________________________________________________________________
//  Initialization

initial
begin
    Tx = 1;  // Reset value
    RxData = 0;
end
    

//______________________________________________________________________________
//  task: transmit. Transmit channel: sends 1 byte of data.

task transmit;

input [7:0] TxData;

integer     i;

    begin
    // Start bit
    Tx = 0; 
    waitBitTime;
    $display("\\  UART_FM: Transmission of data %h has started at time\t", TxData, $realtime/1e6, " us.");
    // Data to transmit
    for(i = 0; i < nBits; i = i + 4'b1)
     begin
      Tx = TxData[i]; 
      waitBitTime;
     end
    // Stop bit    
    Tx = 1; 
    waitBitTime;
    $display("\\  UART_FM: Transmission of data %h has finished at time\t", TxData, $realtime/1e6, " us.");
    end
endtask 

task waitIncommingData;
  
  integer i;
  
  begin
    $display("\\  UART_FM: Waiting incomming Data");
    wait(!Rx)
    waitHalfBitTime;
    for(i = 0; i < nBits; i = i + 4'b1)
     begin
      waitBitTime; 
      RxData[i] = Rx; 
     end
    waitBitTime;
    if (Rx) begin
    $display("\\  UART_FM: Data received at ", $realtime/1e6, " us is %h", RxData);
    end
    else $display("\\ UART_FM: Data received corrupted! at ", $realtime/1e6, " us.");
  end 
endtask

task waitBitTime;
  
integer i;

    begin
    for (i = 0; i < baudRate; i = i + 1)
     begin
       #20;
     end
    end
endtask

task waitHalfBitTime;
  
integer i;

    begin
    for (i = 0; i < baudRate/2; i = i + 1)
     begin
       #20;
     end
    end
endtask


task setBaudRate;
  
input[15:0] bdRate;

  begin
    case(bdRate)
      16'd2400:   baudRate = 16'd1302*16;
      16'd4800:   baudRate = 16'd651*16;
      16'd9600:   baudRate = 16'd325*16; 
      16'd19200:  baudRate = 16'd163*16; 
     default: baudRate = 16'd0;
    endcase
    $display("\\  UART_FM: Baud rate set to %d at time\t", bdRate, $realtime/1e6, " us.");
  end
endtask

task setNbits;

input[3:0] numberOfBits;
  
  begin
    nBits = numberOfBits;
    $display("\\  UART_FM: Number of bits set to %d at time\t", nBits, $realtime/1e6, " us.");
  end
endtask

endmodule // uart_fm