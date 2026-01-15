`timescale 1ns / 1ps

module control_unit(
    input logic [6:0] opcode,
    output logic alusrc,
    output logic memtoreg,
    output logic regwrite,
    output logic memread,
    output logic memwrite,
    output logic branch,
    output logic [1:0] aluop,
    output logic jump,
    output logic [1:0] wb_sel
    );
    
    always_comb begin
        alusrc   = 1'b0;
        memtoreg = 1'b0;
        regwrite = 1'b0;
        jump = 1'b0;
        wb_sel   = 2'b00;
        memread  = 1'b0;
        memwrite = 1'b0;
        branch   = 1'b0;
        aluop    = 2'b00;
        case(opcode)
            7'b0110011: begin //r format
                regwrite = 1'b1;
                alusrc   = 1'b0;
                aluop    = 2'b10;
            end
            7'b0000011: begin //load word
                regwrite = 1'b1;
                memread  = 1'b1;
                memtoreg = 1'b0;
                alusrc   = 1'b1;
                aluop    = 2'b00;
                wb_sel   = 2'b01;
            end
            7'b0100011: begin //store word
                memwrite = 1'b1;
                alusrc   = 1'b1;
                aluop    = 2'b00;
            end
            7'b1100011: begin // branch
                branch   = 1'b1;
                alusrc   = 1'b0;
                aluop    = 2'b01;
            end
            7'b0010011: begin //addi
                regwrite = 1'b1;
                alusrc = 1'b1;
                aluop = 2'b00;
            end
            7'b1101111: begin // jal
                regwrite = 1'b1;
                jump = 1'b1;
                wb_sel   = 2'b10; // write PC+4
            end
        endcase
    end
endmodule
