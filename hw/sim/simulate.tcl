vcom -reportprogress 300 -work work ../hdl/TP/TP_pkg.vhd
vcom -reportprogress 300 -work work tb/tb_package.vhd
vcom -reportprogress 300 -work work ../hdl/TP/TP_generator.vhd
vcom -reportprogress 300 -work work ../hdl/TP/TP_buffer.vhd
vcom -reportprogress 300 -work work ../hdl/TP/TP_module.vhd
vcom -reportprogress 300 -work work tb/input.vhd
vcom -reportprogress 300 -work work tb/testbench.vhd
vsim work.tp_tb
add wave -position insertpoint sim:/tp_tb/*
add wave -position insertpoint sim:/tp_tb/TP_inst/*
add wave -position insertpoint sim:/tp_tb/TP_inst/TP_generator_inst/*
add wave -position insertpoint sim:/tp_tb/TP_inst/TP_buffer_inst/*
config wave -signalnamewidth 1
run -all
wave zoom full
