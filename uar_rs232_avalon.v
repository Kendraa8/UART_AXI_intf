`timescale 1ns/1ps
 
module uar_rs232_avalon(
    Clk                  ,
    Rst_n                ,
    Rx                   ,
    Tx                   ,
    AW_ready             ,
    AW_valid             ,
    W_ready              ,
    W_valid              ,
    W_last               ,
    B_ready              ,
    B_valid              ,
    AW_add               ,
    W_data               ,
    B_response           ,
    W_strb               ,
    AR_add,
    AR_valid			 ,
    AR_ready	 		 ,
    R_data	  			 ,
    R_valid				 ,
    R_last				 ,
    R_resp				 ,
    R_ready				 ,
    AW_len               ,
    AW_burst             ,
    AR_len               ,
    AR_burst             ,

    AW_lock,
    AW_cache,
    AW_prot,
    AW_qos,
    AW_region,
    AW_user,
    AW_id 				 , 
    AW_size			 	 ,
    W_user 				 ,
    B_id 				 ,
    B_user 				 , 		
    AR_id				 ,
    AR_size 			 ,
    AR_lock				 ,
    AR_cache   			 ,
    AR_prot 			 ,
    AR_qos				 ,
    AR_region 			 ,
    AR_user 			 ,
    R_id,	
    R_user
);

input                   Clk                 ; // Clock
input                   Rst_n               ; // Reset
input                   Rx                  ; // RS232 RX line.
output                  Tx                  ; // RS232 TX line.

input           		AW_valid            ; // Write address valid. Indicates that the master signaling valid write address and control information.
input          			W_valid             ; // Write valid. Indicates that valid write data and strobes are available.
input           		W_last              ; // Write last. Indicates that the W_data channel is signaling the last data of the burst.
input           		B_ready             ; // Response ready. Indicates that the master can accept a write response.
output          		AW_ready            ; // Write address ready. Indicates that the slave is ready to accept an address and associated control signals.
output          		W_ready             ; // Write ready. Indicates that the slave can accept the write data.
output          		B_valid             ; // Write response valid. Indicates that the channel is signaling a valid write response.
input   	[5:0]		AW_add             	; // Bus address for write trransactions.
input   	[31:0]  	W_data             	; // Write bus.
output  	[1:0]   	B_response          ; // Write response. Indicates the status of the write transaction.
input   	[5:0] 		AR_add		  		; // Bus address for read trransactions.   
input    				AR_valid   	  		; // Read address valid. Indicates that the channel is signaling valid read address and control information.
output    				AR_ready	   		; // Read address ready. Indicates that the slave is ready to accept an address and associated control signals.
output 		[31:0] 		R_data			    ; // Read bus.
output   				R_valid		    	; // Read valid. Indicates that the channel is signaling the required read data.
output    				R_last		   		; // Read last. Indicates that the R_data channel is signaling the last data of the burst. 
input    				R_ready		  		; // Read ready. Indicates that the master can accept the read data and response information.
output  	[1:0]  		R_resp		    	; // Read response. Indicates the status of the read transfer.
input  		[3:0] 		W_strb             	; // Write strobes. Indicates which byte lanes hold valid data.

input 		[7:0]		AW_len				; // Burst length. The burst length gives the exact number of transfers in a burst
input		[1:0]		AW_burst			; // Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated
input		[7:0]		AR_len				; // Burst length. The burst length gives the exact number of transfers in a burst
input		[1:0]		AR_burst			; // Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated.

input	    [0:0]       AW_lock		;
input	    [3:0]       AW_cache   	;
input	    [2:0]       AW_prot 	;
input	                AW_qos		;
input	                AW_region 	;
input	    [1:0]       AW_user 	;
input	    [7:0]       AW_id 		; 
input	    [2:0]       AW_size		;
input	    [1:0]       W_user 		;
output	    [1:0]       B_user 		; 		
output	    [7:0]       B_id 		;
input	    [7:0]       AR_id		;
input	    [2:0]       AR_size 	;
input	    [0:0]       AR_lock		;
input	    [3:0]       AR_cache   	;
input	    [2:0]       AR_prot 	;
input	                AR_qos		;
input	                AR_region 	;
input	    [1:0]       AR_user 	;
output	    [7:0]       R_id		;	
output	    [1:0]       R_user		;

wire        [15:0]      baudRate            ;
wire        [3:0]       nBits               ;
wire                    RxEn                ; // Enables RX channel. Active high.
wire                    TxEn                ; // Enables TX channel. Active high.
wire        [3:0]       RxStatusFifo        ; // Number of received bytes pending to be read in the RX FIFO.
wire                    RxEmpty             ; // Indicates RX FIFO empty. Active high.
wire                    RxFull              ; // Indicates RX FIFO full. Active high.
wire        [3:0]       TxStatusFifo        ; // Number of bytes pending to be transmitted in the TX FIFO.
wire                    TxEmpty             ; // Indicates TX FIFO empty. Active high.
wire                    TxFull              ; // Indicates TX FIFO full. Active high.
wire        [7:0]       RxDataFifo          ;
wire        [7:0]       TxDataFifo          ;
wire                    RdFifoRx            ;
wire                    WrFifoTx            ;

wire                    TxDone              ; // Trnasmission completed. Data sent.
wire                    RxDone              ; // Reception completed. Data is valid.

wire        [7:0]       RxData              ;
wire        [7:0]       TxData              ;

uar_rs232_slave_interface I_uar_rs232_slave_interface(
    .Clk                  (Clk),
    .Rst_n                (Rst_n),
    .AW_ready             (AW_ready),
    .AW_valid             (AW_valid),
    .W_ready              (W_ready),
    .W_valid              (W_valid),
    .W_last               (W_last),
    .B_ready              (B_ready),
    .B_valid              (B_valid),              
    .AW_add               (AW_add),
    .W_data               (W_data),
    .B_response           (B_response),
    .W_strb               (W_strb),
    .AR_add		          (AR_add),
    .AR_valid		      (AR_valid),
    .AR_ready	 	      (AR_ready),
    .R_data	  	          (R_data),
    .R_valid		      (R_valid),
    .R_last		          (R_last),
    .R_resp		          (R_resp),
    .R_ready		      (R_ready), 

    .baudRate             (baudRate),
    .nBits                (nBits),
    .RxEn                 (RxEn),
    .TxEn                 (TxEn),
    .RxStatusFifo         (RxStatusFifo), 
    .RxEmpty              (RxEmpty),
    .RxFull               (RxFull),
    .TxStatusFifo         (TxStatusFifo), 
    .TxEmpty              (TxEmpty),
    .TxFull               (TxFull),
    .RxDataFifo           (RxDataFifo),
    .TxDataFifo           (TxDataFifo),
    .RdFifoRx             (RdFifoRx),
    .WrFifoTx             (WrFifoTx),
    .RxDone               (RxDone),
    .TxDone               (TxDone),

    .AW_len   		      (AW_len),
    .AW_burst  		      (AW_burst),
    .AR_len   		      (AR_len ),
    .AR_burst    	      (AR_burst),
    .AW_lock			  (AW_lock),
	.AW_cache   		  (AW_cache),
	.AW_prot 			  (AW_prot),
	.AW_qos				  (AW_qos),
	.AW_region 			  (AW_region),
	.AW_user 			  (AW_user),
	.AW_id 				  (AW_id), 
	.AW_size			  (AW_size) ,
	.W_user 			  (W_user),
	.B_id 				  (B_id),
	.B_user 			  (B_user) , 		
	.AR_id				  (AR_id),
	.AR_size 			  (AR_size),
	.AR_lock			  (AR_lock) ,
	.AR_cache   		  (AR_cache),
	.AR_prot 			  (AR_prot),
	.AR_qos				  (AR_qos),
	.AR_region 			  (AR_region),
	.AR_user 			  (AR_user),
	.R_id				  (R_id),	
	.R_user				  (R_user)
);
    
uar_rs232 I_uar_rs232(
    .Clk                  (Clk),
    .Rst_n                (Rst_n),
    .RxEn                 (RxEn),
    .RxData               (RxData),
    .RxDone               (RxDone),
    .Rx                   (Rx),
    .TxEn                 (!TxEmpty & TxEn),
    .TxData               (TxData),
    .TxDone               (TxDone),
    .Tx                   (Tx),
    .nBits                (nBits),
    .baudRate             (baudRate)
);


fifo #(.B(8), .W(3)) I_fifo_rx_unit(
    .clk                  (Clk), 
    .reset_n              (Rst_n), 
    .rd                   (RdFifoRx),
    .wr                   (RxDone), 
    .w_data               (RxData),
    .empty                (RxEmpty), 
    .full                 (RxFull), 
    .r_data               (RxDataFifo),
    .status_fifo          (RxStatusFifo)
);

fifo #(.B(8), .W(3)) I_fifo_tx_unit(
    .clk                  (Clk), 
    .reset_n              (Rst_n), 
    .rd                   (TxDone),
    .wr                   (WrFifoTx), 
    .w_data               (TxDataFifo), 
    .empty                (TxEmpty),
    .full                 (TxFull), 
    .r_data               (TxData),
    .status_fifo          (TxStatusFifo)
);
        
endmodule