`timescale 1ns / 1ps
module hazard_control_unit(
    input logic memread,//ID/EX is a load
    input logic [4:0] rd,  //ID/EX rd
    input logic [4:0] rs1, //IF/ID rs1
    input logic [4:0] rs2,  //IF/ID rs2
    output logic if_id_write, // 0 if stalling
    output logic pcwrite,   // 0 if stalling
    output logic flush  //1 to flush
    );
    always_comb begin
        if_id_write = 1'b1;
        pcwrite = 1'b1;
        flush = 1'b0;
        if (memread && (rd != 5'd0) && ((rs1 == rd) || (rs2 == rd))) begin
            if_id_write = 1'b0;
            pcwrite = 1'b0;
            flush = 1'b1;
        end
    end
endmodule
