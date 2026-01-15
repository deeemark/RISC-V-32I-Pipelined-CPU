`timescale 1ns / 1ps
import cpu_types::*;
module id_stage(
    // From IF/ID
    input logic [31:0] if_id_pc,
    input logic [31:0] if_id_instr,
    input logic if_id_valid,
    // From WB
    input logic wb_regwrite,
    input logic [4:0] wb_rd,
    input logic [31:0] wb_wdata,
    // Utility
    input logic clk,
    input logic reset,
    // register specifiers
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [4:0] rd,
    // Regfile read values
    output logic [31:0] rs1_val,
    output logic [31:0] rs2_val,
    // Immediate + branch target
    output logic [31:0] imm,
    output logic [31:0] branch_target,
    // Control
    output ctrl_t ctrl,
    // Funct bits for ALU control
    output logic [2:0]  funct3,
    output logic funct7_5,
    output logic [6:0] opcode_out,
    output logic [31:0] pc_plus4

);
    logic [6:0] opcode;
    assign pc_plus4 = if_id_pc + 32'd4;
    // Field extraction
    assign opcode_out = opcode;
    assign opcode  = if_id_instr[6:0];
    assign rd  = if_id_instr[11:7];
    assign funct3 = if_id_instr[14:12];
    assign rs1 = if_id_instr[19:15];
    assign rs2 = if_id_instr[24:20];
    assign funct7_5 = if_id_instr[30];
    // Regfile
    reg_file rf (
        .rs1(rs1),
        .rs2(rs2),
        .rd(wb_rd),
        .rd_data(wb_wdata),
        .we(wb_regwrite),
        .clk(clk),
        .reset(reset),
        .rs1_data(rs1_val),
        .rs2_data(rs2_val)
    );
    // Immediate generation
    imm_gen ig (
        .instr(if_id_instr),
        .imm(imm)
    );
    // Branch target adder
    branch_adder ba (
        .pc(if_id_pc),
        .imm(imm),
        .updated_pc(branch_target)
    );
    // Control unit outputs
    logic cu_alusrc, cu_memtoreg, cu_regwrite, cu_memread, cu_memwrite, cu_branch;
    logic [1:0] cu_aluop;
    control_unit cu (
        .opcode(opcode),
        .alusrc(cu_alusrc),
        .memtoreg(cu_memtoreg),
        .regwrite(cu_regwrite),
        .memread (cu_memread),
        .memwrite(cu_memwrite),
        .branch(cu_branch),
        .aluop(cu_aluop),
        .jump(ctrl.jump),
        .wb_sel(ctrl.wb_sel)
    );
    always_comb begin
        ctrl = '0;  // default NOP
        if (if_id_valid) begin
            ctrl.alusrc = cu_alusrc;
            ctrl.memtoreg = cu_memtoreg;
            ctrl.regwrite = cu_regwrite;
            ctrl.memread = cu_memread;
            ctrl.memwrite = cu_memwrite;
            ctrl.branch = cu_branch;
            ctrl.aluop = cu_aluop;
        end
    end

endmodule
