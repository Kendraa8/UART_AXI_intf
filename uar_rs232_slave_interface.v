`timescale 1ns/1ps
`include "../src/global.v"
 
module uar_rs232_slave_interface(
    Clk                  ,
    Rst_n                ,

  //AXI
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
    AR_add				 ,
    AR_valid			 ,
    AR_ready	 		 ,
    R_data	  			 ,
    R_valid				 ,
    R_last				 ,
    R_resp				 ,
    R_ready				 ,
	AW_len				 ,				
	AW_burst			 ,
	AR_len				 ,
	AR_burst			 ,

	AW_lock				 ,
	AW_cache   			 ,
	AW_prot 			 ,
	AW_qos				 ,
	AW_region 			 ,
	AW_user 			 ,
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
	R_id				 ,	
	R_user				 ,

  //UART
    baudRate             ,
    nBits                ,
    RxEn                 ,
    TxEn                 ,
    RxStatusFifo         , 
    RxEmpty              ,
    RxFull               ,
    TxStatusFifo         , 
    TxEmpty              ,
    TxFull               ,
    RxDataFifo           ,
    TxDataFifo           ,
    RdFifoRx             ,
    WrFifoTx             ,
    RxDone               ,
    TxDone              
);

input          			Clk              	; // Clock
input          			Rst_n               ; // Reset

//AXI
input 		[3:0]		AW_len	  	    ; // Burst length. The burst length gives the exact number of transfers in a burst
input		[1:0]		AW_burst	    ; // Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated
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
input    			AR_valid   	  		; // Read address valid. Indicates that the channel is signaling valid read address and control information.
output    			AR_ready	   		; // Read address ready. Indicates that the slave is ready to accept an address and associated control signals.
input		[3:0]		AR_len				; // Burst length. The burst length gives the exact number of transfers in a burst
input		[1:0]		AR_burst			; // Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated.
output 		[31:0] 		R_data			    ; // Read bus.
output   				R_valid		    	; // Read valid. Indicates that the channel is signaling the required read data.
output    				R_last		   		; // Read last. Indicates that the R_data channel is signaling the last data of the burst. 
input    				R_ready		  		; // Read ready. Indicates that the master can accept the read data and response information.
output  	[1:0]  		R_resp		    	; // Read response. Indicates the status of the read transfer.
input  		[3:0] 		W_strb             	; // Write strobes. Indicates which byte lanes hold valid data.

//UART
output  	[15:0]  	baudRate            ;
output  	[3:0]   	nBits               ;
output         			RxEn                ; // Enables RX channel. Active high.
output         			TxEn                ; // Enables TX channel. Active high.
input   	[3:0]   	RxStatusFifo        ; // Number of received bytes pending to be read in the RX FIFO.
input          			RxEmpty             ; // Indicates RX FIFO empty. Active high.
input          			RxFull              ; // Indicates RX FIFO full. Active high.
input   	[3:0]   	TxStatusFifo        ; // Number of bytes pending to be transmitted in the TX FIFO.
input          			TxEmpty             ; // Indicates TX FIFO empty. Active high.
input          			TxFull              ; // Indicates TX FIFO full. Active high.
input   	[7:0]   	RxDataFifo          ;
output  	[7:0]   	TxDataFifo          ;
output         			RdFifoRx            ;
output         			WrFifoTx            ;
input          			RxDone              ; // Reception completed. Data is valid.
input          			TxDone              ; // Trnasmission completed. Data sent.

input		[0:0]    	AW_lock				;
input		[3:0] 		AW_cache   			;
input		[2:0] 		AW_prot 			;
input				AW_qos				;
input				AW_region 			;
input		[1:0]    	AW_user 			;
input		[7:0]           AW_id 				; 
input		[2:0] 		AW_size			 	;
input		[1:0]           W_user 				;
output		[1:0]           B_user 				; 		
output		[7:0]           B_id 				;
input		[7:0]           AR_id				;
input		[2:0] 		AR_size 			;
input		[0:0]    	AR_lock				;
input		[3:0] 		AR_cache   			;
input		[2:0] 		AR_prot 			;
input				AR_qos				;
input				AR_region 			;
input		[1:0]           AR_user 			;
output		[7:0]           R_id				;	
output		[1:0]           R_user				;

wire            		selConConfig_w      ; // Indicates that UAR_COM_CONFIG register is selected as a target for read/write operations.
wire           			selFifoRx_w         ; // Indicates that UAR_FIFO_RX register is selected as a target for read/write operations.
wire            		selFifoTx_w         ; // Indicates that UAR_FIFO_Tx register is selected as a target for read/write operations.
wire           			selDataRx_w         ; // Indicates that UAR_DATA_RX register is selected as a target for read/write operations.
wire           			selDataTx_w         ; // Indicates that UAR_DATA_TX register is selected as a target for read/write operations.
wire           			selIrq_w            ; // Indicates that UAR_IRQ register is selected as a target for read/write operations.
wire           			selConConfig_r      ; // Indicates that UAR_COM_CONFIG register is selected as a target for read/write operations.
wire           			selFifoRx_r         ; // Indicates that UAR_FIFO_RX register is selected as a target for read/write operations.
wire           			selFifoTx_r         ; // Indicates that UAR_FIFO_Tx register is selected as a target for read/write operations.
wire           			selDataRx_r         ; // Indicates that UAR_DATA_RX register is selected as a target for read/write operations.
wire           			selDataTx_r         ; // Indicates that UAR_DATA_TX register is selected as a target for read/write operations.
wire           			selIrq_r            ; // Indicates that UAR_IRQ register is selected as a target for read/write operations.
wire           			RxIrqMask           ; // Rx IRQ mask. If 0 = IRQ disabled.
wire           			TxIrqMask           ; // Tx IRQ mask. If 0 = IRQ disabled.
wire           			RxIrq               ; // Rx interrupt.
wire           			TxIrq               ; // Tx interrupt.

reg     	[31:0] 		ConConfig           ; // Register UAR_COM_CONFIG;
reg     	[7:0]  		FifoRx              ; // Register UAR_FIFO_RX;
reg     	[7:0]  		FifoTx              ; // Register UAR_FIFO_Tx;
reg     	[7:0]  		DataRx              ; // Register UAR_DATA_RX;
reg     	[7:0]  		DataTx				; // Register UAR_DATA_TX;
reg            			WrFifoTxReg         ;
reg            			RxDoneReg           ;
reg            			TxDoneReg           ;
reg            			RxIrqCapture        ;
reg            			TxIrqCapture        ;

//I/O AXI registers

reg        			awready             ;
reg        			wready              ;
reg        			bvalid              ;
reg   		[31:0]   	awadd               ;
reg  		[1:0]   	bresp               ;
reg   		[31:0] 		aradd		    	;    
reg    				arready	    		;
reg   				rvalid		    	;
reg    				rlast		    	;
reg  		[1:0]  		rresp		    	;

integer				byte_index			;
reg        	[31:0]		rdata           ; // Read operations are allowd when slave_read and slave_chipselect are asserted.
reg 		[31:0]		mem_data_out;
wire 		[31:0]		data_out;
//registers and wires to control burst transfers
reg 				awv_awr_flag		; // The axi_awv_awr_flag flag marks the presence of write address valid
reg 				arv_arr_flag		; //The axi_arv_arr_flag flag marks the presence of read address valid
reg 		[7:0] 		awlen_cntr			; // The axi_awlen_cntr internal write address counter to keep track of beats in a burst transaction
reg 		[7:0] 		arlen_cntr			; //The axi_arlen_cntr internal read address counter to keep track of beats in a burst transaction
wire 				aw_wrap_en			; // aw_wrap_en determines wrap boundary and enables wrapping
wire 				ar_wrap_en			; // ar_wrap_en determines wrap boundary and enables wrapping
wire 		integer  	aw_wrap_size 		; // ar_wrap_size is the size of the read transfer, the read address wraps to a lower address if upper address limit is reached
wire 		integer  	ar_wrap_size 		; 
reg valid_read;
// Output Connections assignments
assign AW_ready	    = awready;
assign W_ready	    = wready & (!TxFull| !selDataTx_w);
assign B_response   = bresp;
assign B_valid	    = bvalid;
assign AR_ready	    = arready;
assign R_resp	    = rresp;
assign R_valid	    = rvalid ;//& (!RxEmpty | !selDataRx_r);
assign R_last	    = rlast;
assign R_data	    = rdata;
assign AW_id        = 8'b0;
assign AR_id        = 8'b0;
assign B_id         = 8'b0;
assign R_id         = 8'b0;

// Internal control signs
assign  aw_wrap_size = (32/8 * (AW_len)); 
assign  ar_wrap_size = (32/8 * (AR_len)); 
assign  aw_wrap_en = ((awadd & aw_wrap_size) == aw_wrap_size)? 1'b1: 1'b0;
assign  ar_wrap_en = ((aradd & ar_wrap_size) == ar_wrap_size)? 1'b1: 1'b0;

// UAR_COM_CONFIG
assign baudRate = ConConfig[15:0];
assign nBits    = ConConfig[19:16];
assign RxEn     = ConConfig[20];
assign TxEn     = ConConfig[21];
assign RxIrqMask= ConConfig[22];
assign TxIrqMask= ConConfig[23];

// Internal decoder
assign selConConfig_w   = (awadd == `ADDR_UAR_COM_CONFIG  ? 1'b1 : 1'b0);
assign selFifoRx_w      = (awadd == `ADDR_UAR_FIFO_RX     ? 1'b1 : 1'b0);
assign selFifoTx_w      = (awadd == `ADDR_UAR_FIFO_TX     ? 1'b1 : 1'b0);
assign selDataRx_w      = (awadd == `ADDR_UAR_DATA_RX     ? 1'b1 : 1'b0);
assign selDataTx_w      = (awadd == `ADDR_UAR_DATA_TX     ? 1'b1 : 1'b0);
assign selIrq_w         = (awadd == `ADDR_UAR_IRQ         ? 1'b1 : 1'b0);

//------- WRITE ------
// IMPLEMENT awready GENERATION:
// awready is asserted for one CLK clock cycle when AW_valid and W_valid is 
// valid and awready isn't valid. 

always @( posedge Clk or negedge Rst_n )
begin
	if ( !Rst_n )
	begin
		//awready <= 1'b0;
		awv_awr_flag  <= 1'b0;
		awready <= 1'b0;
	end 
	else
	begin    
		if (~awready && AW_valid && ~awv_awr_flag && ~arv_arr_flag)// && !TxFull) //&& W_valid && !TxFull)
		begin
			awready <= 1'b1;
			awv_awr_flag  <= 1'b1;
		end
		else if (W_last && wready)// && !TxFull)// preparing to accept next address after current write burst tx completion             
		begin
			awv_awr_flag  <= 1'b0;
			awready <= 1'b0;
			//awadd <= 31'b0;

		end
		else  
		begin
			awready <= 1'b0;
		end
	end 
end  

// IMPLEMENT awadd LATCHING:
// Implement awadd high when both AW_valid and W_valid are valid. 

always @( posedge Clk or negedge Rst_n )
begin
	if ( !Rst_n )
	begin
		awadd <= 31'b0;
		awlen_cntr <= 0;
	end 
	else
	begin    
		if (AW_valid && ~awready && ~awv_awr_flag)// && W_valid)
		begin
			// Write Address latching 
			awadd <= {26'h0, AW_add};
			// start address of transfer
			awlen_cntr <= 0;
		end
		else if((awlen_cntr <= AW_len) && wready && W_valid)        
		begin
			awlen_cntr <= awlen_cntr + 1;
			case (AW_burst)
				2'b00: // Fixed burst: Writes the same address repeatedly.
					begin
						awadd <= awadd; //The same adress is kept          
					end   
				2'b01: //Incremental burst: The write address for all the beats in the transaction are increments by awsize
					begin
						awadd[31:2] <= awadd[31:2] + 1;
						//awaddr aligned to 4 byte boundary
						awadd[1:0]  <= {2{1'b0}};   
						//for awsize = 4 bytes and add_width = 32
					end   
				2'b10: //Wrapping burst:The write address wraps when the address reaches wrap boundary 
					if (aw_wrap_en) //limit reached
						begin
							awadd <= (awadd - aw_wrap_size); 
						end
					else // increment adress like incremental burst
						begin
							awadd[31:2] <= awadd[31:2] + 1;
							//awaddr aligned to 4 byte boundary
							awadd[1:0]  <= {2{1'b0}};   
							//for awsize = 4 bytes and add_width = 32
						end                      
				default: //reserved (fixed burst for example)
					begin
						awadd <= awadd; //The same adress is kept
					end
			endcase  
		end
	end 
end  

// IMPLEMENT wready GENERATION:
// Implement wready generation when W_valid is valid or wready isn't valid 
// because the slave can wait for W_valid

always @( posedge Clk or negedge Rst_n )
begin
	if ( !Rst_n )
	begin
		wready <= 1'b0;
	end 
	else
	begin    
		if (~wready && W_valid  && awv_awr_flag)//&& AW_valid 
		begin
			wready <= 1'b1;
		end
		else if (W_last && wready) 
		begin
			wready <= 1'b0;
		end
	end 
end   

/*
// Implement memory mapped register select and write logic generation
always @(  posedge Clk or negedge Rst_n  )
begin
	  if ( !Rst_n )
	    begin
	      wdata <= 32'b0;
              valid_write <= 1'b0;
	    end 
	  else
	    begin    
	      if (wready && W_valid)// && awready && AW_valid) AIXO EL MES REVISABLE
	        begin
              
	          for ( byte_index = 0; byte_index <= (32/8-1); byte_index = byte_index+1 )
	              if ( W_strb[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                wdata[(byte_index*8) +: 8] <= W_data[(byte_index*8) +: 8];
	              end 
		  valid_write<=1'b1;
	        end
	      else
	        begin
              valid_write<=1'b0;
	        end
	    end 
	end   
*/

//Write registers
//UAR_CON_CONFIG
always @(posedge Clk or negedge Rst_n)
	if (!Rst_n) ConConfig <= 32'h1000A3; //8 bits i 19200b/s.
	else if (selConConfig_w && wready && W_valid) 
	begin
		for ( byte_index = 0; byte_index <= (32/8-1); byte_index = byte_index+1 )
		if ( W_strb[byte_index] == 1 ) 
		begin
		// Respective byte enables are asserted as per write strobes 
		ConConfig[(byte_index*8) +: 8]<= W_data[(byte_index*8) +: 8];
		end 
	//ConConfig <= W_data;
	end

//UAR_FIFO_RX
always @(posedge Clk or negedge Rst_n)
	if (!Rst_n) FifoRx <= 32'h0;
	else FifoRx <= {26'h0, RxStatusFifo, RxEmpty, RxFull};
  
//UAR_FIFO_TX
always @(posedge Clk or negedge Rst_n)
	if (!Rst_n) FifoTx <= 32'h0;
	else FifoTx <= {26'h0, TxStatusFifo, TxEmpty, TxFull};

//UAR_DATA_RX
always @(posedge Clk or negedge Rst_n)
	if (!Rst_n) DataRx <= 32'h0;
	else DataRx <= {24'h0, RxDataFifo};

//UAR_DATA_TX 
assign TxDataFifo = DataTx[7:0];

always @(posedge Clk or negedge Rst_n)
	if (!Rst_n) DataTx <= 32'hFF;
	else if (selDataTx_w && wready && W_valid && !TxFull)
	begin
		for ( byte_index = 0; byte_index <= (32/8-1); byte_index = byte_index+1 )
		if ( W_strb[byte_index] == 1 ) 
		begin
		// Respective byte enables are asserted as per write strobes 
		DataTx[(byte_index*8) +: 8]<= W_data[(byte_index*8) +: 8];
		end 
	end //DataTx <= W_data;

//Delay
always @(posedge Clk or negedge Rst_n)
  if (!Rst_n) WrFifoTxReg = 1'b0;
  else WrFifoTxReg = wready && W_valid & selDataTx_w & !TxFull;

assign WrFifoTx = WrFifoTxReg;

// IMPLEMENT WRITE RESPONSE LOGIC GENERATION:
// The write response and response valid signals are asserted by the slave 
// when W_last is asserted.  

	always @( posedge Clk or negedge Rst_n )
	begin
	  if (  !Rst_n )
	    begin
	      bvalid  <= 0;
	      bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (awv_awr_flag  && ~bvalid && wready && W_valid && W_last)// && awready)
	        begin
	          // indicates a valid write response is available
	          bvalid <= 1'b1;
	          bresp  <= 2'b0; // 'OKAY' response 
	        end                   
	      else if (B_ready && bvalid) //check if bready is asserted while bvalid is high)
	        begin
            	bvalid  <= 0;
	        end
	    end
	end   


//------- READ ------  
// Implement arready generation
always @( posedge Clk or negedge Rst_n )
	begin
	  if ( !Rst_n )
	    begin
	    	arready <= 1'b0;
			arv_arr_flag <= 1'b0;
	    end 
	  else
	    begin    
	      if (~arready && AR_valid && ~awv_awr_flag && ~arv_arr_flag)
	        begin // indicates that the slave has acceped the valid read address
	        	arready <= 1'b1;
				arv_arr_flag <= 1'b1;
	        end
	      else if (rvalid && R_ready && arlen_cntr+1==AR_len)
	      // preparing to accept next address after current read completion
	        begin
	        	arv_arr_flag  <= 1'b0;
	        	arready <= 1'b0;
	        end
	      else        
	        begin
	        	arready <= 1'b0;
	        end
	    end 
	end

// IMPLEMENT axi_araddr LATCHING
// This process is used to latch the address when both AR_valid and R_valid are valid. 
always @( posedge Clk or negedge Rst_n )
begin
	if ( !Rst_n )
	begin
		aradd <= 0;
		arlen_cntr <= 1;
		rlast <= 1'b0;
	end 
	else
	begin    
		if (~arready && AR_valid && ~arv_arr_flag)
		begin
			// address latching 
			aradd <= {26'h0, AR_add}; 
			// start address of transfer
			arlen_cntr <= 0;
			rlast <= 1'b0;
		end   
		else if((arlen_cntr <= AR_len) && rvalid && R_ready)        
		begin
			arlen_cntr <= arlen_cntr + 1;
			rlast <= 1'b0;
			case (AR_burst)
			2'b00: // Fixed burst: The read address for all the beats in the transaction are fixed
				begin
					aradd <= aradd; //The same adress is kept        
					//for arsize = 4 bytes (010)
				end   
			2'b01: //Incremental burst: The read address for all the beats in the transaction are increments by awsize
				begin
					aradd[31:2] <= aradd[31:2] + 1; 
					//araddr aligned to 4 byte boundary
					aradd[1:0]  <= {2{1'b0}};  
					//for awsize = 4 bytes (010)
				end   
			2'b10: //Wrapping burst: The read address wraps when the address reaches wrap boundary 
				if (ar_wrap_en) 
					begin
						aradd <= (aradd - ar_wrap_size); 
					end
				else 
					begin // increment adress like incremental burst
						aradd[31:2] <= aradd[31:2] + 1; 
						//araddr aligned to 4 byte boundary
						aradd[1:0]  <= {2{1'b0}};   
					end                      
			default: //reserved (Fixed burst for example)
				begin
					aradd <= aradd;
				end
			endcase              
		end
		else if((arlen_cntr == AR_len) && ~rlast && arv_arr_flag )   
		begin
			rlast <= 1'b1;
			
		end          
		else if (R_ready) //ja s'ha acabat la lectura, pasem a enviar la resposta.   
		begin
			rlast <= 1'b0;
			arv_arr_flag <= 1'b0;
		end          
	end 
end       

//Internal decoder
assign selConConfig_r   = (aradd == `ADDR_UAR_COM_CONFIG  ? 1'b1 : 1'b0);
assign selFifoRx_r      = (aradd == `ADDR_UAR_FIFO_RX     ? 1'b1 : 1'b0);
assign selFifoTx_r      = (aradd == `ADDR_UAR_FIFO_TX     ? 1'b1 : 1'b0);
assign selDataRx_r      = (aradd == `ADDR_UAR_DATA_RX     ? 1'b1 : 1'b0);
assign selDataTx_r      = (aradd == `ADDR_UAR_DATA_TX     ? 1'b1 : 1'b0);
assign selIrq_r         = (aradd == `ADDR_UAR_IRQ         ? 1'b1 : 1'b0);



always @( posedge Clk or negedge Rst_n  )
begin
	if ( !Rst_n )
	begin
		rvalid <= 1'b0;
		rresp <= 2'b00;
	end 
	else 
	begin    
		if (arv_arr_flag && ~rvalid && (!selDataRx_r || !RxEmpty))
		begin
			// Valid read data is available at the read data bus
			rvalid <= valid_read | !selDataRx_r;
			rresp <= 2'b00;
			valid_read <= 0;
		end  
		else if (rvalid && R_ready)
		begin
			// Read data is accepted by the master
			rvalid <= 1'b0;
		end                
	end
end 
/*
// IMPLEMENT rvalid GENERATION:
always @( posedge Clk or negedge Rst_n  )
begin
	if ( !Rst_n )
	begin
		rvalid <= 1'b0;
		rresp <= 2'b00;
	end 
	else 
	begin    
		if (arv_arr_flag && ~rvalid && !selDataRx_r)
		begin
			// Valid read data is available at the read data bus
			rvalid <= 1'b1;
			rresp <= 2'b00;
		end  
		else if (arv_arr_flag && ~rvalid && selDataRx_r && !RxEmpty)
		begin
			rvalid <= valid_read;
			rresp <= 2'b00;
			valid_read <= 0;
		end 
		else if (rvalid && R_ready)
		begin
			// Read data is accepted by the master
			rvalid <= 1'b0;
		end                
	end
end 
*/
assign RdFifoRx = rvalid & R_ready & selDataRx_r & !RxEmpty ;//arready & ~rvalid & AR_valid  & selDataRx_r & !RxEmpty;

always @(posedge Clk or negedge Rst_n)
  if (!Rst_n) TxDoneReg <= 1'b0;
  else TxDoneReg <= TxDone;

always @(posedge Clk or negedge Rst_n)
  if (!Rst_n) RxDoneReg <= 1'b0;
  else RxDoneReg <= RxDone;


assign data_out = (selConConfig_r ? ConConfig  :
                         selFifoRx_r    ? FifoRx     :
                         selFifoTx_r    ? FifoTx     :
                         selDataRx_r    ? DataRx     :
                         selDataTx_r    ? DataTx     : 32'h0);

always @( data_out, rvalid)
begin
	if (rvalid || arv_arr_flag && ~rvalid && selDataRx_r && !RxEmpty) 
	begin
		// Read address mux
		rdata <= data_out;
		valid_read <= 1;
	end   
	else
	begin
		//rdata <= 32'h00000000;
		valid_read <= 0;
	end       
end  
/*
assign R_data = ( (arv_arr_flag && ~rvalid) && selConConfig_r ? ConConfig  :
                         selFifoRx_r    ? FifoRx     :
                         selFifoTx_r    ? FifoTx     :
                         selDataRx_r    ? DataRx     :
                         selDataTx_r    ? DataTx     : 32'h0);
						 */
						 
/*
always @( posedge Clk or negedge Rst_n)
begin
	if(!Rst_n) R_data <= 32'h00000000;
	else if (arv_arr_flag && ~rvalid)
		begin
			if (selConConfig_r) R_data <= ConConfig;
			else if (selFifoRx_r) R_data <= FifoRx;
			else if (selFifoTx_r) R_data <= FifoTx;
			else if (selDataRx_r && !RxEmpty) R_data <= DataRx;
			else if (selDataTx_r && !TxEmpty) R_data <= DataTx;
			else R_data <= 32'h00000000;
		end  
end
*/


/*						
always @(rdata_reg)//, rvalid)
begin
	if (rvalid ) 
	begin
		// Read address mux
		rdata <= rdata_reg;
	end   
	else
	begin
		rdata <= 32'h00000000;
	end       
end  
*/
/*
always @( posedge Clk or posedge Rst_n)
	begin
	  if ( !Rst_n )
	    begin
	      rdata  <= 0;
	    end 
	  else
	    begin    
	      // When there is a valid read address (S_AXI_ARVALID) with 
	      // acceptance of read address by the slave (axi_arready), 
	      // output the read dada 
	      if (arv_arr_flag)//rvalid) //NO HO TINC CLAR!!!!!!!!
	        begin
	          rdata <= rdata_reg;     // register read data
	        end   
	    end
	end  
*/
endmodule