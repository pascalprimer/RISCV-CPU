`include "defines.v"

module inst_rom(

	input wire ce,
	input wire[`InstAddrBus] addr,
	output reg[`InstBus] inst

);

	reg[`InstBus]  inst_mem[0:`InstMemNum-1];

//integer i;
	initial begin
		$readmemh ( "temp.data", inst_mem);
		//$display("mem0=%b",inst_mem[0]);
		/*for (i = 0; i < 5; i = i + 1) begin
			$display("%h %b\n", inst_mem[i], inst_mem[i]);
		end*/
	end
	
	always @ (*) begin
		if (ce == `ChipDisable) begin
			inst <= `ZeroWord;
		end else begin
			inst <= {
				inst_mem[addr[31:2]][7:0],
				inst_mem[addr[31:2]][15:8],
				inst_mem[addr[31:2]][23:16],
				inst_mem[addr[31:2]][31:24]
			};
		end
	end
	
	

endmodule
