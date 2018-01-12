`include "defines.v"

module id(

	input wire rst,
	input wire[`InstAddrBus] pc_i,
	input wire[`InstBus] inst_i,

	input wire[`RegBus] reg1_data_i,
	input wire[`RegBus] reg2_data_i,
	input wire[`AluOpBus] ex_aluop_i,
	input wire[`AluOpBus] mem_aluop_i,
	
	input wire ex_wreg_i,
	input wire[`RegBus] ex_wdata_i,
	input wire[`RegAddrBus] ex_wd_i,
	
	input wire mem_wreg_i,
	input wire[`RegBus] mem_wdata_i,
	input wire[`RegAddrBus] mem_wd_i,
	
	output reg branch_flag_o,
	output reg[`RegBus] branch_target_address_o,
	output reg[`RegBus] link_addr_o,

	output reg                    reg1_read_o,
	output reg                    reg2_read_o,     
	output reg[`RegAddrBus]       reg1_addr_o,
	output reg[`RegAddrBus]       reg2_addr_o, 	      
	
	output reg[`AluOpBus]         aluop_o,
	output reg[`AluSelBus]        alusel_o,
	output reg[`RegBus]           reg1_o,
	output reg[`RegBus]           reg2_o,
	output reg[`RegAddrBus]       wd_o,
	output reg                    wreg_o,
	output reg[`RegBus] offset_o,
	
	output wire[`RegBus] inst_o,
	
	output wire                   stallreq
);
	//little-endian -> big-endian
	//inst_i = {{{inst_i[7, 0], inst_i[15, 8]}, inst_i[23, 16]}, inst_i[31, 24]};
	wire[6: 0] op = inst_i[6: 0];
	wire[2: 0] sub_op = inst_i[14:12];
	//assign stallreq = `NoStop;
	
	/*wire[5:0] op = inst_i[31:26];
	wire[4:0] op2 = inst_i[10:6];
	wire[5:0] op3 = inst_i[5:0];
	wire[4:0] op4 = inst_i[20:16];*/ 
	reg[`RegBus]	imm;
	reg instvalid;
	
	reg[`RegBus] reg1, reg2;
	reg stallreq_for_reg1_loadrelate;
	reg stallreq_for_reg2_loadrelate;
	wire ex_inst_is_load;
	wire mem_inst_is_load;
	assign ex_inst_is_load = ((ex_aluop_i == `EXE_LB_OP) || 
			  			      (ex_aluop_i == `EXE_LBU_OP)||
			  			      (ex_aluop_i == `EXE_LH_OP) ||
			  			      (ex_aluop_i == `EXE_LHU_OP)||
			  			      (ex_aluop_i == `EXE_LW_OP)) ? 1'b1 : 1'b0;
	assign mem_inst_is_load = ((mem_aluop_i == `EXE_LB_OP) || 
			  			      (mem_aluop_i == `EXE_LBU_OP)||
			  			      (mem_aluop_i == `EXE_LH_OP) ||
			  			      (mem_aluop_i == `EXE_LHU_OP)||
			  			      (mem_aluop_i == `EXE_LW_OP)) ? 1'b1 : 1'b0;
	assign inst_o = inst_i;
	always @ (*) begin
		if (rst == `RstEnable) begin
			reg1 <= `ZeroWord;
	  	end else if ((ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o) && ex_wd_i != 5'b0) begin
			reg1 <= ex_wdata_i;
		end else if ((mem_wreg_i == 1'b1) && (mem_wd_i == reg1_addr_o) && mem_wd_i != 5'b0) begin
			reg1 <= mem_wdata_i;		
		end else begin
	  		reg1 <= reg1_data_i;
	  	end
	end
	always @ (*) begin
		if (rst == `RstEnable) begin
			reg2 <= `ZeroWord;
	  	end else if ((ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o) && ex_wd_i != 5'b0) begin
			reg2 <= ex_wdata_i;
		end else if ((mem_wreg_i == 1'b1) && (mem_wd_i == reg2_addr_o) && mem_wd_i != 5'b0) begin
			reg2 <= mem_wdata_i;		
		end else begin
	  		reg2 <= reg2_data_i;
	  	end
	end
	
	always @ (*) begin	
		if (rst == `RstEnable) begin
			aluop_o <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
			instvalid <= `InstValid;
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= `NOPRegAddr;
			reg2_addr_o <= `NOPRegAddr;
			imm <= 32'h0;
			link_addr_o <= `ZeroWord;
			branch_target_address_o <= `ZeroWord;
			branch_flag_o <= `NotBranch;
		end else begin
//$display("%b %b %b\n", inst_i, op, sub_op);
			aluop_o <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			wd_o <= inst_i[11:7];	
			wreg_o <= `WriteDisable;
			instvalid <= `InstInvalid;	   
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= inst_i[19: 15];
			reg2_addr_o <= inst_i[24: 20];	
			imm <= `ZeroWord;
			link_addr_o <= `ZeroWord;
			branch_target_address_o <= `ZeroWord;
			branch_flag_o <= `NotBranch;
		  	case (op)
		  		7'b0000011: begin //load
		  			case (sub_op)
		  				3'b000: begin //LB
				  			wreg_o <= `WriteEnable;
							aluop_o <= `EXE_LB_OP;
							alusel_o <= `EXE_RES_LOAD_STORE;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;
							instvalid <= `InstValid;
							imm <= {{20{inst_i[31]}}, inst_i[31: 20]};
							offset_o <= {{20{inst_i[31]}}, inst_i[31: 20]};
		  				end
		  				3'b001: begin //LH
		  					wreg_o <= `WriteEnable;
							aluop_o <= `EXE_LH_OP;
							alusel_o <= `EXE_RES_LOAD_STORE;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;
							instvalid <= `InstValid;
							imm <= {{20{inst_i[31]}}, inst_i[31: 20]};
							offset_o <= {{20{inst_i[31]}}, inst_i[31: 20]};
		  				end
		  				3'b010: begin //LW
		  					wreg_o <= `WriteEnable;
							aluop_o <= `EXE_LW_OP;
							alusel_o <= `EXE_RES_LOAD_STORE;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;
							instvalid <= `InstValid;
							imm <= {{20{inst_i[31]}}, inst_i[31: 20]};
							offset_o <= {{20{inst_i[31]}}, inst_i[31: 20]};
		  				end
		  				3'b100: begin //LBU
		  					wreg_o <= `WriteEnable;
							aluop_o <= `EXE_LBU_OP;
							alusel_o <= `EXE_RES_LOAD_STORE;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;
							instvalid <= `InstValid;
							imm <= {{20{inst_i[31]}}, inst_i[31: 20]};
							offset_o <= {{20{inst_i[31]}}, inst_i[31: 20]};
		  				end
		  				3'b101: begin //LHU
		  					wreg_o <= `WriteEnable;
							aluop_o <= `EXE_LHU_OP;
							alusel_o <= `EXE_RES_LOAD_STORE;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;
							instvalid <= `InstValid;
							imm <= {{20{inst_i[31]}}, inst_i[31: 20]};
							offset_o <= {{20{inst_i[31]}}, inst_i[31: 20]};
		  				end
		  				default: begin
		  				end
		  			endcase
		  		end
		  		
		  		7'b0100011: begin
		  			case (sub_op)
		  				3'b000: begin //SB
				  			wreg_o <= `WriteDisable;
							aluop_o <= `EXE_SB_OP;
							alusel_o <= `EXE_RES_LOAD_STORE;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;
							instvalid <= `InstValid;
							imm <= {{20{inst_i[31]}}, inst_i[31: 25], inst_i[11: 7]};
							offset_o <= {{20{inst_i[31]}}, inst_i[31: 25], inst_i[11: 7]};
		  				end
		  				3'b001: begin //SH
		  					wreg_o <= `WriteDisable;
							aluop_o <= `EXE_SH_OP;
							alusel_o <= `EXE_RES_LOAD_STORE;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;
							instvalid <= `InstValid;
							imm <= {{20{inst_i[31]}}, inst_i[31: 25], inst_i[11: 7]};
							offset_o <= {{20{inst_i[31]}}, inst_i[31: 25], inst_i[11: 7]};
//$display("now SH:");
		  				end
		  				3'b010: begin //SW
		  					wreg_o <= `WriteDisable;
							aluop_o <= `EXE_SW_OP;
							alusel_o <= `EXE_RES_LOAD_STORE;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;
							instvalid <= `InstValid;
							imm <= {{20{inst_i[31]}}, inst_i[31: 25], inst_i[11: 7]};
							offset_o <= {{20{inst_i[31]}}, inst_i[31: 25], inst_i[11: 7]};
//$display("id when sw, %h, %h, %h", inst_i, op, inst_i[6: 0]);
		  				end
		  				default: begin
		  				end
		  			endcase
		  		end
		  	
		  		7'b1101111: begin //JAL
					wreg_o <= `WriteEnable;
					alusel_o <= `EXE_RES_JUMP_BRANCH;
					reg1_read_o <= 1'b0;
					reg2_read_o <= 1'b0;
					link_addr_o <= pc_i + 4;
					branch_target_address_o <= pc_i + {{12{inst_i[31]}}, inst_i[19: 12], inst_i[20], inst_i[30: 21], 1'b0};
					branch_flag_o <= `Branch;
					instvalid <= `InstValid;
					//stallreq <= `Stop;
		  		end
		  		
		  		7'b1100111: begin //JALR
		  			wreg_o <= `WriteEnable;
					alusel_o <= `EXE_RES_JUMP_BRANCH;
					reg1_read_o <= 1'b0;
					reg2_read_o <= 1'b0;
					link_addr_o <= pc_i + 4;
					branch_target_address_o <= (reg1_data_i + {{21{inst_i[31]}}, inst_i[30: 20]}) & ({31'b1, 1'b0});
					branch_flag_o <= `Branch;
					instvalid <= `InstValid;
					//stallreq <= `Stop;
		  		end
		  		
		  		7'b1100011: begin
		  			case (sub_op)
		  				3'b000: begin //BEQ
		  					wreg_o <= `WriteDisable;
							alusel_o <= `EXE_RES_JUMP_BRANCH;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;
							instvalid <= `InstValid;
							if (reg1 == reg2) begin
								branch_flag_o <= 1'b1;
								branch_target_address_o 
								<= pc_i+{{20{inst_i[31]}},inst_i[7],inst_i[30:25],inst_i[11:8],1'b0};
								//stallreq <= 1'b1;
							end
		  				end
		  				3'b001: begin //BNE
		  					wreg_o <= `WriteDisable;
							alusel_o <= `EXE_RES_JUMP_BRANCH;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;
							instvalid <= `InstValid;
							if (reg1 != reg2) begin
								branch_flag_o <= 1'b1;
								branch_target_address_o 
								<= pc_i+{{20{inst_i[31]}},inst_i[7],inst_i[30:25],inst_i[11:8],1'b0};
								//stallreq <= 1'b1;
							end
		  				end
		  				3'b100: begin //BLT
		  					wreg_o <= `WriteDisable;
							alusel_o <= `EXE_RES_JUMP_BRANCH;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;
							instvalid <= `InstValid;
							if ($signed(reg1) < $signed(reg2)) begin
								branch_flag_o <= 1'b1;
								branch_target_address_o 
								<= pc_i+{{20{inst_i[31]}},inst_i[7],inst_i[30:25],inst_i[11:8],1'b0};
								//stallreq <= 1'b1;
							end
		  				end
		  				3'b101: begin //BGE
		  					wreg_o <= `WriteDisable;
							alusel_o <= `EXE_RES_JUMP_BRANCH;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;
							instvalid <= `InstValid;
							if ($signed(reg1) >= $signed(reg2)) begin
								branch_flag_o <= 1'b1;
								branch_target_address_o 
								<= pc_i+{{20{inst_i[31]}},inst_i[7],inst_i[30:25],inst_i[11:8],1'b0};
								//stallreq <= 1'b1;
							end
//$display("test_bge: reg1(%d) = %h, reg2(%d) = %h", reg1_addr_o, reg1, reg2_addr_o, reg2);
		  				end
		  				3'b110: begin //BLTU
		  					wreg_o <= `WriteDisable;
							alusel_o <= `EXE_RES_JUMP_BRANCH;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;
							instvalid <= `InstValid;
							if (reg1 < reg2) begin
								branch_flag_o <= 1'b1;
								branch_target_address_o 
								<= pc_i+{{20{inst_i[31]}},inst_i[7],inst_i[30:25],inst_i[11:8],1'b0};
								//stallreq <= 1'b1;
							end
		  				end
		  				3'b111: begin //BGEU
		  					wreg_o <= `WriteDisable;
							alusel_o <= `EXE_RES_JUMP_BRANCH;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;
							instvalid <= `InstValid;
							if (reg1 >= reg2) begin
								branch_flag_o <= 1'b1;
								branch_target_address_o 
								<= pc_i+{{20{inst_i[31]}},inst_i[7],inst_i[30:25],inst_i[11:8],1'b0};
								//stallreq <= 1'b1;
							end
		  				end
		  			endcase
		  		end
		  		
				7'b0010011: begin
					case (sub_op)
						3'b000: begin //ADDI
							wreg_o <= `WriteEnable;
							aluop_o <= `EXE_ADD_OP;
							alusel_o <= `EXE_RES_ARITHMETIC;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;	 
							imm <= {{20{inst_i[31]}}, inst_i[31:20]}; 	
							instvalid <= `InstValid;
						end
						3'b001: begin //SLLI
							wreg_o <= `WriteEnable;
							aluop_o <= `EXE_SLL_OP;
							alusel_o <= `EXE_RES_SHIFT;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;	  	
							imm <= {27'h0, inst_i[24:20]};
							instvalid <= `InstValid;
						end
						3'b010: begin //SLTI
							wreg_o <= `WriteEnable;
							aluop_o <= `EXE_SLT_OP;
							alusel_o <= `EXE_RES_ARITHMETIC;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;	 
							imm <= {{20{inst_i[31]}}, inst_i[31:20]}; 	
							instvalid <= `InstValid;
						end
						3'b011: begin //SLTIU
							wreg_o <= `WriteEnable;
							aluop_o <= `EXE_SLTU_OP;
							alusel_o <= `EXE_RES_ARITHMETIC;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;	 
							imm <= {{20{inst_i[31]}}, inst_i[31:20]}; 	
							instvalid <= `InstValid;
						end
						3'b100: begin //XORI
							wreg_o <= `WriteEnable;
							aluop_o <= `EXE_XOR_OP;
							alusel_o <= `EXE_RES_LOGIC;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;	  	
							imm <= {{20{inst_i[31]}}, inst_i[31:20]};
							instvalid <= `InstValid;
						end
						3'b101: begin //addition check
							if (inst_i[30: 30] == 1'b0) begin //SRLI
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_SRL_OP;
								alusel_o <= `EXE_RES_SHIFT;
								reg1_read_o <= 1'b1;
								reg2_read_o <= 1'b0;	  	
								imm <= {27'h0, inst_i[24:20]};
								instvalid <= `InstValid;
							end else begin //SRAI
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_SRA_OP;
								alusel_o <= `EXE_RES_SHIFT;
								reg1_read_o <= 1'b1;
								reg2_read_o <= 1'b0;	  	
								imm <= {27'h0, inst_i[24:20]};
								instvalid <= `InstValid;
							end				
						end
						3'b110: begin //ORI
							wreg_o <= `WriteEnable;
							aluop_o <= `EXE_OR_OP;
							alusel_o <= `EXE_RES_LOGIC;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;	  	
							imm <= {{20{inst_i[31]}}, inst_i[31:20]};
							instvalid <= `InstValid;
//$display("ori: reg[%h](%h) + %h -> reg[%h]", reg1_addr_o, reg1, {{20{inst_i[31]}}, inst_i[31:20]}, wd_o);
						end
						3'b111: begin //ANDI
							wreg_o <= `WriteEnable;
							aluop_o <= `EXE_AND_OP;
							alusel_o <= `EXE_RES_LOGIC;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;	  	
							imm <= {{20{inst_i[31]}}, inst_i[31:20]};
							instvalid <= `InstValid;
						end
					endcase	
				end
				
				7'b0110011: begin
					case (sub_op)
						3'b000: begin //switch again
							if (inst_i[30] == 1'b0) begin
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_ADD_OP;
								alusel_o <= `EXE_RES_ARITHMETIC;
								reg1_read_o <= 1'b1;
								reg2_read_o <= 1'b1;	  	
								instvalid <= `InstValid;
							end else begin
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_SUB_OP;
								alusel_o <= `EXE_RES_ARITHMETIC;
								reg1_read_o <= 1'b1;
								reg2_read_o <= 1'b1;	  	
								instvalid <= `InstValid;
							end
						end
						3'b001: begin //SLL
							wreg_o <= `WriteEnable;
							aluop_o <= `EXE_SLL_OP;
							alusel_o <= `EXE_RES_SHIFT;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;	  	
							imm <= {27'h0, inst_i[24:20]};
							instvalid <= `InstValid;
						end
						3'b010: begin //SLT
							wreg_o <= `WriteEnable;
							aluop_o <= `EXE_SLT_OP;
							alusel_o <= `EXE_RES_ARITHMETIC;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;	  	
							instvalid <= `InstValid;
						end
						3'b011: begin //SLTU
							wreg_o <= `WriteEnable;
							aluop_o <= `EXE_SLTU_OP;
							alusel_o <= `EXE_RES_ARITHMETIC;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;	  	
							instvalid <= `InstValid;
						end
						3'b100: begin //XOR
							wreg_o <= `WriteEnable;
							aluop_o <= `EXE_XOR_OP;
							alusel_o <= `EXE_RES_LOGIC;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;	  	
							instvalid <= `InstValid;
						end
						3'b101: begin //addition check
							if (inst_i[30: 30] == 1'b0) begin //SRL
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_SRL_OP;
								alusel_o <= `EXE_RES_SHIFT;
								reg1_read_o <= 1'b1;
								reg2_read_o <= 1'b1;	  	
								instvalid <= `InstValid;
							end else begin //SRA
								wreg_o <= `WriteEnable;
								aluop_o <= `EXE_SRA_OP;
								alusel_o <= `EXE_RES_SHIFT;
								reg1_read_o <= 1'b1;
								reg2_read_o <= 1'b1;	  	
								instvalid <= `InstValid;
							end							
						end
						3'b110: begin //OR
							wreg_o <= `WriteEnable;
							aluop_o <= `EXE_OR_OP;
							alusel_o <= `EXE_RES_LOGIC;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;	  	
							instvalid <= `InstValid;
						end
						3'b111: begin //AND
							wreg_o <= `WriteEnable;
							aluop_o <= `EXE_AND_OP;
							alusel_o <= `EXE_RES_LOGIC;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;	  	
							instvalid <= `InstValid;
						end
					endcase	
				end
				
				7'b0110111: begin //LUI
					wreg_o <= `WriteEnable;
					aluop_o <= `EXE_OR_OP;
					alusel_o <= `EXE_RES_LOGIC;
					reg1_read_o <= 1'b0;
					reg2_read_o <= 1'b0;	  	
					imm <= {inst_i[31: 12], 12'b0};
					instvalid <= `InstValid;
				end
				
				7'b0010111: begin //AUIPC
					wreg_o <= `WriteEnable;
					aluop_o <= `EXE_AUIPC_OP;
					alusel_o <= `EXE_RES_ARITHMETIC;
					reg1_read_o <= 1'b0;
					reg2_read_o <= 1'b0;
					imm <= {inst_i[31: 12], 12'b0};
					instvalid <= `InstValid;
//$display("i am auipc: imm = %h", inst_i);
				end
				
				default: begin
				end
			endcase		  //case op
		end       //if
	end         //always
	

	always @ (*) begin
		stallreq_for_reg1_loadrelate <= `NoStop;
		if(rst == `RstEnable) begin
			reg1_o <= `ZeroWord;
	  	end else if (ex_inst_is_load == 1'b1 && ex_wd_i == reg1_addr_o && 
	  				reg1_read_o == 1'b1 && ex_wd_i != 5'b0 ||
	  				mem_inst_is_load == 1'b1 && mem_wd_i == reg1_addr_o && 
	  				reg1_read_o == 1'b1 && mem_wd_i != 5'b0) begin
	  		stallreq_for_reg1_loadrelate <= `Stop;
	  	end else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) && 
	  				(ex_wd_i == reg1_addr_o) && ex_wd_i != 5'b0) begin
			reg1_o <= ex_wdata_i; 
		end else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) && 
					(mem_wd_i == reg1_addr_o) && mem_wd_i != 5'b0) begin
			reg1_o <= mem_wdata_i; 			
		end else if(reg1_read_o == 1'b1) begin
	  		reg1_o <= reg1_data_i;
	  	end else if(reg1_read_o == 1'b0) begin
	  		if (aluop_o == `EXE_AUIPC_OP) begin
	  			reg1_o <= pc_i;
	  		end else reg1_o <= imm;
	  	end else begin
	    	reg1_o <= `ZeroWord;
	  	end
	end
	
	always @ (*) begin
		stallreq_for_reg2_loadrelate <= `NoStop;
		if(rst == `RstEnable) begin
			reg2_o <= `ZeroWord;
	  	end else if (ex_inst_is_load == 1'b1 && ex_wd_i == reg2_addr_o && 
	  				reg2_read_o == 1'b1 && ex_wd_i != 5'b0 ||
	  				mem_inst_is_load == 1'b1 && mem_wd_i == reg2_addr_o && 
	  				reg2_read_o == 1'b1 && mem_wd_i != 5'b0) begin
	  		stallreq_for_reg2_loadrelate <= `Stop;
	  	end else if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) && 
	  				(ex_wd_i == reg2_addr_o) && ex_wd_i != 5'b0) begin
			reg2_o <= ex_wdata_i; 
		end else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) && 
					(mem_wd_i == reg2_addr_o) && mem_wd_i != 5'b0) begin
			reg2_o <= mem_wdata_i; 			
		end else if(reg2_read_o == 1'b1) begin
	  		reg2_o <= reg2_data_i;
	  	end else if(reg2_read_o == 1'b0) begin
	  		reg2_o <= imm;
	 	end else begin
	    	reg2_o <= `ZeroWord;
	  	end
	end
	assign stallreq = stallreq_for_reg1_loadrelate |
						stallreq_for_reg2_loadrelate;
endmodule
