`timescale 1ns / 1ps
import cpu_types::*;

module rsv32core(
    input  logic clk,
    input  logic reset
);
    // IF stage wires
    logic [31:0] if_pc;
    logic [31:0] if_instr;
    logic pc_src;
    logic pc_write;
    logic [31:0] branch_pc;
    if_stage u_if (
        .clk(clk),
        .reset(reset),
        .pc_src(pc_src),
        .pc_write(pc_write),
        .branch_pc(branch_pc),
        .pc (if_pc),
        .instr (if_instr)
    );

    // IF/ID pipeline reg wires
    logic [31:0] if_id_pc;
    logic [31:0] if_id_instr;
    logic if_id_valid;
    logic if_id_write;
    logic flush_if_id;
    if_id_reg u_ifid (
        .reset (reset),
        .clk (clk),
        .pc (if_pc),
        .instr (if_instr),
        .if_id_write(if_id_write),
        .flush_if_id(flush_if_id),
        .if_id_pc (if_id_pc),
        .if_id_instr(if_id_instr),
        .if_id_valid(if_id_valid)
    );

    // ID stage wires
    logic [4:0] id_rs1, id_rs2, id_rd;
    logic [31:0] id_rs1_val, id_rs2_val;
    logic [31:0] id_imm;
    logic [31:0] id_branch_target;
    ctrl_t id_ctrl_raw;
    ctrl_t id_ctrl;           // gated with valid
    logic [2:0] id_funct3;
    logic id_funct7_5;
    logic [31:0] id_pc_plus4;
    // WB feedback wires
    ctrl_t wb_ctrl;
    logic [31:0] wb_alu_out, wb_rdata;
    logic [4:0] wb_rd;
    logic [31:0] wb_wdata;
    logic [31:0] wb_pc_plus4;
    always_comb begin
        unique case (wb_ctrl.wb_sel)
            2'b00: wb_wdata = wb_alu_out;
            2'b01: wb_wdata = wb_rdata;
            2'b10: wb_wdata = wb_pc_plus4; // JAL link
            default: wb_wdata = wb_alu_out;
        endcase
    end
    id_stage u_id (
        .if_id_pc(if_id_pc),
        .if_id_instr(if_id_instr),
        .if_id_valid(if_id_valid),
        .wb_regwrite(wb_ctrl.regwrite),
        .wb_rd(wb_rd),
        .wb_wdata(wb_wdata),
        .clk(clk),
        .reset(reset),
        .rs1(id_rs1),
        .rs2(id_rs2),
        .rd(id_rd),
        .rs1_val(id_rs1_val),
        .rs2_val(id_rs2_val),
        .imm(id_imm),
        .branch_target(id_branch_target),
        .ctrl(id_ctrl_raw),
        .funct3(id_funct3),
        .funct7_5(id_funct7_5),
        .pc_plus4(id_pc_plus4)
    );
    // Gate control with IF/ID valid
    assign id_ctrl = (if_id_valid) ? id_ctrl_raw : '0;
    // ID/EX pipeline reg wires
    ctrl_t id_ex_ctrl;
    logic [31:0] id_ex_pc;
    logic [31:0] id_ex_branch_target;
    logic [31:0] id_ex_rs1_val, id_ex_rs2_val;
    logic [31:0] id_ex_imm;
    logic [4:0] id_ex_rs1, id_ex_rs2, id_ex_rd;
    logic [2:0] id_ex_funct3;
    logic id_ex_funct7_5;
    logic [31:0] id_ex_pc_plus4;
    logic flush_id_ex;    // from hazard OR branch flush
    id_ex_reg u_idex (
        .clk(clk),
        .reset(reset),
        .flush(flush_id_ex),
        .id_ctrl(id_ctrl),
        .id_pc(if_id_pc),
        .id_branch_target(id_branch_target),
        .id_rs1_val(id_rs1_val),
        .id_rs2_val(id_rs2_val),
        .id_imm(id_imm),
        .id_rs1(id_rs1),
        .id_rs2(id_rs2),
        .id_rd(id_rd),
        .id_funct3(id_funct3),
        .id_funct7_5(id_funct7_5),
        .id_pc_plus4(id_pc_plus4),
        .ex_ctrl(id_ex_ctrl),
        .ex_pc(id_ex_pc),
        .ex_branch_target(id_ex_branch_target),
        .ex_rs1_val(id_ex_rs1_val),
        .ex_rs2_val(id_ex_rs2_val),
        .ex_imm(id_ex_imm),
        .ex_rs1(id_ex_rs1),
        .ex_rs2(id_ex_rs2),
        .ex_rd(id_ex_rd),
        .ex_funct3(id_ex_funct3),
        .ex_funct7_5(id_ex_funct7_5),
        .ex_pc_plus4(id_ex_pc_plus4)
    );
    // Hazard detection
    logic hazard_flush;
    hazard_control_unit u_hazard (
        .memread(id_ex_ctrl.memread),
        .rd(id_ex_rd),
        .rs1(if_id_instr[19:15]),
        .rs2(if_id_instr[24:20]),
        .if_id_write(if_id_write),
        .pcwrite(pc_write),
        .flush(hazard_flush)
    );
    // Forwarding unit
    logic [1:0] forwardA, forwardB;
    // EX/MEM wires needed for forwarding
    ctrl_t ex_mem_ctrl;
    logic [31:0] ex_mem_alu_out;
    logic [31:0] ex_mem_store_data;
    logic [4:0] ex_mem_rd;
    logic [31:0] ex_mem_pc_plus4;
    forwarding_unit u_fwd (
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .ex_mem_rd(ex_mem_rd),
        .mem_wb_rd(wb_rd),
        .ex_mem_regwrite(ex_mem_ctrl.regwrite),
        .mem_wb_regwrite(wb_ctrl.regwrite),
        .forwardA(forwardA),
        .forwardB(forwardB)
    );

    // EX stage
    ctrl_t ex_ctrl_out;
    logic [31:0] ex_alu_out;
    logic [31:0] ex_rs2_fwd_out;
    logic [4:0] ex_rd_out;
    logic take_branch;
    ex_stage u_ex (
        .id_ex_ctrl(id_ex_ctrl),
        .id_ex_branch_target(id_ex_branch_target),
        .id_ex_rs1_val(id_ex_rs1_val),
        .id_ex_rs2_val(id_ex_rs2_val),
        .id_ex_imm(id_ex_imm),
        .id_ex_rd(id_ex_rd),
        .id_ex_funct3(id_ex_funct3),
        .id_ex_funct7_5 (id_ex_funct7_5),
        .forwardA (forwardA),
        .forwardB (forwardB),
        .ex_mem_alu_out (ex_mem_alu_out),
        .mem_wb_wdata (wb_wdata),
        .ex_ctrl_out (ex_ctrl_out),
        .alu_out (ex_alu_out),
        .rs2_fwd_out (ex_rs2_fwd_out),
        .rd_out (ex_rd_out),
        .take_branch(take_branch),
        .branch_pc(branch_pc)
    );

    // Branch redirect to PC
    assign pc_src = take_branch;
    // Flush wrong-path instructions on taken redirect
    assign flush_if_id = take_branch;
    // Combine hazard bubble and redirect flush
    assign flush_id_ex = hazard_flush || take_branch;
    // EX/MEM pipeline reg
    ex_mem_reg u_exmem (
        .clk(clk),
        .reset(reset),
        .ex_ctrl(ex_ctrl_out),
        .ex_alu_out(ex_alu_out),
        .ex_store_data(ex_rs2_fwd_out),
        .ex_rd(ex_rd_out),
        .ex_pc_plus4(id_ex_pc_plus4),
        .mem_ctrl(ex_mem_ctrl),
        .mem_alu_out(ex_mem_alu_out),
        .mem_store_data(ex_mem_store_data),
        .mem_rd(ex_mem_rd),
        .mem_pc_plus4(ex_mem_pc_plus4)
    );

    // MEM stage
    ctrl_t mem_ctrl_out;
    logic [31:0] mem_alu_out;
    logic [31:0] mem_rdata;
    logic [4:0] mem_rd_out;
    mem_stage u_mem(
        .ex_mem_ctrl(ex_mem_ctrl),
        .ex_mem_alu_out(ex_mem_alu_out),
        .ex_mem_store_data(ex_mem_store_data),
        .ex_mem_rd(ex_mem_rd),
        .clk(clk),
        .mem_ctrl_out(mem_ctrl_out),
        .mem_alu_out(mem_alu_out),
        .mem_rdata(mem_rdata),
        .mem_rd_out(mem_rd_out)
    );

    // MEM/WB pipeline reg
    mem_wb_reg u_memwb (
        .clk(clk),
        .reset(reset),
        .mem_ctrl(mem_ctrl_out),
        .mem_alu_out(mem_alu_out),
        .mem_rdata(mem_rdata),
        .mem_rd(mem_rd_out),
        .mem_pc_plus4(ex_mem_pc_plus4),
        .wb_pc_plus4(wb_pc_plus4),
        .wb_ctrl(wb_ctrl),
        .wb_alu_out(wb_alu_out),
        .wb_rdata(wb_rdata),
        .wb_rd(wb_rd)
    );
endmodule
