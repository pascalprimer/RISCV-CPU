`include "defines.v"

module pc_reg(
	input wire clk,
	input wire rst,
	input wire[5: 0] stall,
	input wire branch_flag_i,
	input wire[`RegBus] branch_target_address_i,
	output reg[`InstAddrBus] pc,
	output reg ce,
	output reg artificial
);

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			ce <= `ChipDisable;
		end else begin
			ce <= `ChipEnable;
		end
	end
	always @ (posedge clk) begin
		artificial <= stall == 6'b000001;
		if (ce == `ChipDisable) begin
			pc <= 32'h00000000;
		end else if (stall[0] == `NoStop) begin
			if (branch_flag_i == `Branch) begin
				pc <= branch_target_address_i;
//$display("jump to %h", branch_target_address_i);
			end else begin
				pc <= 4'h4 + pc;
			end
		end
	end
	
endmodule
