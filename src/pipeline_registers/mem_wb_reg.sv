`timescale 1ns / 1ps
import cpu_types::*;

module mem_wb_reg(
    input  logic  clk,
    input  logic reset,
    // From MEM stage
    input ctrl_t mem_ctrl,
    input logic [31:0] mem_alu_out,
    input logic [31:0] mem_rdata,
    input logic [4:0] mem_rd,
    input logic [31:0] mem_pc_plus4,
    // To WB stage
    output ctrl_t wb_ctrl,
    output logic [31:0] wb_alu_out,
    output logic [31:0] wb_rdata,
    output logic [4:0] wb_rd,
    output logic [31:0] wb_pc_plus4
);
    always_ff @(posedge clk) begin
        if (reset) begin
            wb_ctrl <= '0;
            wb_alu_out <= 32'b0;
            wb_rdata <= 32'b0;
            wb_rd <= 5'b0;
            wb_pc_plus4 <= 32'b0;
        end 
        else begin
            wb_ctrl <= mem_ctrl;
            wb_alu_out <= mem_alu_out;
            wb_rdata <= mem_rdata;
            wb_rd <= mem_rd;
            wb_pc_plus4 <= mem_pc_plus4;
        end
    end
endmodule
