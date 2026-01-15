`timescale 1ns / 1ps
import cpu_types::*;

module id_ex_reg(
    input logic clk,
    input logic reset,
    // Control from hazard unit
    input logic flush,     // 1 = turn this into a NOP
    // Inputs from ID stage
    input ctrl_t id_ctrl,
    input logic [31:0] id_pc,
    input logic [31:0] id_branch_target,
    input logic [31:0] id_rs1_val,
    input logic [31:0] id_rs2_val,
    input logic [31:0] id_imm,
    input logic [4:0] id_rs1,
    input logic [4:0] id_rs2,
    input logic [4:0] id_rd,
    input logic [2:0] id_funct3,
    input logic id_funct7_5,
    input logic [31:0] id_pc_plus4,
    // Outputs to EX stage
    output ctrl_t ex_ctrl,
    output logic [31:0] ex_pc,
    output logic [31:0] ex_branch_target,
    output logic [31:0] ex_rs1_val,
    output logic [31:0] ex_rs2_val,
    output logic [31:0] ex_imm,
    output logic [4:0] ex_rs1,
    output logic [4:0] ex_rs2,
    output logic [4:0] ex_rd,
    output logic [2:0] ex_funct3,
    output logic ex_funct7_5,
    input  logic [6:0] id_opcode,
    output logic [6:0] ex_opcode,
    output logic [31:0] ex_pc_plus4
);
    always_ff @(posedge clk) begin
        if (reset || flush) begin
                ex_opcode <= 7'b0;
                ex_pc_plus4 <= 32'b0;
            end 
            else begin
                ex_opcode <= id_opcode;
                ex_pc_plus4 <= id_pc_plus4;
         end
        if (reset) begin
            ex_ctrl <= '0;
            ex_pc <= 32'b0;
            ex_branch_target <= 32'b0;
            ex_rs1_val <= 32'b0;
            ex_rs2_val <= 32'b0;
            ex_imm <= 32'b0;
            ex_rs1 <= 5'b0;
            ex_rs2 <= 5'b0;
            ex_rd  <= 5'b0;
            ex_funct3 <= 3'b0;
            ex_funct7_5 <= 1'b0;
        end 
        else if (flush) begin
            // Insert a bubble
            // zeroing for debug
            ex_ctrl <= '0;
            ex_pc <= 32'b0;
            ex_branch_target <= 32'b0;
            ex_rs1_val <= 32'b0;
            ex_rs2_val <= 32'b0;
            ex_imm <= 32'b0;
            ex_rs1 <= 5'b0;
            ex_rs2 <= 5'b0;
            ex_rd <= 5'b0;
            ex_funct3 <= 3'b0;
            ex_funct7_5 <= 1'b0;
        end 
        else begin
            ex_ctrl <= id_ctrl;
            ex_pc <= id_pc;
            ex_branch_target <= id_branch_target;
            ex_rs1_val <= id_rs1_val;
            ex_rs2_val <= id_rs2_val;
            ex_imm <= id_imm;
            ex_rs1 <= id_rs1;
            ex_rs2 <= id_rs2;
            ex_rd <= id_rd;
            ex_funct3 <= id_funct3;
            ex_funct7_5 <= id_funct7_5;
        end
    end
endmodule
