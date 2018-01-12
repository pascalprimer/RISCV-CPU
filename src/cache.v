`include "defines.v"	

module cache_controller (
)

endmodule

module cache(
	input wire 			clk,
	input wire[31: 0] 	addr_i,
	input wire 			who, //0: pc, 1: mem
	input wire 			modify, //if to be modified
	input wire[7: 0]	data_i,
	
	output wire[31: 0]	pc_out,
	output wire[7: 0]	mem_out,
	
);
	reg[31: 0] data_mem[0:`DataMemNum-1];
	
	initial begin
		$readmemh ( "a.S", data_mem);
	end
	
	reg[21: 0] block[5 + 2 : 0];
	reg[7: 0] data[5 + 2: 0][5: 0];
	reg[1: 0] rand;
	reg[7: 0] i;
	
	initial begin
		rand = 0;
		for (i = 0; i < 8'b11111111; i = i + 1) begin
			block[i] = 22'b0;
		end
	end
	always @(posedge clk) begin
		rand = rand + 1'b1;
	end
	
	reg[5: 0] idx;
	reg[20: 0] real_tag;
	always @(*) begin
		idx <= addr_i[11: 6];
		real_tag <= addr_i[31: 12];
	end
	
	always @(*) begin
		if (block[{idx, 2'b00}][21] == 1'b1 && block[{idx, 2'b00}][19: 0] == real_tag) begin
			if (who == 1'b0) begin
				
			end else begin
			
			end
		end else if (block[{idx, 2'b00}][21] == 1'b1 && block[{idx, 2'b00}][19: 0] == real_tag) begin
			
		end else if (block[{idx, 2'b00}][21] == 1'b1 && block[{idx, 2'b00}][19: 0] == real_tag) begin
			
		end else if (block[{idx, 2'b00}][21] == 1'b1 && block[{idx, 2'b00}][19: 0] == real_tag) begin
			
		end else begin
		
		end
	end

endmodule
