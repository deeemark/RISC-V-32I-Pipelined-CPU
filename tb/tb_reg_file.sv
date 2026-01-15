`timescale 1ns / 1ps

module tb_reg_file;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;
    logic [31:0] rd_data;
    logic we;
    logic clk;
    logic reset;
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    reg_file dut(
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .rd_data(rd_data),
    .we(we),
    .clk(clk),
    .reset(reset),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data)
    );
    
    initial clk = 0;
    always #5 clk = ~clk;    
    
    // handy task: do a write on next posedge
  task automatic write_reg(input [4:0] r, input [31:0] v);
    begin
      @(negedge clk);   // set up before posedge
      rd      = r;
      rd_data = v;
      we      = 1'b1;
      @(posedge clk);   // write happens here
      #1;               // allow signals to settle
      we      = 1'b0;
    end
  endtask

  // handy task: set read addresses and print results
  task automatic read_regs(input [4:0] a, input [4:0] b);
    begin
      rs1 = a;
      rs2 = b;
      #1; // combinational settle
      $display("t=%0t  rs1=x%0d -> 0x%08h | rs2=x%0d -> 0x%08h",
               $time, rs1, rs1_data, rs2, rs2_data);
    end
  endtask

  initial begin
    // init inputs
    rs1 = 0; rs2 = 0;
    rd = 0; rd_data = 0;
    we = 0;
    reset = 1;

    $display("=== Reset asserted ===");
    // hold reset through a posedge so regfile clears
    @(posedge clk);
    #1;

    // read a couple regs (should be 0)
    read_regs(5'd0, 5'd1);
    read_regs(5'd2, 5'd31);

    $display("=== Release reset ===");
    @(negedge clk);
    reset = 0;

    // write x1 and x2
    $display("=== Write x1=0xA5A5A5A5, x2=0x12345678 ===");
    write_reg(5'd1, 32'hA5A5A5A5);
    write_reg(5'd2, 32'h12345678);

    // read back
    read_regs(5'd1, 5'd2);

    // attempt to write x0 (should NOT change)
    $display("=== Attempt write x0=0xFFFFFFFF (should be ignored) ===");
    write_reg(5'd0, 32'hFFFF_FFFF);
    read_regs(5'd0, 5'd1);  // x0 must still be 0; x1 unchanged

    // show combinational read behavior (change rs1/rs2 without clock)
    $display("=== Combinational read check (no clock needed) ===");
    rs1 = 5'd2; rs2 = 5'd1;
    #1;
    $display("t=%0t  rs1_data=0x%08h  rs2_data=0x%08h",
             $time, rs1_data, rs2_data);

    // optional: pulse reset again and confirm cleared
    $display("=== Pulse reset again ===");
    @(negedge clk);
    reset = 1;
    @(posedge clk);
    #1;
    reset = 0;

    read_regs(5'd1, 5'd2);  // should be 0 after reset

    $display("=== DONE ===");
    $finish;
  end

endmodule