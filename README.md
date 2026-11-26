# linting 
verilator --lint-only -Wall shift_reg.sv 

# simulating
verilator --binary --trace --top-module <tb_module_name> <design>.sv <tb>.sv