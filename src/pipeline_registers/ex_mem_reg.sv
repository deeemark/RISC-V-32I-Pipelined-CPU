`timescale 1ns / 1ps
import cpu_types::*;

module ex_mem_reg(
    input logic clk,
    input logic reset,
    // Inputs from EX stage
    input ctrl_t ex_ctrl,
    input logic [31:0] ex_alu_out,
    input logic [31:0] ex_store_data,
    input logic [4:0] ex_rd,
    input logic [31:0] ex_pc_plus4,
    // Outputs to MEM stage
    output ctrl_t mem_ctrl,
    output logic [31:0] mem_alu_out,
    output logic [31:0] mem_store_data,
    output logic [4:0] mem_rd,
    output logic [31:0] mem_pc_plus4
);
    always_ff @(posedge clk) begin
        if (reset) begin
            mem_ctrl <= '0;
            mem_alu_out <= 32'b0;
            mem_store_data <= 32'b0;
            mem_rd <= 5'b0;
            mem_pc_plus4 <= 32'b0;
        end 
        else begin
            mem_ctrl <= ex_ctrl;
            mem_alu_out <= ex_alu_out;
            mem_store_data <= ex_store_data;
            mem_rd <= ex_rd;
            mem_pc_plus4 <= ex_pc_plus4;
        end
    end
endmodule
