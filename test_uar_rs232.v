`timescale 1ns/1ps
`include "../src/global.v"

// Redefinitions for functional model instance names
`define SYSRST            I_tb_uar_rs232.I_sys_rst_fm
`define CLK50M            I_tb_uar_rs232.I_sys_clk50MHz_fm
`define UART              I_tb_uar_rs232.I_uart_fm
`define MASTER            I_tb_uar_rs232.I_master_bus_fm
`define DUT               I_tb_uar_rs232.I_uar_rs232_avalon.I_uar_rs232.I_BAUDGEN

module test_uar_rs232();

integer error;

tb_uar_rs232 I_tb_uar_rs232 ();

initial
 begin
   error = 0;
   
   `SYSRST.rstOn;
   `CLK50M.waitCycles(3);
   `SYSRST.rstOff;
   
    check_baudrate;
   
    //test1;
    //test2;
    //test3;
    //test4;
    //test5;
    

    test6;

    //test7;
    //test8;
  #1000;
  check_error;
  $finish;
 end

task baudGeneratorMonitor;

time t1, t2, period;
real frequency;
  begin
   @(posedge `DUT.tick)
   t1 = $realtime;
   @(posedge `DUT.tick)
   t2 = $realtime;
   period = t2 - t1;
   $display("Period = %t ps", period);
   frequency = 1/(16*period*1e-9);
   $display("Measured baudrate = %f bits/s", frequency);
  end
  
endtask


task checkReceivedDataDUT;

input[7:0] dataToReceive;

 begin
   `MASTER.simpleRead(`ADDR_UAR_DATA_RX);
   if (dataToReceive != `MASTER.readData) begin
                                            $display("Error, transmitted data %h is not the expected value %h", `MASTER.readData, dataToReceive);
                                            error = error +1;
                                           end
   else $display("Correct, transmitted data %h is the expected value %h", `MASTER.readData, dataToReceive);
  end
  
endtask

task checkReceivedDataFM;

input[7:0] dataToReceive;

 begin
   if (dataToReceive != `UART.RxData) begin
                                            $display("Error, transmitted data %h is not the expected value %h", `UART.RxData, dataToReceive);
                                            error = error +1;
                                           end
   else $display("Correct, transmitted data %h is the expected value %h", `UART.RxData, dataToReceive);
 end
endtask
  
task transmitUartFm_and_check;

  input[7:0] dataToTransmit;
  
  begin
   `UART.transmit(dataToTransmit);
   checkReceivedDataDUT(dataToTransmit);
  end
 
endtask

task transmitUart_and_check;

  input[7:0] dataToTransmit;
  
  begin
   `MASTER.simpleWrite(dataToTransmit, `ADDR_UAR_DATA_TX);
   `UART.waitIncommingData;
   checkReceivedDataFM(dataToTransmit);
  end
endtask

task check_error;

 begin
   if (error != 0) $display("Test unsuccessful, %d errors", error);
   else $display("Test successful, %d errors", error);
 end
endtask

task check_baudrate;

  begin
    $display("//------------------------------------STARTING TEST CHECK_BAUDRATE------------------------------------//");
    `MASTER.setBaudRateDUT(19200);   
    baudGeneratorMonitor;
    `MASTER.setBaudRateDUT(9600);   
    baudGeneratorMonitor;
    `MASTER.setBaudRateDUT(4800);   
    baudGeneratorMonitor;
    `MASTER.setBaudRateDUT(2400);   
    baudGeneratorMonitor;
    $display("//------------------------------------TEST CHECK_BAUDRATE FINISHED------------------------------------//");
  end  
endtask

task test1;
 
 begin
    $display("//------------------------------------STARTING TEST1------------------------------------//");
    `UART.setBaudRate(19200);
    `UART.setNbits(8);
    `MASTER.setBaudRateDUT(19200);
    `MASTER.setNbitsDUT(8);
    `MASTER.enableRxDUT;
    transmitUartFm_and_check(8'hAA);
    transmitUartFm_and_check(8'h55);
    transmitUartFm_and_check(8'h77);
    transmitUartFm_and_check(8'h67);
    transmitUartFm_and_check(8'hFA);
    transmitUartFm_and_check(8'h0A);
    transmitUartFm_and_check(8'hCD);
    transmitUartFm_and_check(8'h00);
    `MASTER.disableRxDUT;
    
    `UART.setBaudRate(9600);
    `UART.setNbits(8);
    `MASTER.setBaudRateDUT(9600);
    `MASTER.setNbitsDUT(8);
    `MASTER.enableRxDUT;
    transmitUartFm_and_check(8'hAA);
    transmitUartFm_and_check(8'h55);
    transmitUartFm_and_check(8'h77);
    transmitUartFm_and_check(8'h67);
    transmitUartFm_and_check(8'hFA);
    transmitUartFm_and_check(8'h0A);
    transmitUartFm_and_check(8'hCD);
    transmitUartFm_and_check(8'h00);
    `MASTER.disableRxDUT;
    
    `UART.setBaudRate(4800);
    `UART.setNbits(8);
    `MASTER.setBaudRateDUT(4800);
    `MASTER.setNbitsDUT(8);
    `MASTER.enableRxDUT;
    transmitUartFm_and_check(8'hAA);
    transmitUartFm_and_check(8'h55);
    transmitUartFm_and_check(8'h77);
    transmitUartFm_and_check(8'h67);
    transmitUartFm_and_check(8'hFA);
    transmitUartFm_and_check(8'h0A);
    transmitUartFm_and_check(8'hCD);
    transmitUartFm_and_check(8'h00);
    `MASTER.disableRxDUT;
    
    `UART.setBaudRate(2400);
    `UART.setNbits(8);
    `MASTER.setBaudRateDUT(2400);
    `MASTER.setNbitsDUT(8);
    `MASTER.enableRxDUT;
    transmitUartFm_and_check(8'hAA);
    transmitUartFm_and_check(8'h55);
    transmitUartFm_and_check(8'h77);
    transmitUartFm_and_check(8'h67);
    transmitUartFm_and_check(8'hFA);
    transmitUartFm_and_check(8'h0A);
    transmitUartFm_and_check(8'hCD);
    transmitUartFm_and_check(8'h00);
    `MASTER.disableRxDUT;
   $display("//------------------------------------TEST1 FINISHED------------------------------------//"); 
  end 
endtask

task test2;
 
 begin
    $display("//------------------------------------STARTING TEST2------------------------------------//");
    `UART.setBaudRate(19200);
    `UART.setNbits(8);
    `MASTER.setBaudRateDUT(19200);
    `MASTER.setNbitsDUT(8);
    `MASTER.enableTxDUT;
    transmitUart_and_check(8'hAA);
    transmitUart_and_check(8'h55);
    transmitUart_and_check(8'h77);
    transmitUart_and_check(8'h67);
    transmitUart_and_check(8'hFA);
    transmitUart_and_check(8'h0A);
    transmitUart_and_check(8'hCD);
    transmitUart_and_check(8'h00);
    `MASTER.disableTxDUT;
    
    `UART.setBaudRate(9600);
    `UART.setNbits(8);
    `MASTER.setBaudRateDUT(9600);
    `MASTER.setNbitsDUT(8);
    `MASTER.enableTxDUT;
    transmitUart_and_check(8'hAA);
    transmitUart_and_check(8'h55);
    transmitUart_and_check(8'h77);
    transmitUart_and_check(8'h67);
    transmitUart_and_check(8'hFA);
    transmitUart_and_check(8'h0A);
    transmitUart_and_check(8'hCD);
    transmitUart_and_check(8'h00);
    `MASTER.disableTxDUT;
    
    `UART.setBaudRate(4800);
    `UART.setNbits(8);
    `MASTER.setBaudRateDUT(4800);
    `MASTER.setNbitsDUT(8);
    `MASTER.enableTxDUT;
    transmitUart_and_check(8'hAA);
    transmitUart_and_check(8'h55);
    transmitUart_and_check(8'h77);
    transmitUart_and_check(8'h67);
    transmitUart_and_check(8'hFA);
    transmitUart_and_check(8'h0A);
    transmitUart_and_check(8'hCD);
    transmitUart_and_check(8'h00);
    `MASTER.disableTxDUT;
    
    `UART.setBaudRate(2400);
    `UART.setNbits(8);
    `MASTER.setBaudRateDUT(2400);
    `MASTER.setNbitsDUT(8);
    `MASTER.enableTxDUT;
    transmitUart_and_check(8'hAA);
    transmitUart_and_check(8'h55);
    transmitUart_and_check(8'h77);
    transmitUart_and_check(8'h67);
    transmitUart_and_check(8'hFA);
    transmitUart_and_check(8'h0A);
    transmitUart_and_check(8'hCD);
    transmitUart_and_check(8'h00);
    `MASTER.disableTxDUT;
    $display("//------------------------------------TEST2 FINISHED------------------------------------//"); 
  end 
endtask

task test3;

 begin
   $display("//------------------------------------STARTING TEST3------------------------------------//");
   `UART.setBaudRate(19200);
   `UART.setNbits(8);
   `MASTER.setBaudRateDUT(19200);
   `MASTER.setNbitsDUT(8);
   `MASTER.enableRxDUT;
   
   fork
    test31;
    test32;
   join
   `MASTER.disableRxDUT;
   $display("//------------------------------------TEST3 FINISHED------------------------------------//");
 end
endtask

task test31;
 
 begin
    $display("//------------------------------------STARTING TRANSACTIONS------------------------------------//", $time);
    `UART.transmit(8'h19);
    `UART.transmit(8'h18);
    `UART.transmit(8'h17);
    `UART.transmit(8'h16);
    `UART.transmit(8'h15);
    `UART.transmit(8'h14);
    `UART.transmit(8'h13);
    `UART.transmit(8'h12);
    `UART.transmit(8'h11);
    `UART.transmit(8'h10);
    $display("//------------------------------------TRANSACTIONS FINISHED------------------------------------//"); 
  end 
endtask

task test32;
 
 begin
   $display("//------------------------------------WAITING DATA------------------------------------//", $time);
   `MASTER.waitFifoRxNoEmpty;
   checkReceivedDataDUT(8'h19);
   `MASTER.waitFifoRxNoEmpty;
   checkReceivedDataDUT(8'h18);
   `MASTER.waitFifoRxNoEmpty;
   checkReceivedDataDUT(8'h17);
   `MASTER.waitFifoRxNoEmpty;
   checkReceivedDataDUT(8'h16);
   `MASTER.waitFifoRxNoEmpty;
   checkReceivedDataDUT(8'h15);
   `MASTER.waitFifoRxNoEmpty;
   checkReceivedDataDUT(8'h14);
   `MASTER.waitFifoRxNoEmpty;
   checkReceivedDataDUT(8'h13);
   `MASTER.waitFifoRxNoEmpty;
   checkReceivedDataDUT(8'h12);
   `MASTER.waitFifoRxNoEmpty;
   checkReceivedDataDUT(8'h11);
   `MASTER.waitFifoRxNoEmpty;
   checkReceivedDataDUT(8'h10);
   $display("//------------------------------------DATA RECEIVED------------------------------------//"); 
  end 
endtask

task test4;
 
 begin  
    $display("//------------------------------------STARTING TEST4------------------------------------//");
    `UART.setBaudRate(19200);
    `UART.setNbits(8);
    `MASTER.setBaudRateDUT(19200);
    `MASTER.setNbitsDUT(8);
    `MASTER.enableTxDUT;
    fork
     test41;
     test42;
    join 
    `MASTER.disableTxDUT;
    $display("//------------------------------------TEST4 FINISHED------------------------------------//");
  end 
endtask

task test41;
 
 begin
    $display("//------------------------------------STARTING TRANSACTIONS------------------------------------//", $time);
    `MASTER.simpleWrite(8'h1, `ADDR_UAR_DATA_TX);
    `MASTER.simpleWrite(8'h2, `ADDR_UAR_DATA_TX);
    `MASTER.simpleWrite(8'h3, `ADDR_UAR_DATA_TX);
    `MASTER.simpleWrite(8'h4, `ADDR_UAR_DATA_TX);
    `MASTER.simpleWrite(8'h5, `ADDR_UAR_DATA_TX);
    `MASTER.simpleWrite(8'h6, `ADDR_UAR_DATA_TX);
    `MASTER.simpleWrite(8'h7, `ADDR_UAR_DATA_TX);
    `MASTER.simpleWrite(8'h8, `ADDR_UAR_DATA_TX);
    `MASTER.simpleWrite(8'h9, `ADDR_UAR_DATA_TX);
    `MASTER.simpleWrite(8'h10, `ADDR_UAR_DATA_TX); 
    $display("//------------------------------------TRANSACTIONS FINISHED------------------------------------//"); 
  end 
endtask

task test42;
 
 begin
    $display("//------------------------------------WAITING DATA------------------------------------//", $time);
    `UART.waitIncommingData;
    checkReceivedDataFM(8'h1);
    `UART.waitIncommingData;
    checkReceivedDataFM(8'h2);
    `UART.waitIncommingData;
    checkReceivedDataFM(8'h3);
    `UART.waitIncommingData;
    checkReceivedDataFM(8'h4);
    `UART.waitIncommingData;
    checkReceivedDataFM(8'h5);
    `UART.waitIncommingData;
    checkReceivedDataFM(8'h6);
    `UART.waitIncommingData;
    checkReceivedDataFM(8'h7);
    `UART.waitIncommingData;
    checkReceivedDataFM(8'h8);
    `UART.waitIncommingData;
    checkReceivedDataFM(8'h9);
    `UART.waitIncommingData;
    checkReceivedDataFM(8'h10);
    check_error;
    $display("//------------------------------------DATA RECEIVED------------------------------------//"); 
  end 
endtask



task test5;

 begin
    $display("//------------------------------------STARTING TEST5------------------------------------//");
    `UART.setBaudRate(19200);
    `UART.setNbits(8);
    `MASTER.setBaudRateDUT(19200);
    `MASTER.setNbitsDUT(8);
    `MASTER.enableTxDUT;
    
    fork
     test51;
     test52;
    join
    `MASTER.disableTxDUT;
    check_error;
    $display("//------------------------------------TEST5 FINISHED------------------------------------//"); 
 end   
endtask

task test51;
 begin
    `MASTER.dataArray[0] = 8'd10;
    `MASTER.dataArray[1] = 8'd11;
    `MASTER.dataArray[2] = 8'd12;
    `MASTER.dataArray[3] = 8'd13;
    `MASTER.dataArray[4] = 8'd14;
    `MASTER.dataArray[5] = 8'd15;
    `MASTER.dataArray[6] = 8'd16;
    `MASTER.dataArray[7] = 8'd17;
    `MASTER.dataArray[8] = 8'd18;
    `MASTER.dataArray[9] = 8'd19; 
    `MASTER.dataArray[10] = 8'd20; 
    `MASTER.dataArray[11] = 8'd21; 
    `MASTER.burstWrite(8'b00001100, `ADDR_UAR_DATA_TX, 2'b00);
  end
endtask

task test52;
  begin
    `UART.waitIncommingData;
    checkReceivedDataFM(8'd10);
    `UART.waitIncommingData;
    checkReceivedDataFM(8'd11);
    `UART.waitIncommingData;
    checkReceivedDataFM(8'd12);
    `UART.waitIncommingData;
    checkReceivedDataFM(8'd13);
    `UART.waitIncommingData;
    checkReceivedDataFM(8'd14);
    `UART.waitIncommingData;
    checkReceivedDataFM(8'd15);
    `UART.waitIncommingData;
    checkReceivedDataFM(8'd16);
    `UART.waitIncommingData;
    checkReceivedDataFM(8'd17);
    `UART.waitIncommingData;
    checkReceivedDataFM(8'd18);
    `UART.waitIncommingData;
    checkReceivedDataFM(8'd19);
    `UART.waitIncommingData;
    checkReceivedDataFM(8'd20);
    `UART.waitIncommingData;
    checkReceivedDataFM(8'd21);
  end
endtask

task test6;

integer i;

 begin
    $display("//------------------------------------STARTING TEST6------------------------------------//");
    `UART.setBaudRate(19200);
    `UART.setNbits(8);
    `MASTER.setBaudRateDUT(19200);
    `MASTER.setNbitsDUT(8);
    `MASTER.enableRxDUT;
    fork
     test61;
     `MASTER.burstRead(10, `ADDR_UAR_DATA_RX, 2'b00);
    join
     for (i=0; i < 10; i = i + 1)
      begin
        if (i+1 != `MASTER.dataArray[i]) begin
                                            $display("Error, transmitted data %h is not the expected value %h", `MASTER.dataArray[i], i+1);
                                            error = error +1;
                                           end
        else $display("Correct, transmitted data %h is the expected value %h", `MASTER.dataArray[i], i+1);
      end
     `MASTER.disableRxDUT; 
    
    check_error;
    $display("//------------------------------------TEST6 FINISHED------------------------------------//"); 
 end   
endtask

task test61;
 
 begin
    $display("//------------------------------------STARTING TRANSACTIONS------------------------------------//", $time);
    `UART.transmit(8'h1);
    `UART.transmit(8'h2);
    `UART.transmit(8'h3);
    `UART.transmit(8'h4);
    `UART.transmit(8'h5);
    `UART.transmit(8'h6);
    `UART.transmit(8'h7);
    `UART.transmit(8'h8);
    `UART.transmit(8'h9);
    `UART.transmit(8'hA); 
    $display("//------------------------------------TRANSACTIONS FINISHED------------------------------------//"); 
  end 
endtask

task test62;
 
 begin
    $display("//------------------------------------STARTING TRANSACTIONS------------------------------------//", $time);
    `UART.transmit(8'h1);
    `UART.transmit(8'h2);
    `UART.transmit(8'h3);
    `UART.transmit(8'h4);
    `UART.transmit(8'h5);
    `UART.transmit(8'h6);
    `UART.transmit(8'h7);
    `UART.transmit(8'h8);
    `UART.transmit(8'h9);
    `UART.transmit(8'hA); 
    $display("//------------------------------------TRANSACTIONS FINISHED------------------------------------//"); 
  end 
endtask
/*
task test7;
 
 begin
    $display("//------------------------------------STARTING TEST7------------------------------------//");
    `UART.setBaudRate(19200);
    `UART.setNbits(8);
    `MASTER.setBaudRateDUT(19200);
    `MASTER.setNbitsDUT(8);
    `MASTER.enableRxDUT;
    `MASTER.enableRxIrq;
    `UART.transmit(8'hA);
    `MASTER.waitIrqAsserted;
    checkReceivedDataDUT(8'hA);
    `MASTER.deassertIrq;
    `MASTER.disableRxDUT;
    `MASTER.disableRxIrq;
     $display("//------------------------------------TEST7 FINISHED------------------------------------//");
 end
endtask

task test8;
 
 begin
    $display("//------------------------------------STARTING TEST2------------------------------------//");
    `UART.setBaudRate(19200);
    `UART.setNbits(8);
    `MASTER.setBaudRateDUT(19200);
    `MASTER.setNbitsDUT(8);
    `MASTER.enableTxDUT;
    `MASTER.enableTxIrq;
    fork
     test81;
     test82;
    join 
     $display("//------------------------------------TEST7 FINISHED------------------------------------//");
 end
endtask

task test81;
  
 begin
  `MASTER.simpleWrite(8'h1, `ADDR_UAR_DATA_TX);
  `MASTER.waitIrqAsserted;
  `MASTER.disableTxDUT;
  `MASTER.disableTxIrq;
 end
 
endtask

task test82;
 
 begin
  `UART.waitIncommingData;
  checkReceivedDataFM(8'h1); 
 end
 
endtask
*/   
endmodule