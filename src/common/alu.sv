`timescale 1ns / 1ps
module alu #(
parameter ADDR_W = 32
)
(
    input logic [3:0] alu_ctr,
    input logic [ADDR_W-1:0] var1,
    input logic [ADDR_W-1:0] var2,
    output logic zero,
    output logic [ADDR_W-1:0] alu_res
    );
    typedef enum logic [3:0] {
    ALU_ADD = 4'b0000,
    ALU_SUB = 4'b0001,
    ALU_AND = 4'b0010,
    ALU_OR = 4'b0011,
    ALU_SLT = 4'b0100,
    ALU_SLL = 4'b0101,
    ALU_SRL = 4'b0110,
    ALU_SRA = 4'b0111
} alu_ctrl_t;
    always_comb begin
        unique case (alu_ctrl_t'(alu_ctr))
            ALU_ADD: alu_res = var1 + var2;
            ALU_SUB: alu_res = var1 - var2;
            ALU_AND: alu_res = var1 & var2;
            ALU_OR: alu_res = var1 | var2;
            ALU_SLT: alu_res = ($signed(var1) < $signed(var2)) ? {{(ADDR_W-1){1'b0}},1'b1} : '0;
            ALU_SLL: alu_res = var1 << var2[4:0];
            ALU_SRL: alu_res = var1 >> var2[4:0];
            ALU_SRA: alu_res = $signed(var1) >>> var2[4:0];
            default: alu_res = '0;
        endcase
    end
    assign zero = (alu_res == '0);
endmodule
