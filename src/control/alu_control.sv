`timescale 1ns / 1ps
module alu_control(
    input logic [1:0] aluop,
    input logic funct7_5,
    input logic [2:0] funct3,
    input logic [6:0] opcode,
    output logic [3:0] alu_ctr_in
    );
    always_comb begin
        alu_ctr_in = 4'b0;
        if (aluop == 2'b00) alu_ctr_in = 4'b0000;
        else if (aluop == 2'b01) alu_ctr_in = 4'b0001;
        else if (aluop == 2'b10) begin
            unique case(funct3)
                3'b000: begin
                    if (opcode == 7'b0110011)  // R-type
                        alu_ctr_in = funct7_5 ? 4'b0001 : 4'b0000; // SUB / ADD
                    else
                        alu_ctr_in = 4'b0000; // ADDI always ADD
                end 
                3'b111: alu_ctr_in = 4'b0010;
                3'b110: alu_ctr_in = 4'b0011;
                3'b010: alu_ctr_in = 4'b0100;
                3'b001: alu_ctr_in = 4'b0101;
                3'b101: begin
                    alu_ctr_in = funct7_5 ? 4'b0111: 4'b0110;
                    end
              endcase
        end
        
     end
endmodule
