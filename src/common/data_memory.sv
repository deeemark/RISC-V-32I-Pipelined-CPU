`timescale 1ns / 1ps
module data_memory #(
    parameter int DEPTH_WORDS = 1024
)(
    input  logic        clk,
    input  logic        memread,
    input  logic        memwrite,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata
);
    logic [31:0] mem [0:DEPTH_WORDS-1];
    logic [$clog2(DEPTH_WORDS)-1:0] idx;

    assign idx   = addr[($clog2(DEPTH_WORDS)+1):2];
    assign rdata = (memread) ? mem[idx] : 32'b0;   // async read

    always_ff @(posedge clk) begin
        if (memwrite)
            mem[idx] <= wdata;                     // sync write
    end
endmodule
