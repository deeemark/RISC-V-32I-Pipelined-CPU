`timescale 1ns/1ps

module tb_instruction_memory;

  localparam int ADDR_W = 4;   // small for demo (16 words)
  localparam int DATA_W = 32;

  logic clk;
  logic [ADDR_W-1:0] addr;
  logic [DATA_W-1:0] instr;

  // DUT
  instruction_memory #(
    .ADDR_W(ADDR_W),
    .DATA_W(DATA_W),
    .INIT_FILE("prog.hex")
  ) dut (
    .clk(clk),
    .addr(addr),
    .instr(instr)
  );

  // Clock: 10ns period
  initial clk = 0;
  always #5 clk = ~clk;

  // Print header
  initial begin
    $display("Time(ps)   posedge   addr_sampled   instr_out");
    $display("---------------------------------------------");
  end

  // Print after synchronous update
  always_ff @(posedge clk) begin
    // Use $strobe so instr is the updated value
    $strobe("%0t      ^         %0d        0x%08h",
            $time, addr, instr);
  end

  // Drive addresses cleanly BEFORE each posedge
  initial begin
    addr = 0;

    #1; // stabilize before first posedge

    // Walk forward
    for (int i = 0; i < 8; i++) begin
      @(negedge clk);
      addr <= i[ADDR_W-1:0];
    end

    // Jump back to 3
    @(negedge clk);
    addr <= 3;

    repeat (3) @(posedge clk);

    $finish;
  end

endmodule

