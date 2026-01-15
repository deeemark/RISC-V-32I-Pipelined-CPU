`timescale 1ns / 1ps
module if_stage(
    input logic clk,
    input logic reset,
    input logic pc_src,
    input logic pc_write,
    input logic [31:0] branch_pc,
    output logic [31:0] pc,
    output logic [31:0] instr
);
    logic [9:0] imem_addr;
    pc_counter u_pc (
        .clk(clk),
        .reset(reset),
        .pc_src(pc_src),
        .pc_write(pc_write),
        .branch_pc(branch_pc),
        .pc(pc)
    );
    assign imem_addr = pc[11:2];
    instruction_memory u_imem (
        .addr(imem_addr),
        .instr(instr)
    );
endmodule
