//全局
`define RstEnable 1'b1
`define RstDisable 1'b0
`define ZeroWord 32'h00000000
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define ReadEnable 1'b1
`define ReadDisable 1'b0
`define AluOpBus 7:0
`define AluSelBus 2:0
`define InstValid 1'b0
`define InstInvalid 1'b1
`define Stop 1'b1
`define NoStop 1'b0
`define InDelaySlot 1'b1
`define NotInDelaySlot 1'b0
`define Branch 1'b1
`define NotBranch 1'b0
`define InterruptAssert 1'b1
`define InterruptNotAssert 1'b0
`define TrapAssert 1'b1
`define TrapNotAssert 1'b0
`define True_v 1'b1
`define False_v 1'b0
`define ChipEnable 1'b1
`define ChipDisable 1'b0


`define EXE_ORI 6'b001101
`define EXE_NOP 6'b000000

//AluOp
 `define EXE_AND_OP 8'b10000001
  `define EXE_OR_OP 8'b10000010
 `define EXE_XOR_OP 8'b10000011
 `define EXE_ORI_OP 8'b10000100
`define EXE_XORI_OP 8'b10000101
 `define EXE_LUI_OP 8'b10000110   

 `define EXE_SLL_OP 8'b11000001
 `define EXE_SRL_OP 8'b11000011
 `define EXE_SRA_OP 8'b11000100

 `define EXE_SLT_OP  8'b11100001
`define EXE_SLTU_OP  8'b11100010
 `define EXE_ADD_OP  8'b11100011
 `define EXE_SUB_OP  8'b11100100
`define EXE_AUIPC_OP 8'b11100101


`define EXE_LB_OP  8'b11100110
`define EXE_LH_OP  8'b11100111
`define EXE_LW_OP  8'b11101000
`define EXE_LBU_OP 8'b11101001
`define EXE_LHU_OP 8'b11101010
`define EXE_SB_OP  8'b11101011
`define EXE_SH_OP  8'b11101100
`define EXE_SW_OP  8'b11101101

`define EXE_J  		6'b000010
`define EXE_JAL  	6'b000011
`define EXE_JALR  	6'b001001
`define EXE_JR  	6'b001000
`define EXE_BEQ  	6'b000100
`define EXE_BGEZ  	5'b00001
`define EXE_BGEZAL  5'b10001
`define EXE_BGTZ  	6'b000111
`define EXE_BLEZ  	6'b000110
`define EXE_BLTZ  	5'b00000
`define EXE_BLTZAL  5'b10000
`define EXE_BNE  	6'b000101

`define EXE_LB  6'b100000
`define EXE_LH  6'b100100
`define EXE_LW  6'b100001
`define EXE_LBU 6'b100101
`define EXE_LHU 6'b100011
`define EXE_SB  6'b100010
`define EXE_SH  6'b101000
`define EXE_SW  6'b101001
`define EXE_RES_LOAD_STORE 3'b111	
 `define EXE_NOP_OP 8'b11110001

//AluSel
`define EXE_RES_LOGIC 3'b001
`define EXE_RES_SHIFT 3'b010
`define EXE_RES_ARITHMETIC 3'b100
`define EXE_RES_JUMP_BRANCH 3'b110

`define EXE_RES_NOP 3'b000

//指令存储器inst_rom
`define InstAddrBus 	31:0
`define InstBus 		31:0
`define InstMemNum 		4096//131071
`define InstMemNumLog2 	17

`define DataAddrBus 	31:0
`define DataBus 		31:0
`define DataMemNum 		8096//131071
`define DataMemNumLog2 	17
`define ByteWidth 		7:0

//通用寄存器regfile
`define RegAddrBus 		4:0
`define RegBus 			31:0
`define RegWidth 		32
`define DoubleRegWidth 	64
`define DoubleRegBus 	63:0
`define RegNum 			32
`define RegNumLog2 		5
`define NOPRegAddr 		5'b00000
