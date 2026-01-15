`timescale 1ns / 1ps

module instruction_memory #(
    parameter string INIT_FILE = "prog2.hex",
    parameter DEPTH = 1024
)(
    input  logic [9:0]  addr,
    output logic [31:0] instr
);
    logic [31:0] mem [0:DEPTH-1];
    initial $readmemh(INIT_FILE, mem);
    assign instr = mem[addr];
endmodule
