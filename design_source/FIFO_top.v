`timescale 1ns / 1ps

module FIFO_top#(parameter data_size = 8,           //8bit data
    parameter addr_size = 4,                        //3bit address (8 mem locations) + 1 bit wrap-bit
    parameter AF_thresh = 6)(                       //almost_full threshold
    input  [data_size-1:0] wdata,                   //input data                                
    input wen,ren,                                  //write and read enables
    input wclk,rclk,                                //write and read clocks
    input wrst_n,rrst_n,                            //write and read resets
    output [data_size-1:0] rdata,                   //output data
    output wfull,                                   //FIFO full flag
    output rempty,                                  //FIFO empty flag
    output [addr_size-1:0] count,
    output almost_full
    );
    
    wire [addr_size-2:0] waddr,raddr;
    wire [addr_size-1:0] rptr,wptr,rq2_wptr,wq2_rptr;
    
    //fifo memory module
    fifo_mem  #(
    .data_size(data_size),
    .addr_size(addr_size))
    RAM (
    .rdata(rdata),
    .wdata(wdata),
    .wclk(wclk),
    .waddr(waddr),
    .raddr(raddr),
    .wen(wen),
    .wfull(wfull)  
    );
    
    //read to write clock domain synchronizer
    synchronizer #(
    .addr_size(addr_size)) 
    sync_r2w (
    .clk(wclk),
    .ptr(rptr),
    .rst(wrst_n),
    .m2m_ptr(wq2_rptr)
    );
    
    //write to read clock domain synchronizer
    synchronizer#(
    .addr_size(addr_size)) 
    sync_w2r (
    .clk(rclk),
    .ptr(wptr),
    .rst(rrst_n),
    .m2m_ptr(rq2_wptr)
    );
    
    //read pointer and empty flag handler
    rptr_empty #(
    .addr_size(addr_size)) 
    rptrempty (
    .ren(ren),
    .rclk(rclk),
    .rq2_wptr(rq2_wptr),
    .rrst_n(rrst_n),
    .rempty(rempty),
    .rptr(rptr),
    .raddr(raddr)
    );

    //wite pointer and full flag handler    
    wptr_full #(
    .addr_size(addr_size),.AF_thresh(AF_thresh)) 
    fptrfull (
    .wen(wen),
    .wclk(wclk),
    .wq2_rptr(wq2_rptr),
    .wrst_n(wrst_n),
    .wfull(wfull),
    .wptr(wptr),
    .waddr(waddr),
    .count(count),
    .almost_full(almost_full)
    );
endmodule
