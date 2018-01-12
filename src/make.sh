#!/bin/sh
iverilog -o mips openmips_min_sopc_tb.v openmips_min_sopc.v openmips.v mem_wb.v mem.v if_id.v id_ex.v id.v ex_mem.v ex.v regfile.v pc_reg.v ctrl.v data_ram.v
