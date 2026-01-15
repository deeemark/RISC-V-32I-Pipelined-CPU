`timescale 1ns / 1ps
import cpu_types::*;

module mem_stage(
    // From EX/MEM reg
    input ctrl_t ex_mem_ctrl,
    input logic [31:0] ex_mem_alu_out, // address
    input logic [31:0] ex_mem_store_data,  // value to store
    input logic [4:0] ex_mem_rd,
    // Utility
    input logic clk,
    // To MEM/WB reg
    output ctrl_t mem_ctrl_out,
    output logic [31:0] mem_alu_out, // pass-through for WB
    output logic [31:0] mem_rdata, // loaded data
    output logic [4:0]  mem_rd_out
);
    // Data memory
    data_memory #(.DEPTH_WORDS(1024)) dmem (
        .clk(clk),
        .memread(ex_mem_ctrl.memread),
        .memwrite(ex_mem_ctrl.memwrite),
        .addr(ex_mem_alu_out),
        .wdata(ex_mem_store_data),
        .rdata(mem_rdata)
    );
    // Pass-throughs
    assign mem_ctrl_out = ex_mem_ctrl;
    assign mem_alu_out = ex_mem_alu_out;
    assign mem_rd_out = ex_mem_rd;
endmodule
