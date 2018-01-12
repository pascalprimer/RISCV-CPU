`include "defines.v"	

module data_ram(

	input wire clk,
	input wire pc_ce,
	input wire mem_ce,
	input wire we,
	input wire[`DataAddrBus] mem_addr,
	input wire[`InstAddrBus] pc_addr,
	input wire[3:0] sel,
	input wire who, //0: pc, 1: mem
	input wire[`DataBus] data_i, //litle-endian
	output reg[`DataBus] data_o,  //litle-endian
	output reg[31: 0] inst //instruction given to if_id
	
);
	
	reg[31: 0] data_mem[0: 100000];
	
		
	initial begin
		$readmemh ( "a.S", data_mem);
	end
	
	//pc
	always @ (*) begin
		if (pc_ce == `ChipDisable || who == 1'b1) begin
			inst <= `ZeroWord;
		end else begin
			inst <= {
				data_mem[pc_addr[31:2]][7:0],
				data_mem[pc_addr[31:2]][15:8],
				data_mem[pc_addr[31:2]][23:16],
				data_mem[pc_addr[31:2]][31:24]
			};
		end
	end
	
	//memory
	always @ (posedge clk) begin
		if (mem_ce == `ChipDisable || who == 1'b0) begin
			//data_o <= ZeroWord;
		end else if(we == `WriteEnable) begin
			if (sel[3] == 1'b1) begin
				//data_mem3[addr[31:2]] <= data_i[7: 0];
				data_mem[mem_addr[31: 2]][7: 0] <= data_i[7: 0];
//$display("write %h into mem[%h]", data_i[7: 0], {addr[31:2], 2'b11});
		    end
			if (sel[2] == 1'b1) begin
				//data_mem2[addr[31:2]] <= data_i[15: 8];
				data_mem[mem_addr[31: 2]][15: 8] <= data_i[15: 8];
//$display("write %h into mem[%h]", data_i[15: 8], {addr[31:2], 2'b10});
		    end
			if (sel[1] == 1'b1) begin
				//data_mem1[addr[31:2]] <= data_i[23: 16];
				data_mem[mem_addr[31: 2]][23: 16] <= data_i[23: 16];
//$display("write %h into mem[%h]", data_i[23: 16], {addr[31:2], 2'b01});
		    end
			if (sel[0] == 1'b1) begin
				//data_mem0[addr[31:2]] <= data_i[31: 24];
				data_mem[mem_addr[31: 2]][31: 24] <= data_i[31: 24];
//$display("write %h into mem[%h]", data_i[31: 24], {addr[31:2], 2'b00});
	//$display("%h %h", mem_addr[31: 2], data_i[31: 24]);
if (mem_addr[31: 2] == 7'b1000001) begin
	$display("%c", data_i[31: 24]);
end
				if (mem_addr[31: 2] == 7'b1000010 && data_i[31: 24] == 8'b11111111) begin
					$finish;
				end
		    end
		end
	end
	
	//read from mem
	always @ (*) begin
		if (mem_ce == `ChipDisable || who == 1'b0) begin
			data_o <= `ZeroWord;
		end else if(we == `WriteDisable) begin
		    /*data_o <= {data_mem0[addr[31:2]],
		               data_mem1[addr[31:2]],
		               data_mem2[addr[31:2]],
		               data_mem3[addr[31:2]]};*/
			data_o <= data_mem[mem_addr[31: 2]];
		end else begin
			data_o <= `ZeroWord;
		end
	end		

endmodule
