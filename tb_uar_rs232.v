`timescale 1ns/1ps
 
module tb_uar_rs232();

wire          clk50MHz            ;
wire          Rst_n               ;
wire          Tx                  ; // RS232 Tx line.
wire          Rx                  ; // RS232 Rx line. 
wire           		AW_valid            ; // Write address valid. Indicates that the master signaling valid write address and control information.
wire          			W_valid             ; // Write valid. Indicates that valid write data and strobes are available.
wire           		W_last              ; // Write last. Indicates that the W_data channel is signaling the last data of the burst.
wire           		B_ready             ; // Response ready. Indicates that the master can accept a write response.
wire          		AW_ready            ; // Write address ready. Indicates that the slave is ready to accept an address and associated control signals.
wire          		W_ready             ; // Write ready. Indicates that the slave can accept the write data.
wire          		B_valid             ; // Write response valid. Indicates that the channel is signaling a valid write response.
wire   	[31:0]		AW_add             	; // Bus address for write trransactions.
wire   	[31:0]  	W_data             	; // Write bus.
wire  	[1:0]   	B_response          ; // Write response. Indicates the status of the write transaction.
wire   	[31:0] 		AR_add		  		; // Bus address for read trransactions.   
wire    				AR_valid   	  		; // Read address valid. Indicates that the channel is signaling valid read address and control information.
wire    				AR_ready	   		; // Read address ready. Indicates that the slave is ready to accept an address and associated control signals.
wire 		[31:0] 		R_data			    ; // Read bus.
wire   				R_valid		    	; // Read valid. Indicates that the channel is signaling the required read data.
wire    				R_last		   		; // Read last. Indicates that the R_data channel is signaling the last data of the burst. 
wire    				R_ready		  		; // Read ready. Indicates that the master can accept the read data and response information.
wire  	[1:0]  		R_resp		    	; // Read response. Indicates the status of the read transfer.
wire  		[3:0] 		W_strb             	; // Write strobes. Indicates which byte lanes hold valid data.
wire [7:0]AW_len  ; 		  
wire [1:0]AW_burst ; 		  
wire   [7:0] AR_len ;  		  
wire    [1:0]AR_burst; 

wire	AW_lock				 ;
wire	[3:0] AW_cache   			 ;
wire	[2:0] AW_prot 			 ;
wire	AW_qos				 ;
wire	AW_region 			 ;
wire	AW_user 			 ;
wire	AW_id 				 ; 
wire	[2:0] AW_size			 	 ;
wire	W_user 				 ;
wire	B_user 				 ; 		
wire	B_id 				 ;
wire	AR_id				 ;
wire	[2:0] AR_size 			 ;
wire	AR_lock				 ;
wire	[3:0] AR_cache   			 ;
wire	[2:0] AR_prot 			 ;
wire	AR_qos				 ;
wire	AR_region 			 ;
wire	AR_user 			 ;
wire	R_id				 ;	
wire	R_user				 ;

uar_rs232_avalon I_uar_rs232_avalon(
    .Clk                  (clk50MHz),
    .Rst_n                (Rst_n),
    .Rx                   (Tx),
    .Tx                   (Rx),
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
    .AR_add		  (AR_add),
    .AR_valid		  (AR_valid),
    .AR_ready	 	  (AR_ready),
    .R_data	  	  (R_data),
    .R_valid		  (R_valid),
    .R_last		  (R_last),
    .R_resp		  (R_resp),
    .R_ready		  (R_ready),
    .AW_len   		  (AW_len),
    .AW_burst  		  (AW_burst),
    .AR_len   		  (AR_len ),
    .AR_burst    	  (AR_burst),

    .AW_lock				 (AW_lock),
	.AW_cache   			 (AW_cache),
	.AW_prot 			 (AW_prot),
	.AW_qos				 (AW_qos),
	.AW_region 			 (AW_region),
	.AW_user 			 (AW_user),
	.AW_id 				 (AW_id), 
	.AW_size			 	(AW_size) ,
	.W_user 				 (W_user),
	.B_id 				 (B_id),
	.B_user 				(B_user) , 		
	.AR_id				 (AR_id),
	.AR_size 			 (AR_size),
	.AR_lock				(AR_lock) ,
	.AR_cache   			 (AR_cache),
	.AR_prot 			 (AR_prot),
	.AR_qos				 (AR_qos),
	.AR_region 			 (AR_region),
	.AR_user 			 (AR_user),
	.R_id				 (R_id),	
	.R_user				 (R_user)   
    );

sys_clk50MHz_fm I_sys_clk50MHz_fm(
    .Clk             (clk50MHz)
    );

sys_rst_fm I_sys_rst_fm(                  
    .Rst_n                (Rst_n)                   
    );

uart_fm I_uart_fm(
    .Tx                   (Tx),
    .Rx                   (Rx)                    
    );

master_bus_fm I_master_bus_fm(
    .Clk                  (clk50MHz),
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
    .AR_add		  (AR_add),
    .AR_valid		  (AR_valid),
    .AR_ready	 	  (AR_ready),
    .R_data	  	  (R_data),
    .R_valid		  (R_valid),
    .R_last		  (R_last),
    .R_resp		  (R_resp),
    .R_ready		  (R_ready),
    .AW_len   		  (AW_len),
    .AW_burst  		  (AW_burst),
    .AR_len   		  (AR_len ),
    .AR_burst    	  (AR_burst),

        .AW_lock				 (AW_lock),
	.AW_cache   			 (AW_cache),
	.AW_prot 			 (AW_prot),
	.AW_qos				 (AW_qos),
	.AW_region 			 (AW_region),
	.AW_user 			 (AW_user),
	.AW_id 				 (AW_id), 
	.AW_size			 	(AW_size) ,
	.W_user 				 (W_user),
	.B_id 				 (B_id),
	.B_user 				(B_user) , 		
	.AR_id				 (AR_id),
	.AR_size 			 (AR_size),
	.AR_lock				(AR_lock) ,
	.AR_cache   			 (AR_cache),
	.AR_prot 			 (AR_prot),
	.AR_qos				 (AR_qos),
	.AR_region 			 (AR_region),
	.AR_user 			 (AR_user),
	.R_id				 (R_id),	
	.R_user				 (R_user) 
    );
               
endmodule