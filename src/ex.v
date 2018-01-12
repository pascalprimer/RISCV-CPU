`include "defines.v"

module ex(

	input wire rst,
	
	input wire[`AluOpBus] aluop_i,
	input wire[`AluSelBus] alusel_i,
	input wire[`RegBus] reg1_i,
	input wire[`RegBus] reg2_i,
	input wire[`RegAddrBus] wd_i,
	input wire wreg_i,
	input wire[`RegBus] link_address_i,
	input wire[`RegBus] inst_i,
	input wire[`RegBus] offset_i,
	
	output reg[`RegAddrBus] wd_o,
	output reg wreg_o,
	output reg[`RegBus]	wdata_o,
	
	output wire[`AluOpBus] aluop_o,
	output wire[`RegBus] mem_addr_o,
	output wire[`RegBus] reg2_o,
	output reg stallreq //if is load or store now
);

	reg[`RegBus] logicout;
	assign aluop_o = aluop_i;
	assign mem_addr_o = offset_i + reg1_i;
	assign reg2_o = reg2_i;
	always @ (*) begin
		if(rst == `RstEnable) begin
			logicout <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_OR_OP:	begin
					logicout <= reg1_i | reg2_i;
				end
				`EXE_AND_OP: begin
					logicout <= reg1_i & reg2_i;
				end
				`EXE_XOR_OP:	begin
					logicout <= reg1_i ^ reg2_i;
				end
				default: begin
					logicout <= `ZeroWord;
				end
			endcase
		end    //if
	end      //always
	
	reg[`RegBus] shiftres;
	always @ (*) begin
		if(rst == `RstEnable) begin
			shiftres <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_SLL_OP:	begin
					shiftres <= reg1_i << reg2_i[4: 0];
				end
				`EXE_SRL_OP:	begin
					shiftres <= reg1_i >> reg2_i[4: 0];
				end
				`EXE_SRA_OP:	begin
					shiftres <= (reg1_i >> reg2_i[4: 0]) | ({32{reg1_i[31]}} << (6'd32 - {1'b0, reg2_i[4: 0]}));
				end
				default: begin
					shiftres <= `ZeroWord;
				end
			endcase
		end
	end
	
	reg[`RegBus] arithres;
	always @ (*) begin
		if(rst == `RstEnable) begin
			arithres <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_ADD_OP, `EXE_AUIPC_OP:	begin
					arithres <= reg1_i + reg2_i;
//$display("adder: reg1 = %h, reg2 = %h", reg1_i, reg2_i);
				end
				`EXE_SUB_OP:	begin
					arithres <= reg1_i - reg2_i;
				end
				`EXE_SLT_OP:	begin
					arithres <= $signed(reg1_i) < $signed(reg2_i);/*(((reg1_i[31] == 0) &&  (reg2_i[31] == 1)) || 
								((reg1_i[31] == reg2_i[31]) && (reg1_i[30: 0] < reg2_i[30: 0])));*/
				end
				`EXE_SLTU_OP:	begin
					arithres <= reg1_i < reg2_i;
				end
				default: begin
					arithres <= `ZeroWord;
				end
			endcase
		end
	end

	always @ (*) begin
		stallreq <= (alusel_i == `EXE_RES_LOAD_STORE);
		wd_o <= wd_i;	 	 	
		wreg_o <= wreg_i;
		case ( alusel_i ) 
			`EXE_RES_LOGIC:	begin
				wdata_o <= logicout;
			end
			`EXE_RES_SHIFT: begin
				wdata_o <= shiftres;
			end
			`EXE_RES_ARITHMETIC: begin
				wdata_o <= arithres;
			end
			`EXE_RES_JUMP_BRANCH: begin
				wdata_o <= link_address_i;
			end
			default: begin
				wdata_o <= `ZeroWord;
			end
		endcase
//$display("wdata_o = %h", wdata_o);
	end	

endmodule
