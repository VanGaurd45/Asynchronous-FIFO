`timescale 1ns / 1ps

module synchronizer#(parameter addr_size = 4)(
    input clk,
    input [addr_size-1:0] ptr,
    input rst,
    output reg [addr_size-1:0] m2m_ptr    
    );
    
    // imtermediate output of 1st Flip-Flop
    reg [addr_size-1:0] temp;
    
    // 2 D_FF synchronizer with async reset
    always @ (posedge clk or negedge rst) begin
        if(!rst) begin
            m2m_ptr <= 0;
            temp <= 0;
        end
        else begin
            temp <= ptr;
            m2m_ptr <= temp;
        end
    end        
endmodule
