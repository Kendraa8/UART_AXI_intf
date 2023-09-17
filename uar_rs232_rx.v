`timescale 1ns/1ps

module uar_rs232_rx(
    Clk                  ,
    Rst_n                ,
    RxEn                 ,
    RxData               ,
    RxDone               ,
    Rx                   ,
    tick                 ,
    nBits
    );

input           Clk                 ; // Clock
input           Rst_n               ; // Reset

input           RxEn                ; // Enable rx operation. Enable only if RX=1
output [ 7: 0]  RxData              ; // Received data
output          RxDone              ; // Reception completed. Data is valid.
input           Rx                  ; // RS232 RX line.

input           tick                ; // Baud rate clock

input [3:0]     nBits               ;

reg   [5:0]     timer               ; // Timer register

reg   [3:0]     bits                ; // To counter the number of bits of an incomming frame;

reg             waitHalfBitTime     ;
reg             waitFullBitTime     ;
reg             waitNBits           ;
reg             RxDone              ;
reg             captureData         ; //Enables RX shift register. Active high.
reg [7:0]       incommingData       ; //RX shift register.
reg             waitDonePosReg      ;

wire            waitDonePos;

wire            waitBitsDone        ; 

wire            waitDone            ; // End of count of timer. Active high one clock cycle;        

wire            rx_sync             ;

reg [4:0]       state               ; // Current state;
reg [4:0]       next_state          ; // Future state;

//reg [7:0]		RxData;

// FSM states
parameter  
    IDLE      = 5'h0,
    STARTBIT  = 5'h1,
    DATA      = 5'h2,
    STOP      = 5'h3,
	  WAIT		  = 5'h4;

always@(posedge Clk or negedge Rst_n)
  if (!Rst_n)state <= IDLE;
  else state <= next_state; 

always@(rx_sync or RxEn or waitDone or waitBitsDone or state)
  case(state)
    IDLE:     if (!rx_sync && RxEn) next_state = STARTBIT;
              else next_state = IDLE;
    STARTBIT: if (waitDone) next_state = DATA;
              else next_state = STARTBIT; 
    DATA:     if (waitBitsDone) next_state = STOP;
              else next_state = DATA;
    STOP:     if (waitDone) next_state = IDLE;
              else next_state = STOP;  
  endcase

always@(rx_sync or RxEn or waitDone or state or incommingData)
 begin
  waitHalfBitTime = 1'b0;
  waitFullBitTime = 1'b0;
  waitNBits       = 1'b0;
  RxDone          = 1'b0;
  captureData     = 1'b0;
  case(state)
    IDLE: if (!rx_sync && RxEn) waitHalfBitTime = 1'b1;   
    STARTBIT: if (waitDone) begin
                              waitFullBitTime = 1'b1;
                              waitNBits       = 1'b1;
                            end
    DATA: begin
           if (waitDone) begin
                          waitFullBitTime = 1'b1;
                          captureData     = 1'b1; 
                         end
           else waitFullBitTime = 1'b0; 
          end
    STOP: begin
           if (waitDone)begin
                          waitHalfBitTime = 1'b1;
                          RxDone = rx_sync;
                        end
           else waitHalfBitTime = 1'b0; 
          end
  endcase
 end 
 
always @(posedge Clk or negedge Rst_n)
    if (!Rst_n)
        timer <= 6'h0;
    else if (waitHalfBitTime)
        timer <= 6'd8;
    else if (waitFullBitTime)
        timer <= 6'd16;
    else if (timer != 0 && tick == 1'b1) 
        timer <= timer - 6'd1;
    
// Timer expires when its value is 1.
assign waitDone = (timer == 0);

assign waitDonePos = (~waitDonePosReg & waitDone);
always @(posedge Clk or negedge Rst_n)
    if (!Rst_n) waitDonePosReg <=  1'b0;
    else waitDonePosReg <= waitDone;

always @(posedge Clk or negedge Rst_n)
    if (!Rst_n)
        bits <= 4'h0;
    else if (waitNBits)
        bits <= nBits;
    else if (bits != 0 && waitDonePos == 1'b1) 
        bits <= bits - 4'd1;
    
// Bits expires when its value is 1.
assign waitBitsDone = (bits == 0);


// RX shift register
always @(posedge Clk or negedge Rst_n)
    if (!Rst_n) incommingData <= 8'h0;
    else if (captureData  == 1'b1) begin
                            incommingData[7] <= rx_sync;
                            incommingData[6:0] <= incommingData[7:1];
                          end
                          
//The number of bits of transmitted data is programmable. For such cases that nBits < 8,
//zeros are added in order to erase old data and avoid problems. 

assign RxData = ( (nBits == 4'h6) ? {incommingData[7:2],2'h0} :
                  (nBits == 4'h7) ? {incommingData[7:1], 1'h0} :
                  (nBits == 4'h8) ? incommingData[7:0] : 8'h0 );
                  
//  Synchronization of Rx input signal
//  Rx must be synchronized to avoid metastability problems.

uar_synchro i_synchro_rx (
                    .Clk                  (Clk               ),
                    .Rst_n                (Rst_n             ),
                    .AsyncIn              (Rx                ),
                    .SyncOut              (rx_sync           )
                    );
                        
endmodule