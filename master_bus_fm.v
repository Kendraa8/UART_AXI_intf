`timescale 1ns/1ps
`include "../src/global.v"

module master_bus_fm(

//AXI
  Clk                     ,
  Rst_n                   ,

  AW_ready                ,
  AW_valid                ,
  W_ready                 ,
  W_valid                 ,
  W_last                  ,
  B_ready                 ,
  B_valid                 ,               
  AW_add                  ,
  W_data                  ,
  B_response              ,
  W_strb                  ,
  AR_add		              ,    
  AR_valid   	    	      ,
  AR_ready	    	        ,
  R_data		              ,
  R_valid		              ,
  R_last		              ,
  R_ready		              ,
  R_resp		              ,
  AW_len                  ,
  AW_burst                ,
  AR_len                  ,
  AR_burst                ,

  
	AW_lock				          ,
	AW_cache   			        ,
	AW_prot 			          ,
	AW_qos				          ,
	AW_region 			        ,
	AW_user 			          ,
	AW_id 				          ,     
	AW_size			 	          ,
	W_user 				          ,
	B_id 				            ,
	B_user 				          , 		
	AR_id				            ,
	AR_size 			          ,
	AR_lock				          ,
	AR_cache   			        ,
	AR_prot 			          ,
	AR_qos				          ,
	AR_region 			        ,
	AR_user 			          ,
	R_id				            ,	
	R_user				 

);

//AVALON
input                   Clk                   ; // Clock
input                   Rst_n                 ; // Reset

output reg              AW_valid              ;
output reg              W_valid               ;
output reg              W_last                ;
output reg              B_ready               ;
output reg    [3:0]     W_strb                ;
input                   AW_ready              ;
input                   W_ready               ;
input                   B_valid               ;
output reg    [31:0]    AW_add                ;
output reg    [31:0]    W_data                ;
input         [1:0]     B_response            ;
output reg    [31:0] 	  AR_add		            ;    
output reg   	          AR_valid   	          ;
input    	              AR_ready	            ;
input         [31:0]  	R_data		            ;
input   	              R_valid		            ;
input    	              R_last		            ;
output reg    	        R_ready		            ;
input         [1:0]     R_resp		            ; 
output reg    [7:0]     AW_len                ;
output reg    [1:0]     AW_burst              ;
output reg    [7:0]     AR_len                ;
output reg    [1:0]     AR_burst              ;

reg           [31:0]    readData;
reg           [7:0]     dataArray   [0:255]   ;
 
integer                 i                     ;  

output	AW_lock				                        ;
output	[3:0] AW_cache   			                ;
output	[2:0] AW_prot 			                        ;
output	AW_qos				                        ;
output	AW_region 			                      ;
output	AW_user 			                        ;
output	AW_id 				                        ;   
output	[2:0] AW_size			 	                        ;
output	W_user 				                        ;

input	  B_user 				                        ; 		
input	  B_id 				                          ;  

output	AR_id				                          ;
output	[2:0] AR_size 			                        ;
output	AR_lock				                        ;
output	[3:0] AR_cache   			                      ;
output	[2:0] AR_prot 			                        ;
output	AR_qos				                        ;
output	AR_region 			                      ;
output	AR_user 			                        ;
input	  R_id				                          ;	
input	  R_user				                        ;

task simpleWrite;

  input [31:0] dataToWrite;
  input [2:0]  addressToWrite;
  begin
    fork
    set_waddr(addressToWrite);
    set_wdata(dataToWrite);
    wait_resp;
    join
  end
endtask

task set_waddr;
 input [2:0]  addressToWrite;
 begin
  @(posedge Clk)
	#2 
  AW_add=addressToWrite;
  AW_burst=2'b0;
  AW_len=7'b1;
	AW_valid =1'b1;
 	while(!AW_ready)
	  begin
      		@(posedge Clk)
      		#2; 
    end
  @(posedge Clk)
  AW_valid =1'b0;
 end
endtask

task set_wdata;
 input [31:0] dataToWrite;

 begin
  @(posedge Clk)
	#2 
	W_data = dataToWrite;
	W_strb=4'b1111;
	W_valid =1'b1;
	W_last =1'b1;
 	while(!W_ready)
	  begin
      		@(posedge Clk)
      		#2; 
    end
  @(posedge Clk)
  W_valid =1'b0;
	W_last =1'b0;
 end
endtask

task wait_resp;
 begin
 	B_ready=1'b1;
  @(posedge Clk)
	#2 
 	while(!B_valid)
	  begin
      		@(posedge Clk)
      		#2;
    end
  @(posedge Clk)
 	B_ready=1'b0;
 end
endtask

task simpleRead;

  input [31:0] addressToRead;

  begin
    fork
    set_raddr(addressToRead);
    wait_rresp;
    join
  end
endtask

task set_raddr;
 input [2:0]  addressToRead;
 begin
  @(posedge Clk)
	#2 
  AR_add=addressToRead;
	AR_valid =1'b1;
  AR_burst=2'b00;
  AR_len=7'b1;
 	while(!AR_ready)
	  begin
      		@(posedge Clk)
      		#2; 
    end
  @(posedge Clk)
  AR_valid =1'b0;
 end
endtask


task wait_rresp;
 begin
 	R_ready=1'b1;
  @(posedge Clk)
	#2 
 	while(!R_valid)
	  begin
      		@(posedge Clk)
      		#2;
    	end
  @(posedge Clk)
	readData=R_data;
	R_ready=1'b0;
  end
endtask



task setBaudRateDUT;

input [15:0] bdRate;
reg   [31:0] baudRate;
reg   [31:0] dataToWrite;

  begin
    case(bdRate)
      16'd2400:   baudRate = 32'd1302;
      16'd4800:   baudRate = 32'd651;
      16'd9600:   baudRate = 32'd325; 
      16'd19200:  baudRate = 32'd163; 
     default: baudRate = 16'd0;
    endcase
    simpleRead(`ADDR_UAR_COM_CONFIG);
    //Bits baudRate of UAR_COM_CONFIG are set to 0 in order to rewrite that value 
    //without modifying the other bits of the register.
    dataToWrite = readData & 32'hFFFF0000;
    //The desired baudRate value is written into UAR_COM_CONFIG 
    //without modifying the other bits of the register.
    dataToWrite = dataToWrite | baudRate;
    simpleWrite(dataToWrite, `ADDR_UAR_COM_CONFIG);
    $display("\\  DUT: Baud rate set to %d", bdRate);
  end
  
endtask


task setNbitsDUT;

input[3:0] numberOfBits;

reg   [31:0] dataToWrite;
 
  begin
    simpleRead(`ADDR_UAR_COM_CONFIG);
    //NumberOfBits of UAR_COM_CONFIG is set to 0 in order to rewrite that value 
    //without modifying the other bits of the register.
    dataToWrite = readData & {12'h3FFF, 4'h0, 16'hFFFF};
    //The desired value of numberOfBits is written into UAR_COM_CONFIG 
    //without modifying the other bits of the register.
    dataToWrite = dataToWrite | {12'h0, numberOfBits, 16'h0};
    simpleWrite(dataToWrite, `ADDR_UAR_COM_CONFIG);
    $display("\\  DUT: Number of bits set to %d", numberOfBits);
  end
endtask

task enableRxDUT;
  
  reg   [31:0] dataToWrite;
  
  begin
  simpleRead(`ADDR_UAR_COM_CONFIG);
  dataToWrite = readData | {12'h1, 20'h0};
  simpleWrite(dataToWrite, `ADDR_UAR_COM_CONFIG);
  $display("\\  DUT: Rx channel enabled!");
  end
endtask

task disableRxDUT;
  
  reg   [31:0] dataToWrite;
  
  begin
  simpleRead(`ADDR_UAR_COM_CONFIG);
  dataToWrite = readData & ({11'h7FF, 1'h0, 20'hFFFFF});
  simpleWrite(dataToWrite, `ADDR_UAR_COM_CONFIG);
  $display("\\  DUT: Rx channel disabled!");
  end
endtask

task enableTxDUT;
  
  reg   [31:0] dataToWrite;
  
  begin
  simpleRead(`ADDR_UAR_COM_CONFIG);
  dataToWrite = readData | {12'h2, 20'h0};
  simpleWrite(dataToWrite, `ADDR_UAR_COM_CONFIG);
  $display("\\  DUT: Tx channel enabled!");
  end
endtask

task disableTxDUT;
  
  reg   [31:0] dataToWrite;
  
  begin
  simpleRead(`ADDR_UAR_COM_CONFIG);
  dataToWrite = readData & ({10'h3FF, 1'h0, 21'h1FFFFF});
  simpleWrite(dataToWrite, `ADDR_UAR_COM_CONFIG);
  $display("\\  DUT: Tx channel disabled!");
  end
endtask

task enableRxIrq;
  
  reg   [31:0] dataToWrite;
  
  begin
  simpleRead(`ADDR_UAR_COM_CONFIG);
  dataToWrite = readData | {10'h1, 22'h0};
  simpleWrite(dataToWrite, `ADDR_UAR_COM_CONFIG);
  $display("\\  DUT: Rx IRQ enabled!");
  end
endtask

task disableRxIrq;
  
  reg   [31:0] dataToWrite;
  
  begin
  simpleRead(`ADDR_UAR_COM_CONFIG);
  dataToWrite = readData & ({9'h7FF, 1'h0, 22'hFFFFF});
  simpleWrite(dataToWrite, `ADDR_UAR_COM_CONFIG);
  $display("\\  DUT: Rx IRQ disabled!");
  end
endtask

task enableTxIrq;
  
  reg   [31:0] dataToWrite;
  
  begin
  simpleRead(`ADDR_UAR_COM_CONFIG);
  dataToWrite = readData | {9'h1, 23'h0};
  simpleWrite(dataToWrite, `ADDR_UAR_COM_CONFIG);
  $display("\\  DUT: Tx IRQ enabled!");
  end
endtask

task disableTxIrq;
  
  reg   [31:0] dataToWrite;
  
  begin
  simpleRead(`ADDR_UAR_COM_CONFIG);
  dataToWrite = readData & ({8'h7FF, 1'h0, 23'hFFFFF});
  simpleWrite(dataToWrite, `ADDR_UAR_COM_CONFIG);
  $display("\\  DUT: Tx IRQ disabled!");
  end
endtask

task waitFifoTxEmpty;
  
  reg   empty;
  
  begin
  empty = 0;
  while (!empty)
   begin
     simpleRead(`ADDR_UAR_FIFO_TX);
     empty = readData[1];
   end
   $display("\\  Tx FIFO empty");
  end
endtask

task waitFifoRxNoEmpty;
  
  reg   empty;
  
  begin
  empty = 1;
  while (empty)
   begin
     simpleRead(`ADDR_UAR_FIFO_RX);
     empty = readData[1];
   end
   $display("\\  Rx FIFO no empty");
  end
endtask

//----------------------------------BURST-----------------------------------------------------

task burstWrite;
  input [7:0]  numberOfTransfers;
  input [2:0]  addressToWrite;
  input [1:0]  bursttype;
  begin
    fork
    set_waddr_burst(addressToWrite,bursttype,numberOfTransfers);
    set_wdata_burst(numberOfTransfers);
    wait_resp_burst();
    join
  end
endtask

task set_waddr_burst;
  input [2:0]  addressToWrite;
  input [1:0]  bursttype;
  input [7:0]  numberOfTransfers;

  begin
    @(posedge Clk)
    #2 
    AW_add   = addressToWrite;
    AW_burst = bursttype;
    AW_valid = 1'b1;
    AW_len = numberOfTransfers;
    while(!AW_ready)
      begin
        @(posedge Clk)
        #2; 
      end
    @(posedge Clk)
    AW_valid =1'b0;
 end  
endtask

task set_wdata_burst;
  input [7:0]  numberOfTransfers;
  reg          additionalClockCycle;
  
  begin
    additionalClockCycle = 1'b0;
    @(posedge Clk)
    #2 
    i=0;
      W_strb=4'b1111;
      W_last = 1'b0;
      W_valid = 1'b1;
   for (i = 0; i < numberOfTransfers; i = i +1)
    begin
     W_data = dataArray[i];
     @(posedge Clk)
     #2 
     while(!W_ready)
      begin
        @(posedge Clk)
        #2 additionalClockCycle = 1'b1;
      end
     if (additionalClockCycle) begin 
     //Additional clock cycle in case of slave_writerequest.
                                @(posedge Clk)
                                #2;
                                additionalClockCycle = 1'b0;
                               end 
       
    end

    if (i==numberOfTransfers) W_last =1'b1;
    @(posedge Clk)
    #2
    W_valid =1'b0;
    W_last =1'b0;
  end
endtask


task wait_resp_burst;
 begin
 	B_ready=1'b1;
  @(posedge Clk)
	#2 
 	while(!B_valid)
	  begin
      		@(posedge Clk)
      		#2;
    end
  @(posedge Clk)
 	B_ready=1'b0;
 end
endtask

task burstRead;
  input [7:0]  numberOfTransfers;
  input [2:0]  addressToRead;
  input [1:0]  bursttype;
  begin
    fork
    set_raddr_burst(addressToRead,bursttype,numberOfTransfers);
    wait_rresp_burst(numberOfTransfers);
    join
  end
endtask

task set_raddr_burst;
  input [2:0]  addressToRead;
  input [1:0]  bursttype;
  input [7:0]  numberOfTransfers;

 begin
 
  @(posedge Clk)
	#2 
  AR_add=addressToRead;
  AR_burst = bursttype;
	AR_valid =1'b1;
  AR_len=numberOfTransfers;
 	while(!AR_ready)
	  begin
      		@(posedge Clk)
      		#2; 
    end

  @(posedge Clk)
  AR_valid =1'b0;
 end
endtask

task wait_rresp_burst;
  input [7:0]  numberOfTransfers;
  reg          additionalClockCycle;
  begin
    additionalClockCycle = 1'b0;
    @(posedge Clk)
    #2 

    for (i = 0; i < numberOfTransfers; i = i +1)
    begin
      R_ready=1'b1;
     @(posedge Clk)
     #2 
      while(!R_valid)
      begin
            @(posedge Clk)
            #2 additionalClockCycle = 1'b1;
      end
      if (additionalClockCycle) begin 
     //Additional clock cycle in case of slave_writerequest.
                                @(posedge Clk)
                                #2;
                                additionalClockCycle = 1'b0;
                               end 
      dataArray[i] <= R_data;
      @(posedge Clk)
      #2; 

    end 
  R_ready=1'b0;
  end
endtask

/*
task waitIrqAsserted;

 begin
   wait(slave_irq);
   $display("\\  DUT: IRQ asserted!");
 end
 
endtask

task deassertIrq;

 begin
   simpleWrite(32'h0,`ADDR_UAR_IRQ);
   $display("\\  DUT: IRQ desasserted!");
 end
 
endtask
*/

initial
  begin

    AW_valid    <=1'b0            ;
    W_valid     <=1'b0            ;
    W_last      <=1'b0            ;
    B_ready     <=1'b0            ;
    W_strb      <=8'b0            ;


    AW_add     <=32'b0            ;
    W_data     <=32'b0            ;


    AR_add	    <=32'b0	          ;    
    AR_valid   	<=1'b0            ;

    R_ready	    <=1'b0	          ;

    for (i = 0; i < 256; i = i + 1)
      dataArray [i] = 8'h0;

  end
  
endmodule
