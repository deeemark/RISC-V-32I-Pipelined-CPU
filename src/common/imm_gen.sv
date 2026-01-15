`timescale 1ns / 1ps
module imm_gen #(
    parameter DATA_W = 32
)(
input logic  [DATA_W - 1:0] instr,
output logic  [DATA_W - 1: 0] imm
    );
    logic [6:0] opcode;
    assign opcode = instr [6:0];
    
    always_comb begin
        case (opcode) 
            7'b0010011: imm = {{20{instr[31]}},instr[31:20]}; //addi
            7'b0000011: imm = {{20{instr[31]}},instr[31:20]}; //load
            7'b0100011: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};//store
            7'b1100011: imm = {{19{instr[31]}}, //branch
               instr[31],
               instr[7],
               instr[30:25],
               instr[11:8],
               1'b0};   
            7'b1101111: imm = {{11{instr[31]}}, //jump and link
               instr[31],
               instr[19:12],
               instr[20],
               instr[30:21],
               1'b0};
            default: imm = 32'b0;
        endcase
    end
endmodule
