--Copyright (C) 1991-2011 Altera Corporation
--Your use of Altera Corporation's design tools, logic functions 
--and other software and tools, and its AMPP partner logic 
--functions, and any output files from any of the foregoing 
--(including device programming or simulation files), and any 
--associated documentation or information are expressly subject 
--to the terms and conditions of the Altera Program License 
--Subscription Agreement, Altera MegaCore Function License 
--Agreement, or other applicable license agreement, including, 
--without limitation, that your use is for the sole purpose of 
--programming logic devices manufactured by Altera and sold by 
--Altera or its authorized distributors.  Please refer to the 
--applicable agreement for further details.


FUNCTION linki_v10 
(
	pll_areset,
	rx_channel_data_align[8..0],
	rx_fifo_reset[8..0],
	rx_in[8..0],
	rx_inclock,
	rx_reset[8..0]
)

RETURNS (
	rx_dpa_locked[8..0],
	rx_locked,
	rx_out[35..0],
	rx_outclock
);
