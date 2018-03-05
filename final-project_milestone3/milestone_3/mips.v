`timescale 1ns/1ps
`define mydelay 1

//--------------------------------------------------------------
// mips.v
// David_Harris@hmc.edu and Sarah_Harris@hmc.edu 23 October 2005
// Single-cycle MIPS processor
//--------------------------------------------------------------

// single-cycle MIPS processor
module mips(input         clk, reset,
            output [31:0] pc,
            input  [31:0] instr,
            output        memwrite,
            output [31:0] memaddr,
            output [31:0] memwritedata,
            input  [31:0] memreaddata);

  wire        signext, shiftl16, branch;
  wire [1:0]  memtoreg;
  wire [1:0]  regdst;
  wire        pcsrc, zero;
  wire        alusrc, regwrite;
  wire [1:0]  jump;
  wire [2:0]  alucontrol;
  wire [1:0]  jrjump;

  // Instantiate Controller
  controller c(
    .op         (instr[31:26]), 
		.funct      (instr[5:0]), 
		.zero       (zero),
		.signext    (signext),
		.shiftl16   (shiftl16),
		.memtoreg   (memtoreg),
		.memwrite   (memwrite),
		.pcsrc      (pcsrc),
		.alusrc     (alusrc),
		.regdst     (regdst),
		.regwrite   (regwrite),
		.jump       (jump),
		.alucontrol (alucontrol),
		.jrjump     (jrjump));

  // Instantiate Datapath
  datapath dp(
    .clk        (clk),
    .reset      (reset),
    .signext    (signext),
    .shiftl16   (shiftl16),
    .memtoreg   (memtoreg),
    .pcsrc      (pcsrc),
    .alusrc     (alusrc),
    .regdst     (regdst),
    .regwrite   (regwrite),
    .jump       (jump),
    .alucontrol (alucontrol),
	 .jrjump     (jrjump),
    .zero       (zero),
    .pc         (pc),
    .instr      (instr),
    .aluout     (memaddr), 
    .writedata  (memwritedata),
    .readdata   (memreaddata));

endmodule

module controller(input  [5:0] op, funct,
                  input        zero,
                  output       signext,
                  output       shiftl16,
                  output [1:0] memtoreg, 
						output       memwrite,
                  output       pcsrc, alusrc,
                  output [1:0] regdst, 
						output       regwrite,
                  output [1:0] jump,
                  output [2:0] alucontrol,
						output [1:0] jrjump);

  wire [1:0] aluop;
  wire       branch;

  maindec md(
    .op       (op),
    .signext  (signext),
    .shiftl16 (shiftl16),
    .memtoreg (memtoreg),
    .memwrite (memwrite),
    .branch   (branch),
    .alusrc   (alusrc),
    .regdst   (regdst),
    .regwrite (regwrite),
    .jump     (jump),
    .aluop    (aluop));

  aludec ad( 
    .funct      (funct),
    .aluop      (aluop), 
    .alucontrol (alucontrol),
	 .jrjump     (jrjump));

  assign pcsrc = branch & (op == 6'b000100 ? zero : ~zero);

endmodule


module maindec(input  [5:0] op,
               output       signext,
               output       shiftl16,
               output [1:0] memtoreg, 
					output       memwrite,
               output       branch, alusrc,
               output [1:0] regdst, 
					output       regwrite,
               output [1:0] jump,
               output [1:0] aluop);

  reg [13:0] controls;

  assign {signext, shiftl16, regwrite, regdst, alusrc, branch, memwrite,
          memtoreg, jump, aluop} = controls;

  always @(*)
    case(op)                             //123445678899aa
      6'b000000: controls <= #`mydelay 14'b00110000000011; // Rtype
      6'b100011: controls <= #`mydelay 14'b10100100100000; // LW
      6'b101011: controls <= #`mydelay 14'b10000101000000; // SW
      6'b000101,
      6'b000100: controls <= #`mydelay 14'b10000010000001; // BNE, BEQ
      6'b001000, 
      6'b001001: controls <= #`mydelay 14'b10100100000000; // ADDI, ADDIU: only difference is exception
      6'b001101: controls <= #`mydelay 14'b00100100000010; // ORI
      6'b001111: controls <= #`mydelay 14'b01100100000000; // LUI
      6'b000010: controls <= #`mydelay 14'b00000000001000; // J
		6'b000011: controls <= #`mydelay 14'b00101000011000; // JAL
      default:   controls <= #`mydelay 14'bxxxxxxxxxxxxxx; // ???
    endcase

endmodule


// Add JR signal
module aludec(input      [5:0] funct,
              input      [1:0] aluop,
              output     [2:0] alucontrol,
				  output     [1:0] jrjump);

  reg [4:0] controls;
  assign {alucontrol, jrjump} = controls;				  
  //assign jrjump = (funct == 6'b001000 ? 2'b01 : 2'b00);			  
  always @(*)
  begin
    
  
    case(aluop)
      2'b00: controls <= #`mydelay 5'b01000;  // add
      2'b01: controls <= #`mydelay 5'b11000;  // sub
      2'b10: controls <= #`mydelay 5'b00100;  // or
      default: case(funct)          // RTYPE
          6'b100000,
          6'b100001: controls <= #`mydelay 5'b01000; // ADD, ADDU: only difference is exception
          6'b100010,
          6'b100011: controls <= #`mydelay 5'b11000; // SUB, SUBU: only difference is exception
          6'b100100: controls <= #`mydelay 5'b00000; // AND
          6'b100101: controls <= #`mydelay 5'b00100; // OR
			 6'b101011,
          6'b101010: controls <= #`mydelay 5'b11100; // SLTU, SLT
			 6'b001000: controls <= #`mydelay 5'b00001; // JR
          default:   controls <= #`mydelay 5'bxxxxx; // ???
        endcase
    endcase
  end
	 
  
endmodule

module datapath(input         clk, reset,
                input         signext,
                input         shiftl16,
                input  [1:0]  memtoreg, 
					 input         pcsrc,
                input         alusrc, 
					 input  [1:0]  regdst,
                input         regwrite, 
					 input  [1:0]  jump,
                input  [2:0]  alucontrol,
					 input  [1:0]  jrjump,
                output        zero,
                output [31:0] pc,
                input  [31:0] instr,
                output [31:0] aluout, writedata,
                input  [31:0] readdata);
  
  wire [4:0]  writereg;
  wire [31:0] pcnext, pcnextbr, pcplus4, pcbranch;
  wire [31:0] signimm, signimmsh, shiftedimm;
  wire [31:0] srca, srcb;
  wire [31:0] result;
  wire        shift;

  // next PC logic
  flopr #(32) pcreg(
    .clk   (clk),
    .reset (reset),
    .d     (pcnext),
    .q     (pc));

  adder pcadd1(
    .a (pc),
    .b (32'b100),
    .y (pcplus4));

  sl2 immsh(
    .a (signimm),
    .y (signimmsh));
				 
  adder pcadd2(
    .a (pcplus4),
    .b (signimmsh),
    .y (pcbranch));

  mux2 #(32) pcbrmux(
    .d0  (pcplus4),
    .d1  (pcbranch),
    .s   (pcsrc),
    .y   (pcnextbr));
// pcmux modified mux2 to mux3


  mux3 #(32) pcmux(
    .d0   (pcnextbr),
    .d1   ({pcplus4[31:28], instr[25:0], 2'b00}),
	 .d2   (srca),
    .s    ({jump[1], jrjump[0]}),
    .y    (pcnext));

/*
  mux2 #(32) pcmux(
    .d0   (pcnextbr),
    .d1   ({pcplus4[31:28], instr[25:0], 2'b00}),
    .s    (jump[1]),
    .y    (pcnext));
*/
  // register file logic
  regfile rf(
    .clk     (clk),
    .we      (regwrite),
    .ra1     (instr[25:21]),
    .ra2     (instr[20:16]),
    .wa      (writereg),
    .wd      (result),
    .rd1     (srca),
    .rd2     (writedata));
	 
// wrmux modified mux2 to mux3
/*
  mux2 #(5) wrmux(
    .d0  (instr[20:16]),
    .d1  (instr[15:11]),
    .s   (regdst[1]),
    .y   (writereg));
*/
  mux3 #(5) wrmux(
    .d0  (instr[20:16]),
    .d1  (instr[15:11]),
	 .d2  (5'b11111),
    .s   (regdst[1:0]),
    .y   (writereg));

	 
// resmux modified mux2 to mux3	 
/*
  mux2 #(32) resmux(
    .d0 (aluout),
    .d1 (readdata),
    .s  (memtoreg[1]),
    .y  (result));
*/
  mux3 #(32) resmux(
    .d0 (aluout),
	 .d1 (readdata),
	 .d2 (pcplus4),
	 .s  (memtoreg[1:0]),
	 .y  (result));

  sign_zero_ext sze(
    .a       (instr[15:0]),
    .signext (signext),
    .y       (signimm[31:0]));

  shift_left_16 sl16(
    .a         (signimm[31:0]),
    .shiftl16  (shiftl16),
    .y         (shiftedimm[31:0]));

  // ALU logic
  mux2 #(32) srcbmux(
    .d0 (writedata),
    .d1 (shiftedimm[31:0]),
    .s  (alusrc),
    .y  (srcb));

  alu alu(
    .a       (srca),
    .b       (srcb),
    .alucont (alucontrol),
    .result  (aluout),
    .zero    (zero));
    
endmodule
