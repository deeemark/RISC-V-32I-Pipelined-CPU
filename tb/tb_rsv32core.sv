`timescale 1ns/1ps
import cpu_types::*;

module tb_rsv32core;

  logic clk, reset;
  int cycle;
  rsv32core dut (.clk(clk), .reset(reset));
  initial clk = 1'b0;
  always #5 clk = ~clk;
  // HALT = jal x0,0
  localparam logic [31:0] HALT_INSTR = 32'h0000_006f;
  bit halt_seen;
  int drain_count;
  initial begin
    cycle = 0;
    halt_seen   = 0;
    drain_count = 0;
    reset = 1'b1;
    repeat (3) @(posedge clk);
    reset = 1'b0;
    $display("Time resolution is 1 ps");
    $display("cycle | IF:pc        IF:instr     | pcW ifidW hazF | fA fB | ID/EX: rs1 rs2 rd | rs1v        rs2v        imm         | EX:alu_out    st_data    br | EX/MEM: mW mR addr        store       rd | MEM:rdata     | WB: we rd wdata");
    $display("-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");
    repeat (200) begin
      @(posedge clk);
      cycle++;
      $write("%5d | 0x%08h 0x%08h |  %0d    %0d    %0d  | %02b %02b | ",
             cycle,
             dut.if_pc,
             dut.if_instr,
             dut.pc_write,
             dut.if_id_write,
             dut.hazard_flush,
             dut.forwardA,
             dut.forwardB);
      $write(" %2d  %2d  %2d | 0x%08h 0x%08h 0x%08h | ",
             dut.id_ex_rs1,
             dut.id_ex_rs2,
             dut.id_ex_rd,
             dut.id_ex_rs1_val,
             dut.id_ex_rs2_val,
             dut.id_ex_imm);
      $write("0x%08h 0x%08h  %0d | ",
             dut.ex_alu_out,
             dut.ex_rs2_fwd_out,
             dut.take_branch);
      $write(" %0d  %0d 0x%08h 0x%08h %2d | ",
             dut.ex_mem_ctrl.memwrite,
             dut.ex_mem_ctrl.memread,
             dut.ex_mem_alu_out,
             dut.ex_mem_store_data,
             dut.ex_mem_rd);
      $write("0x%08h | ",
             dut.mem_rdata);
      if (dut.wb_ctrl.regwrite && (dut.wb_rd != 5'd0))
        $write(" we=1 rd=x%0d wdata=0x%08h", dut.wb_rd, dut.wb_wdata);
      else
        $write(" we=0");
      $write("\n");
      //clean halt
      // Detect halt in IF once, then drain pipeline for a few cycles
      if (!halt_seen && dut.if_instr === HALT_INSTR) begin
        halt_seen   = 1;
        drain_count = 6;
        $display("\nHALT observed in IF (jal x0,0). Draining pipeline for %0d cycles...\n", drain_count);
      end
      if (halt_seen) begin
        drain_count--;
        if (drain_count <= 0) begin
          $display("\nPipeline drained. Stopping.\n");
          break;
        end
      end
    end
    // Snapshot regs
    $display("\n=== Regfile snapshot ===");
    $display("x1=0x%08h", dut.u_id.rf.regs[1]);
    $display("x2=0x%08h", dut.u_id.rf.regs[2]);
    $display("x3=0x%08h", dut.u_id.rf.regs[3]);
    $display("x4=0x%08h", dut.u_id.rf.regs[4]);
    $display("x5=0x%08h", dut.u_id.rf.regs[5]);
    $display("x6=0x%08h", dut.u_id.rf.regs[6]);
    $display("\nDONE.");
    $finish;
  end

endmodule
