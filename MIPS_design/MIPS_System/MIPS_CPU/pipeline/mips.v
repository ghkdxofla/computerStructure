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
            //output        memread,
            output [31:0] memaddr,
            output [31:0] memwritedata,
            input  [31:0] memreaddata);
  // ###### Taelim Hwang: Start #######
  wire        signext, shiftl16;
  // new
  wire [1:0]  branch;
  wire [1:0]  memtoreg;
  wire [1:0]  regdst;
  //wire        pcsrc;
  //wire [1:0]  zero;
  wire        alusrc, regwrite;
  wire [1:0]  jump;
  //wire [2:0]  alucontrol;
  //wire [1:0]  jrjump;
  // new
  // ###### Taelim Hwang: Start_3 #######

  wire [2:0]  aluop;
  // ###### Taelim Hwang: End_3 #######

  wire        memwrite_IN;
  wire        memread;
  wire [31:0] instr_ctrl;



  // Instantiate Controller
  controller c(
    .op         (instr_ctrl[31:26]),
		//.funct      (instr[5:0]),
		//.zero       (zero),
		.signext    (signext),
		.shiftl16   (shiftl16),
		.memtoreg   (memtoreg),
		.memwrite   (memwrite_IN),
    .memread    (memread),
		//.pcsrc      (pcsrc),
		.alusrc     (alusrc),
		.regdst     (regdst),
		.regwrite   (regwrite),
		.jump       (jump),
		//.alucontrol (alucontrol),
		//.jrjump     (jrjump),
    .aluop      (aluop),
    .branch     (branch));
    // ###### Taelim Hwang: End #######

  // ###### Taelim Hwang: Start #######
  // Instantiate Datapath
  datapath dp(
    .clk        (clk),
    .reset      (reset),
    .signext    (signext),
    .shiftl16   (shiftl16),
    .memtoreg_D   (memtoreg),
    //.pcsrc      (pcsrc),
    .alusrc_D     (alusrc),
    .regdst_D     (regdst),
    .regwrite_D   (regwrite),
    // ###### Taelim Hwang: Start_2 #######
    .jump_D       (jump),
    // ###### Taelim Hwang: End_2 #######

    //.alucontrol (alucontrol),
	  //.jrjump     (jrjump),

    .aluop_D      (aluop),
    //.zero       (zero),
    // new
    .branch_D     (branch),
    .memwrite_IN (memwrite_IN),
    .memread_D  (memread),
    .readdata_M  (memreaddata),
    .memwrite (memwrite),
    //.memread  (memread),
    .pc         (pc),
    .instr_F      (instr),
    .instr   (instr_ctrl),
    .aluout_M     (memaddr),
    .writedata  (memwritedata));
    //.readdata   (memreaddata));


    // ###### Taelim Hwang: End #######




endmodule
// ###### Taelim Hwang: Start #######

//IF-ID flip-flop
module ff_FD(input             clk, reset, stall,
             input      [31:0] pcplus4_F, //pcplus4 from adder
				     input      [31:0] instr_F, //instruction
             // ###### Taelim Hwang: Start_2 #######
             input pcsrc,
             input [1:0] jumps,
             // ###### Taelim Hwang: End_2 #######

			    	 output reg [31:0] pcplus4_D, instr);
  always@(posedge clk or posedge reset)
  begin
    if(reset) begin
	   pcplus4_D <= 32'b0;
		 instr <= 32'b0;
     end
     // ###### Taelim Hwang: Start_2 #######

	 else if(~stall && ~pcsrc &&jumps == 2'b00) begin
	    pcplus4_D <= pcplus4_F;
		  instr <= instr_F;
    end
    else if(stall) begin
      pcplus4_D<=pcplus4_D;
      instr <= instr;
    end
    else if(pcsrc || jumps == 2'b10 || jumps == 2'b01) begin
      pcplus4_D<=pcplus4_F;
      instr <= instr;
    end
      // ###### Taelim Hwang: End_2 #######


  end
endmodule
//ID-EX flip-flop

module ff_DE(input         clk, reset,
             input  [31:0] pcplus4_D, //pcplus4
				 input  [31:0] srca_D, //srca
				 input  [31:0] writedata_D, //writedata(read data2)
         // ###### Taelim Hwang: Start_3 #######
         input  [31:0] signimm_D,
         // ###### Taelim Hwang: End_3 #######
				 input  [31:0] shiftedimm_D, //signExtended, funct[31:26]
         input  [4:0]  instr_D25, //instruction[25:21]
				 input  [4:0]  instr_D20, //instruction[20:16]
				 input  [4:0]  instr_D15, //instruction[15:11]
         // ###### Taelim Hwang: Start_2 #######
         //jump_D added
         input [31:0] instr,
         // ###### Taelim Hwang: Start_3 #######

				 input  [7:0]  ex_D, //jump, alusrc, regdst, aluop 8bit
         // ###### Taelim Hwang: End_3 #######

         // ###### Taelim Hwang: End_2 #######
				 input  [3:0]  mem_D, //branch, memwrite, memread 4bit
				 input  [2:0]  wb_D, //memtoreg, regwrite 3bit
				 output reg [31:0] pcplus4_E,
				 output reg  [31:0] srca,
				 output reg  [31:0] writedata_E,
         // ###### Taelim Hwang: Start_3 #######
         output reg  [31:0] signimm,
         // ###### Taelim Hwang: End_3 #######

				 output reg  [31:0] shiftedimm,
         output reg  [4:0]  instr_25,
				 output reg  [4:0]  instr_20,
				 output reg  [4:0]  instr_15,
         // ###### Taelim Hwang: Start_2 #######
         output reg [31:0] instr_jump,
         output reg  [1:0]       jump,
         // ###### Taelim Hwang: End_2 #######

				 output reg         alusrc,
				 output reg  [1:0]  regdst,
         // ###### Taelim Hwang: Start_3 #######

				 output reg  [2:0]  aluop,
         // ###### Taelim Hwang: End_3 #######

				 output reg  [3:0]  mem_E,
				 output reg  [2:0]  wb_E);
  always@(posedge clk or posedge reset)
  begin
    if(reset) begin
	  pcplus4_E <= 32'b0;
		srca <= 32'b0;
		writedata_E <= 32'b0;
    // ###### Taelim Hwang: Start_3 #######
    signimm <= 32'b0;
    // ###### Taelim Hwang: End_3 #######
		shiftedimm <= 32'b0;
    instr_25 <= 5'b0;
		instr_20 <= 5'b0;
		instr_15 <= 5'b0;
    // ###### Taelim Hwang: Start_2 #######
    jump <= 2'b0;
    instr_jump <= 32'b0;
    // ###### Taelim Hwang: End_2 #######

		alusrc <= 1'b0;
		regdst <= 2'b00;
    // ###### Taelim Hwang: Start_3 #######

		aluop <= 3'b000;
    // ###### Taelim Hwang: End_3 #######

		mem_E <= 4'b0000;
		wb_E <= 3'b000;
    end
	 else begin
	  pcplus4_E <= pcplus4_D;
		srca <= srca_D;
		writedata_E <= writedata_D;
    // ###### Taelim Hwang: Start_3 #######
    signimm <= signimm_D;
    // ###### Taelim Hwang: End_3 #######
		shiftedimm <= shiftedimm_D;
    instr_25 <= instr_D25;
		instr_20 <= instr_D20;
		instr_15 <= instr_D15;
    // ###### Taelim Hwang: Start_2 #######
    // ###### Taelim Hwang: Start_3 #######

    jump <= ex_D[7:6];
    // ###### Taelim Hwang: End_3 #######

    instr_jump <= instr;
    // ###### Taelim Hwang: End_2 #######
    // ###### Taelim Hwang: Start_3 #######

		alusrc <= ex_D[5];
		regdst <= ex_D[4:3];
		aluop <= ex_D[2:0];
    // ###### Taelim Hwang: End_3 #######

		mem_E <= mem_D;
		wb_E <= wb_D;
    end
  end
endmodule
// ###### Taelim Hwang: Start_2 #######
module branch_adder(input zero,
                    input [1:0] branch,
                    output pcsrc);


  wire      bneorbeq;
  wire      iszero;

  assign iszero = ((branch[0] == 1'b0) ? zero : ~zero);
  assign bneorbeq = branch[1] & iszero;
  assign pcsrc = bneorbeq;

endmodule
// ###### Taelim Hwang: End_2 #######
module ff_EM(input         clk, reset,
				 input  [31:0] pcplus4_E, //pcplus4
         // ###### Taelim Hwang: Start_2 #######

         //input  [31:0] pcbranch_E, //pcbranch(add result)

				 //input        zero_E, //zero
         // ###### Taelim Hwang: End_2 #######

				 input  [31:0] aluout_E, //alu result
				 input  [31:0] writedata_E, //writedata(read data2)
				 input  [4:0] writereg_E, //from wrmux
				 input  [3:0]  mem_E, //branch, memwrite, memread 4bit
				 input  [2:0]  wb_E, //memtoreg, regwrite 3bit
				 output reg  [31:0] pcplus4_M,
         // ###### Taelim Hwang: Start_2 #######

				 //output reg  [31:0] pcbranch,
         // ###### Taelim Hwang: End_2 #######

				 output reg  [31:0] aluout_M,
				 output reg  [31:0] writedata,
				 output reg  [4:0] writereg_M,
         // ###### Taelim Hwang: Start_2 #######

				 //output             pcsrc,
         // ###### Taelim Hwang: End_2 #######

				 output reg         memwrite,
				 output reg         memread,
				 output reg  [2:0]  wb_M);
 // ###### Taelim Hwang: Start_2 #######
//move to ex stage
  //wire      bneorbeq;
  //wire      iszero;
  //reg       zero;

  //reg [1:0] branch;
  // ###### Taelim Hwang: End_2 #######

  always@(posedge clk or posedge reset)
  begin
    if(reset) begin
	   pcplus4_M <= 32'b0;
     // ###### Taelim Hwang: Start_2 #######

		//pcbranch <= 32'b0;
    //zero <= 1'b0;
    // ###### Taelim Hwang: End_2 #######


		aluout_M <= 32'b0;
		writedata <= 32'b0;
		writereg_M <= 4'b0;
    // ###### Taelim Hwang: Start_2 #######

		//branch <= 2'b00;
    // ###### Taelim Hwang: End_2 #######

		memwrite <= 1'b0;
		memread <= 1'b0;
		wb_M <= 3'b000;
    end
	 else begin
	   pcplus4_M <= pcplus4_E;
     // ###### Taelim Hwang: Start_2 #######

		//pcbranch <= pcbranch_E;

		//zero <= zero_E;
    // ###### Taelim Hwang: End_2 #######

		aluout_M <= aluout_E;
		writedata <= writedata_E;
		writereg_M <= writereg_E;
    // ###### Taelim Hwang: Start_2 #######

		//branch <= mem_E[3:2];
    // ###### Taelim Hwang: End_2 #######

		memwrite <= mem_E[1];
		memread <= mem_E[0];
		wb_M <= wb_E;
    end
  end
  //delay를 줘야하나...?
  // ###### Taelim Hwang: Start_2 #######
  // move to ex stage
  //assign iszero = ((branch[0] == 1'b0) ? zero : ~zero);
  //assign bneorbeq = branch[1] & iszero;
  //assign pcsrc = bneorbeq;
  // ###### Taelim Hwang: End_2 #######


endmodule

module ff_MW(input         clk, reset,
             input  [31:0] pcplus4_M, //pcplus4
				 input  [31:0] readdata_M, //readdata (from data memory read data)
				 input  [31:0] aluout_M, //alu result
				 input  [4:0] writereg_M, //from wrmux
				 input  [2:0]  wb_M, //memtoreg, regwrite 3bit
				 output reg  [31:0] pcplus4,
				 output reg  [31:0] readdata,
				 output reg  [31:0] aluout,
				 output reg  [4:0] writereg,
				 output reg  [1:0]  memtoreg,
				 output reg         regwrite);
  always@(posedge clk or posedge reset)
  begin
    if(reset) begin
	   pcplus4 <= 32'b0;
      readdata <= 32'b0;
		aluout <= 32'b0;
		writereg <= 4'b0;
		memtoreg <= 2'b00;
		regwrite <= 1'b0;
    end
	 else begin
	   pcplus4 <= pcplus4_M;
      readdata <= readdata_M;
		aluout <= aluout_M;
		writereg <= writereg_M;
		memtoreg <= wb_M[2:1];
		regwrite <= wb_M[0];
    end
  end
endmodule

module forwarding(input [4:0] instr_D25,
                  input [4:0] instr_D20,
                  input [4:0] instr_E25,
                  input [4:0] instr_E20,
                  input [4:0] writereg_M,
                  input [4:0] writereg_W,
                  input       regwrite_M,
                  input       regwrite_W,
                  output [1:0]forward_rd1,
                  output [1:0]forward_rd2,
                  output reg     forward_dw1,
                  output reg     forward_dw2);
//working in progress
reg  forward_1a;
reg  forward_0a;
reg  forward_1b;
reg  forward_0b;
assign forward_rd1 = {forward_1a, (~forward_1a & forward_0a)};
assign forward_rd2 = {forward_1b, (~forward_1b & forward_0b)};

always @(*)
begin
  if(regwrite_M == 1'b1 && writereg_M != 5'b00000 && writereg_M == instr_E25) begin
    forward_1a = 1'b1;
  end
  else begin
    forward_1a = 1'b0;
  end
  if(regwrite_W == 1'b1 && writereg_W != 5'b00000 && writereg_W == instr_E25) begin
    forward_0a = 1'b1;
  end
  else begin
    forward_0a = 1'b0;
  end
  if(regwrite_M == 1'b1 && writereg_M != 5'b00000 && writereg_M == instr_E20) begin
    forward_1b = 1'b1;
  end
  else begin
    forward_1b = 1'b0;
  end
  if(regwrite_W == 1'b1 && writereg_W != 5'b00000 && writereg_W == instr_E20) begin
    forward_0b = 1'b1;
  end
  else begin
    forward_0b = 1'b0;
  end

  //d-w forwarding
  if(regwrite_W == 1'b1 && writereg_W != 5'b00000 && writereg_W == instr_D25) begin
    forward_dw1 = 1'b1;
  end
  else begin
    forward_dw1 = 1'b0;
  end
  if(regwrite_W == 1'b1 && writereg_W != 5'b00000 && writereg_W == instr_D20) begin
    forward_dw2 = 1'b1;

  end
  else begin
    forward_dw2 = 1'b0;

  end
end



endmodule

//Hazard Detection Unit
module hdu(input [4:0] instr_D25, // D stage rs
           input [4:0] instr_D20, // D stage rt
           input [4:0] instr_E20, // E stage rt
           input       memread_E, // E stage memread
           output reg  stall);         // stall signals

  always @(memread_E or instr_E20 or instr_D20 or instr_D25)
  begin
    if(memread_E && ((instr_E20 == instr_D25 )|| (instr_E20 == instr_D20))) begin
	   stall = 1'b1;
    end
	 else begin
	   stall = 1'b0;
    end
  end

endmodule
// ###### Taelim Hwang: End #######

module controller(input  [5:0] op, //funct,
                  // ###### Taelim Hwang: Start #######
                  //input        zero,
                  output       signext,
                  output       shiftl16,
                  output [1:0] memtoreg,
						      output       memwrite,
                  output       memread,
                  //output       pcsrc,
                  output       alusrc,
                  output [1:0] regdst,
						      output       regwrite,
                  output [1:0] jump,
                  //output [2:0] alucontrol,
						      //output [1:0] jrjump,
                  // ###### Taelim Hwang: Start_3 #######

                  output [2:0] aluop,
                  // ###### Taelim Hwang: End_3 #######

                  output [1:0] branch);
// ###### Taelim Hwang: End #######
  //wire [1:0] aluop;
  //wire       branch;
  // ###### Taelim Hwang: Start #######
  maindec md(
    .op       (op),
    .signext  (signext),
    .shiftl16 (shiftl16),
    .memtoreg (memtoreg),
    .memwrite (memwrite),
    .memread  (memread),
    .branch   (branch),
    .alusrc   (alusrc),
    .regdst   (regdst),
    .regwrite (regwrite),
    .jump     (jump),
    .aluop    (aluop));

  //single cycle -> pipeline
  //aludec은 flip-flop 구조를 위해 datapath 안으로 옮겨짐.
  //aludec ad(
  //  .funct      (funct),
  //  .aluop      (aluop),
  //  .alucontrol (alucontrol),
	//  .jrjump     (jrjump));

  //single cycle -> pipeline
  //assign pcsrc = branch & (op == 6'b000100 ? zero : ~zero);
  //move to alu result
  // ###### Taelim Hwang: End #######

endmodule

// ###### Taelim Hwang: Start #######
// change control signals(bind multiple signals to three big signal wires)
// pipeline에서는 분리된 controller, alu controller 때문에 branch로 beq, bne를
// 구별합니다. 이 때, 00이면 branch X, 10면 beq, 11면 bne 입니다.
module maindec(input  [5:0] op,
               output       signext,
               output       shiftl16,
               output [1:0] memtoreg,
					     output       memwrite,
               output       memread,
               output [1:0] branch,
               output       alusrc,
               output [1:0] regdst,
				       output       regwrite,
               output [1:0] jump,
               // ###### Taelim Hwang: Start_3 #######

               output [2:0] aluop);
               // ###### Taelim Hwang: End_3 #######

 // ###### Taelim Hwang: Start_3 #######

  reg [16:0] controls;
  // ###### Taelim Hwang: End_3 #######

  assign {signext, shiftl16, regwrite, regdst, alusrc, branch, memwrite, memread,
          memtoreg, jump, aluop} = controls;

  always @(*)
    case(op)                             //123445667899aabbb
      6'b000000: controls <= #`mydelay 17'b00110000000000111; // Rtype
      6'b100011: controls <= #`mydelay 17'b10100100011000000; // LW
      6'b101011: controls <= #`mydelay 17'b10000100100000000; // SW
      6'b000101: controls <= #`mydelay 17'b10000011000000001; // BNE
      6'b000100: controls <= #`mydelay 17'b10000010000000001; // BEQ
      6'b001000,
      6'b001001: controls <= #`mydelay 17'b10100100000000000; // ADDI, ADDIU: only difference is exception
      6'b001101: controls <= #`mydelay 17'b00100100000000010; // ORI
      6'b001111: controls <= #`mydelay 17'b01100100000000000; // LUI
      6'b000010: controls <= #`mydelay 17'b00000000000010000; // J
		  6'b000011: controls <= #`mydelay 17'b00101000000110000; // JAL
      // ###### Taelim Hwang: Start_3 #######

      6'b001010: controls <= #`mydelay 17'b10100100000000011; // SLTI
      // ###### Taelim Hwang: End_3 #######

      default:   controls <= #`mydelay 17'bxxxxxxxxxxxxxxxxx; // ???
    endcase

endmodule


// Add JR signal
module aludec(input      [5:0] funct,
              // ###### Taelim Hwang: Start_3 #######

              input      [2:0] aluop,
              // ###### Taelim Hwang: End_3 #######

              output     [2:0] alucontrol,
				  output     [1:0] jrjump);

  reg [4:0] controls;

  assign {alucontrol, jrjump} = controls;
  //assign jrjump = (funct == 6'b001000 ? 2'b01 : 2'b00);
  always @(*)
  begin


    case(aluop)
    // ###### Taelim Hwang: Start_3 #######

      3'b000: controls <= #`mydelay 5'b01000;  // add
      3'b001: controls <= #`mydelay 5'b11000;  // sub
      3'b010: controls <= #`mydelay 5'b00100;  // or
      //new instruction
      3'b011: controls <= #`mydelay 5'b11100; // slt
      // ###### Taelim Hwang: End_3 #######

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
          // ###### Taelim Hwang: Start_2 #######

          default:   controls <= #`mydelay 5'bxxx00; // ??? / JR default : 00
          // ###### Taelim Hwang: End_2 #######

        endcase
    endcase
  end


endmodule
// ###### Taelim Hwang: End #######

// ###### Taelim Hwang: Start #######
module datapath(input         clk, reset,
                input         signext,
                input         shiftl16,
                input  [1:0]  memtoreg_D,
				      	//input         pcsrc,
                input         alusrc_D,
			      		input  [1:0]  regdst_D,
                input         regwrite_D,
                // ###### Taelim Hwang: Start_2 #######
				      	input  [1:0]  jump_D,
                // ###### Taelim Hwang: End_2 #######
                //input  [2:0]  alucontrol,
                // ###### Taelim Hwang: Start_3 #######

                input [2:0]  aluop_D,
                // ###### Taelim Hwang: Start_3 #######

				      	//input  [1:0]  jrjump,
                //output [1:0]  zero,
                // new start
                input  [1:0]  branch_D,
                input         memwrite_IN,
                input         memread_D,
                input  [31:0]  readdata_M,
                output        memwrite,
                //output        memread,


                // end
                output [31:0] pc,
                // change start
                input  [31:0] instr_F,
                output [31:0] instr,
                // end
                output [31:0] aluout_M, writedata);
                //input  [31:0] readdata);
  // ###### Taelim Hwang: End #######
  // ###### Taelim Hwang: Start #######
  // ###### Taelim Hwang: Start_2 #######
  //jump_D added
  // ###### Taelim Hwang: Start_3 #######

  reg [7:0]  ex_D;
  // ###### Taelim Hwang: End_3 #######

  // ###### Taelim Hwang: End_2 #######
  reg [3:0]  mem_D;
  reg [2:0]  wb_D;
  // ###### Taelim Hwang: Start_3 #######

  wire [14:0] control_signal_IN;
  wire [14:0] control_signal_OUT;
  // ###### Taelim Hwang: Start_3 #######

  wire        stall;
  wire [31:0] srca_pp, srcb_pp;
  wire [1:0] forward_rd1, forward_rd2;
  // ###### Taelim Hwang: Start_2 #######
  //jump_D added
  assign control_signal_IN = {jump_D, alusrc_D, regdst_D, aluop_D,
                         branch_D, memwrite_IN, memread_D,
                         memtoreg_D, regwrite_D};
  // ###### Taelim Hwang: End_2 #######

  always@(*)
  begin
    if (reset) begin
      // ###### Taelim Hwang: Start_2 #######

      ex_D <= 8'b0;
      // ###### Taelim Hwang: End_2 #######

    //memwrite, memread는 mips에서 외부의 ram으로 보내는 signal이다
    //port 만들어주기
      mem_D <= 4'b0;

      wb_D = 3'b0;
      end
      else begin
      // ###### Taelim Hwang: Start_2 #######
      // ###### Taelim Hwang: Start_3 #######

      ex_D <= #`mydelay  control_signal_OUT[14:7];
      // ###### Taelim Hwang: End_3 #######

      // ###### Taelim Hwang: End_2 #######

    //memwrite, memread는 mips에서 외부의 ram으로 보내는 signal이다
    //port 만들어주기
      mem_D <= #`mydelay  control_signal_OUT[6:3];

      wb_D <= #`mydelay  control_signal_OUT[2:0];
      end
  end
  // ###### Taelim Hwang: End #######
  wire [4:0]  writereg;
  wire [31:0] pcnext, pcnextbr, pcplus4, pcbranch;
  // ###### Taelim Hwang: Start_3 #######
  wire [31:0] signimm_D;
  // ###### Taelim Hwang: End_3 #######

  wire [31:0] signimm, signimmsh, shiftedimm;
  wire [31:0] srca, srcb;
  wire [31:0] result;
  wire        shift;

  // ###### Taelim Hwang: Start #######
  wire [2:0]  alucontrol;
  wire [1:0]  jrjump;
  wire [1:0]  memtoreg;
  wire        pcsrc;
  // ###### Taelim Hwang: Start_2 #######
  wire [1:0]  jump;
  // ###### Taelim Hwang: End_2 #######

  wire        alusrc;
  wire [1:0]  regdst;
  wire        regwrite;
  //wire        zero;
  // ###### Taelim Hwang: Start_3 #######

  wire [2:0]  aluop;
  // ###### Taelim Hwang: End_3 #######

  wire        memread;
  wire [31:0] srca_OUT;
  wire [31:0] writedata_OUT;

  wire       forward_dw1;
  wire       forward_dw2;
  //################# IF-ID ##################
  //input wire
  wire [31:0] pcplus4_F;
  //instr_F is not needed because input already has this port.
  //output wire
  wire [31:0] pcplus4_D;
  //wire [31:0] instr;


  ff_FD fd(
    .clk       (clk),
    .reset     (reset),
    .stall     (stall),
    // ###### Taelim Hwang: Start_2 #######
    .pcsrc     (pcsrc),
    .jumps     ({jump[1], jrjump[0]}),
    // ###### Taelim Hwang: End_2 #######

    .pcplus4_F (pcplus4_F),
    .instr_F   (instr_F),
    //#######################################################
    .pcplus4_D (pcplus4_D),
    .instr     (instr));


  //################# ID-EX ##################
  //input
  wire [31:0] srca_D;
  wire [31:0] writedata_D;
  wire [31:0] shiftedimm_D;
  //instr_D20, instr_D15 are not needed.
  //wire [4:0]  ex_D;
  //wire [3:0]  mem_D;
  //wire [2:0]  wb_D;
  //output
  wire [31:0] pcplus4_E;
  wire [31:0] writedata_E;
  wire [4:0]  instr_25;
  wire [4:0]  instr_20;
  wire [4:0]  instr_15;
  // ###### Taelim Hwang: Start_2 #######
  wire [31:0] instr_jump;
  // ###### Taelim Hwang: End_2 #######

  wire [3:0]  mem_E;
  wire [2:0]  wb_E;


  ff_DE de(
    .clk (clk),
    .reset (reset),
    .pcplus4_D (pcplus4_D),
    .srca_D (srca_D),
    .writedata_D (writedata_D),
    // ###### Taelim Hwang: Start_3 #######
    .signimm_D (signimm_D),
    // ###### Taelim Hwang: End_3 #######

    .shiftedimm_D (shiftedimm_D),
    .instr_D25 (instr[25:21]),
    .instr_D20 (instr[20:16]),
    .instr_D15 (instr[15:11]),
    // ###### Taelim Hwang: Start_2 #######
    .instr (instr),
    // ###### Taelim Hwang: End_2 #######

    .ex_D (ex_D),
    .mem_D (mem_D), //branch, memwrite, memread 4bit
    .wb_D (wb_D), //memtoreg, regwrite 3bit
    //########################################################
    .pcplus4_E (pcplus4_E),
    .srca (srca),
    .writedata_E (writedata_E),
    // ###### Taelim Hwang: Start_3 #######
    .signimm (signimm),
    // ###### Taelim Hwang: End_3 #######

    .shiftedimm (shiftedimm),
    .instr_25 (instr_25),
    .instr_20 (instr_20),
    .instr_15 (instr_15),
    // ###### Taelim Hwang: Start_2 #######

    .instr_jump (instr_jump),
    .jump (jump),
    // ###### Taelim Hwang: End_2 #######

    .alusrc (alusrc),
    .regdst (regdst),
    .aluop (aluop),
    .mem_E (mem_E),
    .wb_E (wb_E));


  //################# EX-MEM ##################
  //input
  // ###### Taelim Hwang: Start_2 #######

  //wire [31:0] pcbranch_E;
  // ###### Taelim Hwang: End_2 #######

  wire       zero_E;
  wire [31:0] aluout_E;
  wire [4:0]  writereg_E;
  //output
  wire [31:0] pcplus4_M;
  //wire [31:0] aluout_M;
  wire [31:0] aluout;
  wire [4:0]  writereg_M;
  wire [2:0]  wb_M;





  ff_EM em(
    .clk (clk),
    .reset (reset),
    .pcplus4_E (pcplus4_E), //pcplus4
    // ###### Taelim Hwang: Start_2 #######
    //.pcbranch_E (pcbranch_E), //pcbranch(add result)
    //.zero_E (zero_E), //zero

    // ###### Taelim Hwang: End_2 #######

    .aluout_E (aluout_E), //alu result
    .writedata_E (srcb_pp), //writedata(read data2)
    .writereg_E (writereg_E), //from wrmux
    .mem_E (mem_E), //branch, memwrite, memread 4bit
    .wb_E (wb_E), //memtoreg, regwrite 3bit
    //########################################################
    .pcplus4_M (pcplus4_M),
    // ###### Taelim Hwang: Start_2 #######

    //.pcbranch (pcbranch),
    //.pcsrc (pcsrc),
    // ###### Taelim Hwang: End_2 #######

    .aluout_M (aluout_M),
    .writedata (writedata),
    .writereg_M (writereg_M),


    //memwrite, memread는 mips에서 외부의 ram으로 보내는 signal이다
    .memwrite (memwrite),
    .memread (memread),
    .wb_M (wb_M));


  //################# MEM-WB ##################
  //input

  //output
  wire [31:0] readdata;
  // memrdmux를 위한 wire
  wire [31:0] readdata_OUT;


  ff_MW mw(
    .clk (clk),
    .reset (reset),
    .pcplus4_M (pcplus4_M), //pcplus4
    //mips 의 memreaddata임.
    .readdata_M (readdata_OUT), //readdata (from data memory read data)

    .aluout_M (aluout_M), //alu result
    .writereg_M (writereg_M), //from wrmux
    .wb_M (wb_M), //memtoreg, regwrite 3bit
    //############################################################
    .pcplus4 (pcplus4),
    .readdata (readdata),
    .aluout (aluout),
    .writereg (writereg),
    .memtoreg (memtoreg),
    .regwrite (regwrite));


  // ###### Taelim Hwang: End #######
  // next PC logic
  flopr #(32) pcreg(
    .clk   (clk),
    .reset (reset),
    .stall (stall),

    .d     (pcnext),
    .q     (pc));

  adder pcadd1(
    .a (pc),
    .b (32'b100),
    .y (pcplus4_F));
//수정중
  sl2 immsh(
    .a (signimm),
    .y (signimmsh));

  adder pcadd2(
    .a (pcplus4_E),
    .b (signimmsh),
    .y (pcbranch));
    // ###### Taelim Hwang: Start_2 #######

    //.y (pcbranch_E));
    // ###### Taelim Hwang: End_2 #######


  mux2 #(32) pcbrmux(
    .d0  (pcplus4_F),
    .d1  (pcbranch),
    .s   (pcsrc),
    .y   (pcnextbr));
// pcmux modified mux2 to mux3

// ###### Taelim Hwang: Start #######

  mux3 #(32) pcmux(
    .d0   (pcnextbr),
    .d1   ({pcplus4_E[31:28], instr_jump[25:0], 2'b00}), // 수정
	  .d2   (srca_pp),
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
    .rd1     (srca_OUT),
    .rd2     (writedata_OUT));

// wrmux modified mux2 to mux3
/*
  mux2 #(5) wrmux(
    .d0  (instr[20:16]),
    .d1  (instr[15:11]),
    .s   (regdst[1]),
    .y   (writereg));
*/
  mux3 #(5) wrmux(
    .d0  (instr_20),
    .d1  (instr_15),
	 .d2  (5'b11111),
    .s   (regdst[1:0]),
    .y   (writereg_E));


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
// ###### Taelim Hwang: End #######
// ###### Taelim Hwang: Start_3 #######

  sign_zero_ext sze(
    .a       (instr[15:0]),
    .signext (signext),
    .y       (signimm_D[31:0]));
    // ###### Taelim Hwang: End_3 #######

// ###### Taelim Hwang: Start #######
  shift_left_16 sl16(
    // ###### Taelim Hwang: Start_3 #######

    .a         (signimm_D[31:0]),
    // ###### Taelim Hwang: End_3 #######

    .shiftl16  (shiftl16),
    .y         (shiftedimm_D[31:0]));

  // ALU logic
  mux2 #(32) srcbmux(
    .d0 (srcb_pp),
    .d1 (shiftedimm[31:0]),
    .s  (alusrc),
    .y  (srcb));

  alu alu(
    .a       (srca_pp),
    .b       (srcb),
    .alucont (alucontrol),
    .result  (aluout_E),
    .zero    (zero_E));
  // pipelined forwarding
  forwarding fwd(
    .instr_E25 (instr_25),
    .instr_E20 (instr_20),
    .instr_D25 (instr[25:21]),
    .instr_D20 (instr[20:16]),
    .writereg_M (writereg_M),
    .writereg_W (writereg),
    .regwrite_M (wb_M[0]),
    .regwrite_W (regwrite),
    .forward_rd1 (forward_rd1),
    .forward_rd2 (forward_rd2),
    .forward_dw1 (forward_dw1),
    .forward_dw2 (forward_dw2));
  // Pipelined alu mux
  mux3 #(32) fwdamux(
    .d0 (srca),
    .d1 (aluout_M),
    .d2 (result),
    .s (forward_rd1),
    .y (srca_pp)
    );

  mux3 #(32) fwdbmux(
    .d0 (writedata_E),
    .d1 (aluout_M),
    .d2 (result),
    .s (forward_rd2),
    .y (srcb_pp)
    );

  // Pipelined alu contorller
  aludec ad(
    .funct      (shiftedimm[5:0]), //funct code를 따오는 개념이다
    .aluop      (aluop),
    .alucontrol (alucontrol),
	  .jrjump     (jrjump));
  // Hazard Detection Unit
  hdu hdu(
    .instr_D25 (instr[25:21]), // D stage rs
    .instr_D20 (instr[20:16]), // D stage rt
    .instr_E20 (instr_20), // E stage rt
    .memread_E (mem_E[0]), // E stage memread
    .stall (stall));
    // ###### Taelim Hwang: Start_3 #######

  // hdu mux
  mux2 #(15) hdumux(
    .d0 (control_signal_IN),
    .d1 (15'b0),
    .s  (stall),
    .y (control_signal_OUT));
    // ###### Taelim Hwang: End_3 #######


  // memread mux
  mux2 #(32) memrdmux(
    .d0 (32'b0),
    .d1 (readdata_M),
    .s (memread),
    .y (readdata_OUT));

    //wa-rd mux
    mux2 #(32) ward_1mux(
      .d0 (srca_OUT),
      .d1 (result),
      .s (forward_dw1),
      .y (srca_D)
      );

    //wa-rd2 mux
    mux2 #(32) ward_2mux(
      .d0 (writedata_OUT),
      .d1 (result),
      .s (forward_dw2),
      .y (writedata_D)
      );

      // ###### Taelim Hwang: Start_2 #######
    branch_adder branch_adder(
      .zero (zero_E),
      .branch (mem_E[3:2]),
      .pcsrc (pcsrc)
      );
      // ###### Taelim Hwang: End_2 #######




endmodule
// ###### Taelim Hwang: End #######
