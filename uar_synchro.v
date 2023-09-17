`timescale 1ns/1ps

module uar_synchro (
    Clk                  ,
    Rst_n                ,
    AsyncIn              ,
    SyncOut           
    );

input          Clk                 ; // Clock
input          Rst_n               ; // Reset

input          AsyncIn             ; // Asynchronous input
output         SyncOut             ; // Synchronous output

reg            reg1                ; // Synchro ff chain
reg            reg2                ; // Synchro ff chain
wire           SyncOut             ;

assign SyncOut = reg2; // End of synchro chain

// synchro register    
always @(posedge Clk or negedge Rst_n)
    if (!Rst_n) begin
        reg1 <= 1'b1;
        reg2 <= 1'b1;
    end else begin
        reg1 <= AsyncIn;
        reg2 <= reg1;
    end        


endmodule // uar_synchro
