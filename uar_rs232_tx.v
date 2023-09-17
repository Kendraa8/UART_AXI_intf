`timescale 1ns/1ps

module uar_rs232_tx(
    Clk                  ,
    Rst_n                ,
    TxEn                 ,
    TxData               ,
    TxDone               ,
    Tx                   ,
    tick                 ,
    nBits
    );

input           Clk                 ; // Clock
input           Rst_n               ; // Reset

input           TxEn                ; // Enable rx operation. Enable only if RX=1
input [7: 0]    TxData              ; // Data to transmit
output          TxDone              ; // Transmission completed.
output          Tx                  ; // RS232 TX line.

input           tick                ; // Baud rate clock

input [3:0]     nBits               ;

reg   [5:0]     timer               ; // Timer register

reg   [3:0]     bits                ; // To counter the number of bits of an incomming frame.

reg             waitFullBitTime     ;
reg             waitNBits           ;
reg             TxDone              ;
reg             waitDonePosReg      ;

wire            waitDonePos;

wire            waitBitsDone        ; 

wire            waitDone            ; // End of count of timer. Active high one clock cycle;        


reg   [4:0]     state               ; // Current state.
reg   [4:0]     next_state          ; // Future state.

reg             sendData            ; // Enables TX shift register. Active high.
reg             loadFrame           ; // Loads data to transmit into TX register.

reg   [9:0]     outData             ; // TX shift register.
wire  [9:0]     frame               ; // Frame to be transmited. TxData+startBit+stopBit.

// FSM states
parameter  
    IDLE      = 5'h0,
    STARTBIT  = 5'h1,
    DATA      = 5'h2,
    STOP      = 5'h3;

always@(posedge Clk or negedge Rst_n)
  if (!Rst_n)state <= IDLE;
  else state <= next_state; 

always@(TxEn or waitDone or waitBitsDone or state)
  case(state)
    IDLE:     if (TxEn) next_state = STARTBIT;
              else next_state = IDLE;
    STARTBIT: if (waitDone) next_state = DATA;
              else next_state = STARTBIT; 
    DATA:     if (waitBitsDone) next_state = STOP;
              else next_state = DATA;
    STOP:     if (waitDone) next_state = IDLE;
              else next_state = STOP;  
  endcase

always@(TxEn or waitDone or state)
 begin
  waitFullBitTime = 1'b0;
  waitNBits       = 1'b0;
  TxDone          = 1'b0;
  sendData        = 1'b0;
  loadFrame       = 1'b0;
  case(state)
    IDLE: if (TxEn) begin
                    waitFullBitTime = 1'b1;   
                    loadFrame = 1'b1;
                    end
    STARTBIT: if (waitDone) begin
                              waitFullBitTime = 1'b1;
                              waitNBits       = 1'b1;
                              sendData        = 1'b1; 
                            end
    DATA: begin
           if (waitDone) begin
                          waitFullBitTime = 1'b1;
                          sendData     = 1'b1; 
                         end
           else waitFullBitTime = 1'b0; 
          end
    STOP: begin
           if (waitDone) TxDone          = 1'b1;
           else TxDone          = 1'b0;
          end
  endcase
 end 
 
always @(posedge Clk or negedge Rst_n)
    if (!Rst_n)
        timer <= 6'h0;
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


// TX shift register
always @(posedge Clk or negedge Rst_n)
    if (!Rst_n) outData <= 10'h3FF;
    else if (loadFrame) outData <= frame;
         else if (sendData  == 1'b1) begin
                            outData[9] <= 1'b1;
                            outData[8:0] <= outData[9:1];
                          end

assign Tx = outData[0];
                         
//The number of bits of transmitted data is programmable. For such cases that nBits < 8,
//zeros are added in order to erase old data and avoid problems. 

assign frame = (  (nBits == 4'h6) ? {3'b111, TxData[5:0],1'h0} :
                  (nBits == 4'h7) ? {2'b11, TxData[6:0], 1'h0} :
                  (nBits == 4'h8) ? {1'b1, TxData[7:0], 1'h0} : 10'h3FF );
                  
                       
endmodule