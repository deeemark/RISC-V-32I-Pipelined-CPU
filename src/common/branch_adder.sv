`timescale 1ns / 1ps
module branch_adder #(
parameter ADDR_W = 32
)(
    input logic [ADDR_W-1:0] pc,
    input logic [ADDR_W-1:0] imm,
    output logic [ADDR_W-1:0] updated_pc
    );
    assign updated_pc = imm + pc;
endmodule
