`timescale 1ns / 1ps

module wptr_full#(parameter addr_size = 4,parameter AF_thresh = 6)(
    input wen,
    input wclk,
    input [addr_size-1:0] wq2_rptr,                               //synced gray read pointer (addr_size+1 bits)
    input  wrst_n,
    output reg wfull,
    output reg [addr_size-1:0] wptr,                              //gray write pointer (addr_size+1 bits)
    output [addr_size-2:0] waddr,
    output reg almost_full,                                       //Fifo almost-full flag
    output reg [addr_size-1:0] count                              //number of words in FIFO present
    );
    
    reg [addr_size-1:0] addr_b;                                   //current address (extra MSB = wrap bit)
    wire [addr_size-1:0] next_addr_b,next_addr_g;                 //updated address (binary and gray)
    reg [addr_size-1:0] wq2_rptr_b;                               //synced read pointer converted to binary
    wire wfull_val;                                               //full  flag from prev counter
    wire [addr_size-1:0] count_val;
    integer i;
    
    assign next_addr_b = addr_b + (wen && !wfull);                                                                  //address is updated only when write is enabled and FIFO not full
    assign next_addr_g = next_addr_b ^ (next_addr_b >> 1);                                                          //binary to gray    
    assign wfull_val = (next_addr_g == {~wq2_rptr[addr_size-1:addr_size-2], wq2_rptr[addr_size-3:0]});              //full condition : flip upper two bit of the gray addresses and compare
    assign waddr = addr_b[addr_size-2:0];                                                                           //drop the wrap bit, memory needs only addr_size bits
    assign count_val = next_addr_b - wq2_rptr_b;                                                                    //occupancy, wraparound handled by modulo subtraction
    
    //gray to binary
    always @ (*) begin
        wq2_rptr_b[addr_size-1] = wq2_rptr[addr_size-1];
        for (i = addr_size-2; i >= 0; i = i - 1)
            wq2_rptr_b[i] = wq2_rptr_b[i+1] ^ wq2_rptr[i];
    end
    
    //FF to store the address
    always @ (posedge wclk or negedge wrst_n) begin
        if(!wrst_n) addr_b <= 0;
        else addr_b <= next_addr_b;
    end
    
    //wptr crosses domain so must be glitch free
    always @ (posedge wclk or negedge wrst_n) begin
        if(!wrst_n) wptr <= 0;
        else wptr <= next_addr_g;
    end
    
    //feeds back to counter, so FF breaks combinational loop
    always @ (posedge wclk or negedge wrst_n) begin
        if(!wrst_n) wfull <= 1'b0;
        else wfull <= wfull_val;
    end
    
    //count and almost_full registered so they line up with wfull
    always @ (posedge wclk or negedge wrst_n) begin
        if(!wrst_n) begin
            count <= 0;
            almost_full <= 1'b0;
        end
        else begin
            count <= count_val;
            almost_full <= (count_val >= AF_thresh);
        end
    end
endmodule