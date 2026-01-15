`timescale 1ns / 1ps
module reg_file(
    // read based input
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    // write based input
    input logic [4:0] rd,
    input logic [31:0] rd_data,
    input logic we,
    // utility
    input logic clk,
    input logic reset,
    // read based output
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data 
    );
    logic [31:0] regs [31:0];
    assign rs1_data = (rs1 == 0) ? 32'b0 : regs[rs1]; 
    assign rs2_data = (rs2 == 0) ? 32'b0 : regs[rs2];
    always_ff @(posedge clk) begin
        if (reset) begin
            for(int i = 0;i < 32; i++)
                regs[i] <= 32'b0;
         end
         else if (we && rd != 0) begin
            regs[rd] <= rd_data;
         end
    end
         
endmodule
