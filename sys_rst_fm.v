`timescale 1ns/1ps

module sys_rst_fm (                  
    Rst_n                   
    );

output          Rst_n            ;   // Generated reset
reg             Rst_n            ; 

initial
 begin
   Rst_n = 1;
 end
 
// -----------------------------------------------------------------------------
// Task: sys.rstOn
// Asserts reset (Rst_n=0 & Rst=1)
// -----------------------------------------------------------------------------
task rstOn; begin
    Rst_n=0;
end
endtask // rstOn

// -----------------------------------------------------------------------------
// Task: sys.rstOff
// Deasserts reset (Rst_n=0 & Rst=1)
// -----------------------------------------------------------------------------
task rstOff; begin
    Rst_n=1;
end
endtask // rstOff

// 

endmodule