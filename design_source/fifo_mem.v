`timescale 1ns / 1ps

module fifo_mem #(parameter data_size = 8,           //8bit data
    parameter addr_size = 4)                         //3bit address (8 mem locations) + 1 bit wrap-bit
    (output [data_size-1:0] rdata,                   //8bit read data
    input [data_size-1:0] wdata,                     //8bit write data
    input wclk,                                      //write clock  
    input [addr_size-2:0] waddr,                     //4bit write address ( 2^(4-1) memory location)
    input [addr_size-2:0] raddr,                     //4bit read address ( 2^(4-1) memory location)
    input wen,                                       //write enable
    input wfull                                      //memory full flag
    );
    
    //memory is a 2D array of data_size x memory_size
    localparam depth = 1<<(addr_size-1);
    reg [data_size-1:0] memory [0:depth-1];
    
    //reading data.
    assign rdata = memory[raddr[addr_size-2:0]];
    
    //writing data into memory
    always @(posedge wclk)
        if (wen && !wfull) memory[waddr[addr_size-2:0]] <= wdata;
    
endmodule
