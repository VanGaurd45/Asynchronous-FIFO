`timescale 1ns / 1ps

module rptr_empty#(parameter addr_size = 4)(
    input ren,
    input rclk,
    input [addr_size-1:0] rq2_wptr,
    input  rrst_n,
    output reg rempty,
    output reg  [addr_size-1:0] rptr,
    output [addr_size-2:0] raddr
    );
    
    reg [addr_size-1:0] addr_b;                             //current address
    wire [addr_size-1:0] next_addr_b,next_addr_g;           //updated address (binary and gray)
    wire rempty_val;                                        //empty  flag from prev counter
            
    assign next_addr_b = addr_b + (ren && !rempty);         //address is updated only when read is enabled and FIFO not empty
    assign next_addr_g = next_addr_b ^ (next_addr_b>>1);    //binary to gray    
    assign rempty_val = (rq2_wptr == next_addr_g);          //empty condition : two address has to be same
    assign raddr = addr_b[addr_size-2:0];                   //raddr is getting the next_addr_b through the FF but combinationally used to prevent delay
    
    //FF to store the address
    always @ (posedge rclk or negedge rrst_n) begin
        if(!rrst_n) addr_b <= 0;
        else addr_b <= next_addr_b;
    end
    
    //rptr crosses domain so must be glitch free
    always @ (posedge rclk or negedge rrst_n) begin
        if(!rrst_n) rptr <= 0;
        else rptr <= next_addr_g;
    end
    
    //feeds back to counter, so FF breaks combinational loop
    always @ (posedge rclk or negedge rrst_n) begin
        if(!rrst_n) rempty <= 1'b1;
        else rempty <= rempty_val;
    end
endmodule
