`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/12/2026 03:34:35 PM
// Design Name: 
// Module Name: tb_imm_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_imm_gen;
    localparam DATA_W = 32;
    logic [DATA_W-1:0] instr;
    logic [DATA_W-1:0] imm;
    imm_gen #(.DATA_W(DATA_W)) dut (
        .instr(instr),
        .imm(imm)
    );

    initial begin
    $display("time  instr                imm");
    $display("---------------------------------------");

    // Example 1: I-type immediate = -12
    // Put -12 into instr[31:20]
    instr = 32'b0;
    instr[6:0]   = 7'b0010011;         // OP-IMM (like addi)
    instr[31:20] = -12'sd12;          // immediate field
    #1;
    $display("%0t  0x%08h  0x%08h", $time, instr, imm);

    // Example 2: S-type immediate = -12
    instr = 32'b0;
    instr[6:0]    = 7'b0100011;         // STORE (S-type)
    {instr[31:25], instr[11:7]} = -12'sd12;
    #1;
    $display("%0t  0x%08h  0x%08h", $time, instr, imm);

    $finish;
  end
endmodule
