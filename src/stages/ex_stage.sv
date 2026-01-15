`timescale 1ns / 1ps
import cpu_types::*;

module ex_stage(
    // Inputs from ID/EX pipeline reg
    input ctrl_t id_ex_ctrl,
    input logic [31:0] id_ex_branch_target,
    input logic [31:0] id_ex_rs1_val,
    input logic [31:0] id_ex_rs2_val,
    input logic [31:0] id_ex_imm,
    input logic [4:0] id_ex_rd,
    input logic [2:0] id_ex_funct3,
    input logic id_ex_funct7_5,
    input logic [6:0] id_ex_opcode,
    input logic [31:0] id_ex_pc_plus4,
    // Forwarding selects
    input logic [1:0] forwardA,
    input logic [1:0] forwardB,
    // Values for forwarding
    input logic [31:0] ex_mem_alu_out,  // from EX/MEM
    input logic [31:0] mem_wb_wdata, // from WB mux output
    // Outputs to EX/MEM reg
    output ctrl_t ex_ctrl_out,
    output logic [31:0] alu_out,
    output logic [31:0] rs2_fwd_out,  // store data after forwarding
    output logic [4:0] rd_out,
    output logic [31:0] pc_plus4_out,
    // Branch redirect
    output logic take_branch,
    output logic [31:0] branch_pc
);
    // Forward rs1/rs2 into EX
    logic [31:0] opA, opB_raw;
    always_comb begin
        // take values from ID/EX as default
        opA  = id_ex_rs1_val;
        opB_raw= id_ex_rs2_val;
        // forwardA mux
        unique case (forwardA)
            2'b00: opA = id_ex_rs1_val;
            2'b10: opA = ex_mem_alu_out;
            2'b01: opA = mem_wb_wdata;
            default: opA = id_ex_rs1_val;
        endcase
        // forwardB mux
        unique case (forwardB)
            2'b00: opB_raw = id_ex_rs2_val;
            2'b10: opB_raw = ex_mem_alu_out;
            2'b01: opB_raw = mem_wb_wdata;
            default: opB_raw = id_ex_rs2_val;
        endcase
    end
    assign rs2_fwd_out = opB_raw;
    // ALU input B mux reg vs imm
    logic [31:0] opB;
    assign opB = (id_ex_ctrl.alusrc) ? id_ex_imm : opB_raw;
    //ALU control decode
    logic [3:0] alu_sel;
    alu_control u_aluctrl (
        .aluop(id_ex_ctrl.aluop),
        .opcode(id_ex_opcode),
        .funct7_5(id_ex_funct7_5),
        .funct3(id_ex_funct3),
        .alu_ctr_in(alu_sel)
    );
    //ALU
    logic zero;
    alu u_alu (
        .alu_ctr(alu_sel),
        .var1(opA),
        .var2(opB),
        .zero(zero),
        .alu_res(alu_out)
    );
    //Branch decision
    logic take_jump;
    assign take_jump = id_ex_ctrl.jump;
    // branch=1 and aluop=01  means equal.
    assign take_branch = (id_ex_ctrl.branch && zero) || id_ex_ctrl.jump;
    // Branch PC comes from ID/EX
    assign branch_pc = id_ex_branch_target;
    // Passthrough
    assign ex_ctrl_out = id_ex_ctrl;
    assign rd_out = id_ex_rd;
    assign pc_plus4_out = id_ex_pc_plus4;
endmodule
