`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/11/2026 06:39:45 PM
// Design Name: 
// Module Name: tb_pc_counter
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
module tb_pc_counter;

  localparam ADDR_W = 10;
  logic clk, reset;
  logic [ADDR_W-1:0] pc;

  pc_counter #(.ADDR_W(ADDR_W)) dut (
    .clk(clk),
    .reset(reset),
    .pc(pc)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  int cycle = 0;
  always @(posedge clk) begin
    cycle++;
    $strobe("cycle=%0d  pc=%0d (0x%h)", cycle, pc, pc);
  end

  initial begin
    reset = 1;
    #12;
    reset = 0;

    repeat (10) @(posedge clk);
    $finish;
  end

endmodule
