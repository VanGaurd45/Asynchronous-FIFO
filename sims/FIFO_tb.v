`timescale 1ns / 1ps

module FIFO_tb();
    parameter data_size = 8;
    parameter addr_size = 4;
    parameter AF_thresh = 6;
    
    reg  [data_size-1:0] wdata; 
    reg wen,ren;                
    reg wclk,rclk;             
    reg wrst_n,rrst_n;         
    wire [data_size-1:0] rdata; 
    wire wfull;                 
    wire rempty; 
    wire [addr_size-1:0] count;
    wire almost_full;
    
    FIFO_top #(data_size, addr_size,AF_thresh) dut(
    .wdata(wdata),
    .wen(wen),.ren(ren),               
    .wclk(wclk),.rclk(rclk),             
    .wrst_n(wrst_n),.rrst_n(rrst_n),         
    .rdata(rdata),
    .wfull(wfull),                
    .rempty(rempty),
    .count(count),
    .almost_full(almost_full)               
    );
    
    integer i;
    integer seed=1;
    
    always #5 wclk =~wclk;
    always #10 rclk = ~rclk;  
    
    initial begin
        wrst_n=0;
        rrst_n=0;
        wclk=0;
        rclk=0;
        wen=0;
        ren=0;
        wdata=0;
        
        #20 rrst_n=1;wrst_n=1;
        
        //test1:writing and reading
        ren = 1;
        for (i=0;i<10;i=i+1) begin
            wdata = $random(seed);
            wen = 1;
            #10;
            wen = 0;
            #10;
        end
        
        //test2: Memory full condition
//        for (i=0;i<11;i=i+1) begin
//            wdata =$random(seed);
//            wen = 1;
//            #10;
//            wen = 0;
//            #10;
//        end

        //test3:writing and reading
//        ren = 0;
//        for (i=0;i<10;i=i+1) begin
//            wdata = $random(seed);
//            wen = 1;
//            #10;
//            wen = 0;
//            #10;
//        end
//        ren=1;
        
        //test4:writing and reading
//        ren = 1;
//        for (i=0;i<10;i=i+1) begin
//            #10;
//        end

        
        #70 $finish;   
    end       
       

endmodule
