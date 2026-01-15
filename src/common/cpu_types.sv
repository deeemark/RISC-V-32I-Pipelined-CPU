package cpu_types;
    typedef struct packed {
        logic  regwrite;
        logic  memread;
        logic  memwrite;
        logic  memtoreg;
        logic  branch;
        logic alusrc;
        logic [1:0] aluop;
		logic  is_rtype;
		logic jump;
		logic [1:0] wb_sel;     // 00=ALU, 01=MEM, 10=PC+4
    } ctrl_t;
endpackage

