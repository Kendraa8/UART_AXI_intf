`timescale 1ns/1ps

module sys_clk50MHz_fm (                  
    Clk                   
    );

`define DATA_SKEW #1 

output          Clk            ;   // Generated clock
reg             Clk            ;   

// Initialization of all signals and variables
initial begin
    Clk=0;
end

initial begin
    forever begin
        Clk=1;
        #10;
        Clk=0;
        #10;
    end
end


// -----------------------------------------------------------------------------
// Task: sys.waitCycles(<cycles>)
// <cycles>: number of clock positive edges to wait
// -----------------------------------------------------------------------------

task waitCycles;
input [31:0] cycles;
begin
    repeat (cycles)
        @(posedge Clk);
    `DATA_SKEW;
end
endtask // waitCycles

endmodule