`timescale 1ns / 1ps
module if_id_reg(
    input logic reset,
    input logic clk,
    input logic [31:0] pc,
    input logic [31:0] instr,
    input logic if_id_write,
    input logic flush_if_id,
    output logic [31:0] if_id_pc,
    output logic [31:0] if_id_instr,
    output logic if_id_valid
);
    always_ff @(posedge clk) begin
      if (reset) begin
        if_id_pc <= 32'b0;
        if_id_instr <= 32'h0000_0013;
        if_id_valid <= 1'b0;
      end
      else if (flush_if_id) begin
          if_id_pc    <= 32'b0;
          if_id_instr <= 32'h0000_0013;
          if_id_valid <= 1'b0;
       end 
      else if (if_id_write) begin
        if_id_pc <= pc;
        if_id_instr <= instr;
        if_id_valid <= 1'b1;
      end
    end
endmodule
