`timescale 1ns / 1ps

module pc_counter(
    input  logic clk,
    input  logic reset,
    input logic pc_src,
    input logic pc_write,
    input logic [31:0]branch_pc,
    output logic [31:0] pc
);
    logic [31:0] next_pc;
    always_comb begin
        next_pc = pc + 32'd4;
        if(pc_src)
            next_pc = branch_pc;
    end
    always_ff @(posedge clk) begin
        if (reset)
            pc <= 32'b0;
        else if (pc_write) //update the pc
            pc <= next_pc;
        // otherwise stall
    end
endmodule

