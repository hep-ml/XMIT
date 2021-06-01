// megafunction wizard: %ALTGX_RECONFIG%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: alt2gxb_reconfig 

// ============================================================
// File Name: recon.v
// Megafunction Name(s):
// 			alt2gxb_reconfig
//
// Simulation Library Files(s):
// 			altera_mf;lpm
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 9.1 Build 350 03/24/2010 SP 2 SJ Full Version
// ************************************************************


//Copyright (C) 1991-2010 Altera Corporation
//Your use of Altera Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Altera Program License 
//Subscription Agreement, Altera MegaCore Function License 
//Agreement, or other applicable license agreement, including, 
//without limitation, that your use is for the sole purpose of 
//programming logic devices manufactured by Altera and sold by 
//Altera or its authorized distributors.  Please refer to the 
//applicable agreement for further details.


//alt2gxb_reconfig CBX_AUTO_BLACKBOX="ALL" DEVICE_FAMILY="Arria II GX" ENABLE_BUF_CAL="TRUE" NUMBER_OF_CHANNELS=2 NUMBER_OF_RECONFIG_PORTS=1 RECONFIG_FROMGXB_WIDTH=17 RECONFIG_TOGXB_WIDTH=4 busy reconfig_clk reconfig_fromgxb reconfig_togxb
//VERSION_BEGIN 9.1SP2 cbx_alt2gxb_reconfig 2010:03:24:20:43:42:SJ cbx_alt_cal 2010:03:24:20:43:42:SJ cbx_alt_dprio 2010:03:24:20:43:42:SJ cbx_altsyncram 2010:03:24:20:43:42:SJ cbx_cycloneii 2010:03:24:20:43:43:SJ cbx_lpm_add_sub 2010:03:24:20:43:43:SJ cbx_lpm_compare 2010:03:24:20:43:43:SJ cbx_lpm_counter 2010:03:24:20:43:43:SJ cbx_lpm_decode 2010:03:24:20:43:43:SJ cbx_lpm_mux 2010:03:24:20:43:43:SJ cbx_lpm_shiftreg 2010:03:24:20:43:43:SJ cbx_mgl 2010:03:24:21:01:05:SJ cbx_stratix 2010:03:24:20:43:43:SJ cbx_stratixii 2010:03:24:20:43:43:SJ cbx_stratixiii 2010:03:24:20:43:43:SJ cbx_util_mgl 2010:03:24:20:43:43:SJ  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



//alt_dprio address_width=16 CBX_AUTO_BLACKBOX="ALL" device_family="Arria II GX" quad_address_width=9 address busy datain dataout dpclk dpriodisable dprioin dprioload dprioout quad_address rden reset wren wren_data
//VERSION_BEGIN 9.1SP2 cbx_alt_dprio 2010:03:24:20:43:42:SJ cbx_cycloneii 2010:03:24:20:43:43:SJ cbx_lpm_add_sub 2010:03:24:20:43:43:SJ cbx_lpm_compare 2010:03:24:20:43:43:SJ cbx_lpm_counter 2010:03:24:20:43:43:SJ cbx_lpm_decode 2010:03:24:20:43:43:SJ cbx_lpm_shiftreg 2010:03:24:20:43:43:SJ cbx_mgl 2010:03:24:21:01:05:SJ cbx_stratix 2010:03:24:20:43:43:SJ cbx_stratixii 2010:03:24:20:43:43:SJ  VERSION_END

//synthesis_resources = lpm_compare 3 lpm_counter 1 lpm_decode 1 lut 1 reg 102 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
(* ALTERA_ATTRIBUTE = {"{-to addr_shift_reg[31]} DPRIO_INTERFACE_REG=ON;{-to wr_out_data_shift_reg[31]} DPRIO_INTERFACE_REG=ON;{-to rd_out_data_shift_reg[13]} DPRIO_INTERFACE_REG=ON;{-to in_data_shift_reg[0]} DPRIO_INTERFACE_REG=ON;{-to startup_cntr[0]} DPRIO_INTERFACE_REG=ON;{-to startup_cntr[1]} DPRIO_INTERFACE_REG=ON;{-to startup_cntr[2]} DPRIO_INTERFACE_REG=ON"} *)
module  recon_alt_dprio_kuj
	( 
	address,
	busy,
	datain,
	dataout,
	dpclk,
	dpriodisable,
	dprioin,
	dprioload,
	dprioout,
	quad_address,
	rden,
	reset,
	wren,
	wren_data) /* synthesis synthesis_clearbox=2 */;
	input   [15:0]  address;
	output   busy;
	input   [15:0]  datain;
	output   [15:0]  dataout;
	input   dpclk;
	output   dpriodisable;
	output   dprioin;
	output   dprioload;
	input   dprioout;
	input   [8:0]  quad_address;
	input   rden;
	input   reset;
	input   wren;
	input   wren_data;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   [15:0]  datain;
	tri0   rden;
	tri0   reset;
	tri0   wren;
	tri0   wren_data;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	(* ALTERA_ATTRIBUTE = {"PRESERVE_REGISTER=ON;POWER_UP_LEVEL=LOW"} *)
	reg	[31:0]	addr_shift_reg;
	(* ALTERA_ATTRIBUTE = {"PRESERVE_REGISTER=ON;POWER_UP_LEVEL=LOW"} *)
	reg	[15:0]	in_data_shift_reg;
	(* ALTERA_ATTRIBUTE = {"PRESERVE_REGISTER=ON;POWER_UP_LEVEL=LOW"} *)
	reg	[15:0]	rd_out_data_shift_reg;
	wire	[2:0]	wire_startup_cntr_d;
	(* ALTERA_ATTRIBUTE = {"PRESERVE_REGISTER=ON;POWER_UP_LEVEL=LOW"} *)
	reg	[2:0]	startup_cntr;
	wire	[2:0]	wire_startup_cntr_ena;
	(* ALTERA_ATTRIBUTE = {"POWER_UP_LEVEL=LOW"} *)
	reg	[2:0]	state_mc_reg;
	(* ALTERA_ATTRIBUTE = {"PRESERVE_REGISTER=ON;POWER_UP_LEVEL=LOW"} *)
	reg	[31:0]	wr_out_data_shift_reg;
	wire  wire_pre_amble_cmpr_aeb;
	wire  wire_pre_amble_cmpr_agb;
	wire  wire_rd_data_output_cmpr_ageb;
	wire  wire_rd_data_output_cmpr_alb;
	wire  wire_state_mc_cmpr_aeb;
	wire  [5:0]   wire_state_mc_counter_q;
	wire  [7:0]   wire_state_mc_decode_eq;
	wire	wire_dprioin_mux_dataout;
	wire  busy_state;
	wire  idle_state;
	wire  rd_addr_done;
	wire  rd_addr_state;
	wire  rd_data_done;
	wire  rd_data_input_state;
	wire  rd_data_output_state;
	wire  rd_data_state;
	wire rdinc;
	wire  read_state;
	wire  s0_to_0;
	wire  s0_to_1;
	wire  s1_to_0;
	wire  s1_to_1;
	wire  s2_to_0;
	wire  s2_to_1;
	wire  startup_done;
	wire  startup_idle;
	wire  wr_addr_done;
	wire  wr_addr_state;
	wire  wr_data_done;
	wire  wr_data_state;
	wire  write_state;

	// synopsys translate_off
	initial
		addr_shift_reg = 0;
	// synopsys translate_on
	always @ ( posedge dpclk or  posedge reset)
		if (reset == 1'b1) addr_shift_reg <= 32'b0;
		else
			if (wire_pre_amble_cmpr_aeb == 1'b1) addr_shift_reg <= {{2{{2{1'b0}}}}, 1'b0, quad_address[8:0], 2'b10, address};
			else  addr_shift_reg <= {addr_shift_reg[30:0], 1'b0};
	// synopsys translate_off
	initial
		in_data_shift_reg = 0;
	// synopsys translate_on
	always @ ( posedge dpclk or  posedge reset)
		if (reset == 1'b1) in_data_shift_reg <= 16'b0;
		else if  (rd_data_input_state == 1'b1)   in_data_shift_reg <= {in_data_shift_reg[14:0], dprioout};
	// synopsys translate_off
	initial
		rd_out_data_shift_reg = 0;
	// synopsys translate_on
	always @ ( posedge dpclk or  posedge reset)
		if (reset == 1'b1) rd_out_data_shift_reg <= 16'b0;
		else
			if (wire_pre_amble_cmpr_aeb == 1'b1) rd_out_data_shift_reg <= {{2{1'b0}}, {2{1'b1}}, 1'b0, quad_address, 2'b10};
			else  rd_out_data_shift_reg <= {rd_out_data_shift_reg[14:0], 1'b0};
	// synopsys translate_off
	initial
		startup_cntr[0:0] = 0;
	// synopsys translate_on
	always @ ( posedge dpclk)
		if (wire_startup_cntr_ena[0:0] == 1'b1) 
			if (reset == 1'b1) startup_cntr[0:0] <= 1'b0;
			else  startup_cntr[0:0] <= wire_startup_cntr_d[0:0];
	// synopsys translate_off
	initial
		startup_cntr[1:1] = 0;
	// synopsys translate_on
	always @ ( posedge dpclk)
		if (wire_startup_cntr_ena[1:1] == 1'b1) 
			if (reset == 1'b1) startup_cntr[1:1] <= 1'b0;
			else  startup_cntr[1:1] <= wire_startup_cntr_d[1:1];
	// synopsys translate_off
	initial
		startup_cntr[2:2] = 0;
	// synopsys translate_on
	always @ ( posedge dpclk)
		if (wire_startup_cntr_ena[2:2] == 1'b1) 
			if (reset == 1'b1) startup_cntr[2:2] <= 1'b0;
			else  startup_cntr[2:2] <= wire_startup_cntr_d[2:2];
	assign
		wire_startup_cntr_d = {(startup_cntr[2] ^ (startup_cntr[1] & startup_cntr[0])), (startup_cntr[0] ^ startup_cntr[1]), (~ startup_cntr[0])};
	assign
		wire_startup_cntr_ena = {3{((((rden | wren) | rdinc) | (~ startup_idle)) & (~ startup_done))}};
	// synopsys translate_off
	initial
		state_mc_reg = 0;
	// synopsys translate_on
	always @ ( posedge dpclk or  posedge reset)
		if (reset == 1'b1) state_mc_reg <= 3'b0;
		else  state_mc_reg <= {(s2_to_1 | (((~ s2_to_0) & (~ s2_to_1)) & state_mc_reg[2])), (s1_to_1 | (((~ s1_to_0) & (~ s1_to_1)) & state_mc_reg[1])), (s0_to_1 | (((~ s0_to_0) & (~ s0_to_1)) & state_mc_reg[0]))};
	// synopsys translate_off
	initial
		wr_out_data_shift_reg = 0;
	// synopsys translate_on
	always @ ( posedge dpclk or  posedge reset)
		if (reset == 1'b1) wr_out_data_shift_reg <= 32'b0;
		else
			if (wire_pre_amble_cmpr_aeb == 1'b1) wr_out_data_shift_reg <= {{2{1'b0}}, 2'b01, 1'b0, quad_address[8:0], 2'b10, datain};
			else  wr_out_data_shift_reg <= {wr_out_data_shift_reg[30:0], 1'b0};
	lpm_compare   pre_amble_cmpr
	( 
	.aeb(wire_pre_amble_cmpr_aeb),
	.agb(wire_pre_amble_cmpr_agb),
	.ageb(),
	.alb(),
	.aleb(),
	.aneb(),
	.dataa(wire_state_mc_counter_q),
	.datab(6'b011111)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.aclr(1'b0),
	.clken(1'b1),
	.clock(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		pre_amble_cmpr.lpm_width = 6,
		pre_amble_cmpr.lpm_type = "lpm_compare";
	lpm_compare   rd_data_output_cmpr
	( 
	.aeb(),
	.agb(),
	.ageb(wire_rd_data_output_cmpr_ageb),
	.alb(wire_rd_data_output_cmpr_alb),
	.aleb(),
	.aneb(),
	.dataa(wire_state_mc_counter_q),
	.datab(6'b110000)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.aclr(1'b0),
	.clken(1'b1),
	.clock(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		rd_data_output_cmpr.lpm_width = 6,
		rd_data_output_cmpr.lpm_type = "lpm_compare";
	lpm_compare   state_mc_cmpr
	( 
	.aeb(wire_state_mc_cmpr_aeb),
	.agb(),
	.ageb(),
	.alb(),
	.aleb(),
	.aneb(),
	.dataa(wire_state_mc_counter_q),
	.datab({6{1'b1}})
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.aclr(1'b0),
	.clken(1'b1),
	.clock(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		state_mc_cmpr.lpm_width = 6,
		state_mc_cmpr.lpm_type = "lpm_compare";
	lpm_counter   state_mc_counter
	( 
	.clock(dpclk),
	.cnt_en((write_state | read_state)),
	.cout(),
	.eq(),
	.q(wire_state_mc_counter_q),
	.sclr(reset)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.aclr(1'b0),
	.aload(1'b0),
	.aset(1'b0),
	.cin(1'b1),
	.clk_en(1'b1),
	.data({6{1'b0}}),
	.sload(1'b0),
	.sset(1'b0),
	.updown(1'b1)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		state_mc_counter.lpm_port_updown = "PORT_UNUSED",
		state_mc_counter.lpm_width = 6,
		state_mc_counter.lpm_type = "lpm_counter";
	lpm_decode   state_mc_decode
	( 
	.data(state_mc_reg),
	.eq(wire_state_mc_decode_eq)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.aclr(1'b0),
	.clken(1'b1),
	.clock(1'b0),
	.enable(1'b1)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		state_mc_decode.lpm_decodes = 8,
		state_mc_decode.lpm_width = 3,
		state_mc_decode.lpm_type = "lpm_decode";
	or(wire_dprioin_mux_dataout, ((((((wr_addr_state | rd_addr_state) & addr_shift_reg[31]) & wire_pre_amble_cmpr_agb) | ((~ wire_pre_amble_cmpr_agb) & (wr_addr_state | rd_addr_state))) | (((wr_data_state & wr_out_data_shift_reg[31]) & wire_pre_amble_cmpr_agb) | ((~ wire_pre_amble_cmpr_agb) & wr_data_state))) | (((rd_data_output_state & rd_out_data_shift_reg[15]) & wire_pre_amble_cmpr_agb) | ((~ wire_pre_amble_cmpr_agb) & rd_data_output_state))), ~(((write_state | rd_addr_state) | rd_data_output_state)));
	assign
		busy = busy_state,
		busy_state = (write_state | read_state),
		dataout = in_data_shift_reg,
		dpriodisable = (~ (startup_cntr[2] & (startup_cntr[0] | startup_cntr[1]))),
		dprioin = wire_dprioin_mux_dataout,
		dprioload = (~ ((startup_cntr[0] ^ startup_cntr[1]) & (~ startup_cntr[2]))),
		idle_state = wire_state_mc_decode_eq[0],
		rd_addr_done = (rd_addr_state & wire_state_mc_cmpr_aeb),
		rd_addr_state = (wire_state_mc_decode_eq[5] & startup_done),
		rd_data_done = (rd_data_state & wire_state_mc_cmpr_aeb),
		rd_data_input_state = (wire_rd_data_output_cmpr_ageb & rd_data_state),
		rd_data_output_state = (wire_rd_data_output_cmpr_alb & rd_data_state),
		rd_data_state = (wire_state_mc_decode_eq[7] & startup_done),
		rdinc = 1'b0,
		read_state = (rd_addr_state | rd_data_state),
		s0_to_0 = ((wr_data_state & wr_data_done) | (rd_data_state & rd_data_done)),
		s0_to_1 = (((idle_state & (wren | ((~ wren) & ((rden | rdinc) | wren_data)))) | (wr_addr_state & wr_addr_done)) | (rd_addr_state & rd_addr_done)),
		s1_to_0 = (((wr_data_state & wr_data_done) | (rd_data_state & rd_data_done)) | (idle_state & (wren | (((~ wren) & (~ wren_data)) & rden)))),
		s1_to_1 = (((idle_state & ((~ wren) & (rdinc | wren_data))) | (wr_addr_state & wr_addr_done)) | (rd_addr_state & rd_addr_done)),
		s2_to_0 = ((((wr_addr_state & wr_addr_done) | (wr_data_state & wr_data_done)) | (rd_data_state & rd_data_done)) | (idle_state & (wren | wren_data))),
		s2_to_1 = ((idle_state & (((~ wren) & (~ wren_data)) & (rdinc | rden))) | (rd_addr_state & rd_addr_done)),
		startup_done = ((startup_cntr[2] & (~ startup_cntr[0])) & startup_cntr[1]),
		startup_idle = ((~ startup_cntr[0]) & (~ (startup_cntr[2] ^ startup_cntr[1]))),
		wr_addr_done = (wr_addr_state & wire_state_mc_cmpr_aeb),
		wr_addr_state = (wire_state_mc_decode_eq[1] & startup_done),
		wr_data_done = (wr_data_state & wire_state_mc_cmpr_aeb),
		wr_data_state = (wire_state_mc_decode_eq[3] & startup_done),
		write_state = (wr_addr_state | wr_data_state);
endmodule //recon_alt_dprio_kuj

//synthesis_resources = alt_cal 1 lpm_compare 3 lpm_counter 1 lpm_decode 1 lut 1 reg 114 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
(* ALTERA_ATTRIBUTE = {"{-to address_pres_reg[11]} DPRIO_CHANNEL_NUM=11;{-to address_pres_reg[10]} DPRIO_CHANNEL_NUM=10;{-to address_pres_reg[9]} DPRIO_CHANNEL_NUM=9;{-to address_pres_reg[8]} DPRIO_CHANNEL_NUM=8;{-to address_pres_reg[7]} DPRIO_CHANNEL_NUM=7;{-to address_pres_reg[6]} DPRIO_CHANNEL_NUM=6;{-to address_pres_reg[5]} DPRIO_CHANNEL_NUM=5;{-to address_pres_reg[4]} DPRIO_CHANNEL_NUM=4;{-to address_pres_reg[3]} DPRIO_CHANNEL_NUM=3;{-to address_pres_reg[2]} DPRIO_CHANNEL_NUM=2;{-to address_pres_reg[1]} DPRIO_CHANNEL_NUM=1;{-to address_pres_reg[0]} DPRIO_CHANNEL_NUM=0"} *)
module  recon_alt2gxb_reconfig_tfm
	( 
	busy,
	reconfig_clk,
	reconfig_fromgxb,
	reconfig_togxb) /* synthesis synthesis_clearbox=2 */;
	output   busy;
	input   reconfig_clk;
	input   [16:0]  reconfig_fromgxb;
	output   [3:0]  reconfig_togxb;

	wire  wire_calibration_busy;
	wire  [15:0]   wire_calibration_dprio_addr;
	wire  [15:0]   wire_calibration_dprio_dataout;
	wire  wire_calibration_dprio_rden;
	wire  wire_calibration_dprio_wren;
	wire  [8:0]   wire_calibration_quad_addr;
	wire  wire_calibration_retain_addr;
	wire  wire_dprio_busy;
	wire  [15:0]   wire_dprio_dataout;
	wire  wire_dprio_dpriodisable;
	wire  wire_dprio_dprioin;
	wire  wire_dprio_dprioload;
	(* ALTERA_ATTRIBUTE = {"PRESERVE_REGISTER=ON"} *)
	reg	[11:0]	address_pres_reg;
	wire  cal_busy;
	wire  [0:0]  cal_dprioout_wire;
	wire  [7:0]  cal_testbuses;
	wire  [2:0]  channel_address;
	wire  [15:0]  dprio_address;
	wire  is_adce_all_control;
	wire  is_adce_continuous_single_control;
	wire  is_adce_one_time_single_control;
	wire  is_adce_single_control;
	wire  is_adce_standby_single_control;
	wire offset_cancellation_reset;
	wire  [8:0]  quad_address;
	wire  reconfig_reset_all;
	wire transceiver_init;

	alt_cal   calibration
	( 
	.busy(wire_calibration_busy),
	.cal_error(),
	.clock(reconfig_clk),
	.dprio_addr(wire_calibration_dprio_addr),
	.dprio_busy(wire_dprio_busy),
	.dprio_datain(wire_dprio_dataout),
	.dprio_dataout(wire_calibration_dprio_dataout),
	.dprio_rden(wire_calibration_dprio_rden),
	.dprio_wren(wire_calibration_dprio_wren),
	.quad_addr(wire_calibration_quad_addr),
	.remap_addr(address_pres_reg),
	.reset((offset_cancellation_reset | reconfig_reset_all)),
	.retain_addr(wire_calibration_retain_addr),
	.testbuses(cal_testbuses),
	.transceiver_init(transceiver_init)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.start(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		calibration.channel_address_width = 1,
		calibration.number_of_channels = 2,
		calibration.sim_model_mode = "FALSE",
		calibration.lpm_type = "alt_cal";
	recon_alt_dprio_kuj   dprio
	( 
	.address(({16{wire_calibration_busy}} & dprio_address)),
	.busy(wire_dprio_busy),
	.datain(({16{wire_calibration_busy}} & wire_calibration_dprio_dataout)),
	.dataout(wire_dprio_dataout),
	.dpclk(reconfig_clk),
	.dpriodisable(wire_dprio_dpriodisable),
	.dprioin(wire_dprio_dprioin),
	.dprioload(wire_dprio_dprioload),
	.dprioout(cal_dprioout_wire),
	.quad_address(address_pres_reg[11:3]),
	.rden((wire_calibration_busy & wire_calibration_dprio_rden)),
	.reset(reconfig_reset_all),
	.wren((wire_calibration_busy & wire_calibration_dprio_wren)),
	.wren_data(wire_calibration_retain_addr));
	// synopsys translate_off
	initial
		address_pres_reg = 0;
	// synopsys translate_on
	always @ ( posedge reconfig_clk or  posedge reconfig_reset_all)
		if (reconfig_reset_all == 1'b1) address_pres_reg <= 12'b0;
		else  address_pres_reg <= {quad_address, channel_address};
	assign
		busy = cal_busy,
		cal_busy = wire_calibration_busy,
		cal_dprioout_wire = {reconfig_fromgxb[0]},
		cal_testbuses = {reconfig_fromgxb[8:1]},
		channel_address = wire_calibration_dprio_addr[14:12],
		dprio_address = {wire_calibration_dprio_addr[15], address_pres_reg[2:0], wire_calibration_dprio_addr[11:0]},
		offset_cancellation_reset = 1'b0,
		quad_address = wire_calibration_quad_addr,
		reconfig_reset_all = 1'b0,
		reconfig_togxb = {wire_calibration_busy, wire_dprio_dprioload, wire_dprio_dpriodisable, wire_dprio_dprioin},
		transceiver_init = 1'b0;
endmodule //recon_alt2gxb_reconfig_tfm
//VALID FILE


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module recon (
	reconfig_clk,
	reconfig_fromgxb,
	busy,
	reconfig_togxb)/* synthesis synthesis_clearbox = 2 */;

	input	  reconfig_clk;
	input	[16:0]  reconfig_fromgxb;
	output	  busy;
	output	[3:0]  reconfig_togxb;

	wire  sub_wire0;
	wire [3:0] sub_wire1;
	wire  busy = sub_wire0;
	wire [3:0] reconfig_togxb = sub_wire1[3:0];

	recon_alt2gxb_reconfig_tfm	recon_alt2gxb_reconfig_tfm_component (
				.reconfig_clk (reconfig_clk),
				.reconfig_fromgxb (reconfig_fromgxb),
				.busy (sub_wire0),
				.reconfig_togxb (sub_wire1))/* synthesis synthesis_clearbox=2
	 clearbox_macroname = alt2gxb_reconfig
	 clearbox_defparam = "cbx_blackbox_list=-lpm_mux;intended_device_family=Arria II GX;number_of_channels=2;number_of_reconfig_ports=1;enable_buf_cal=true;reconfig_fromgxb_width=17;reconfig_togxb_width=4;" */;

endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: ADCE NUMERIC "0"
// Retrieval info: PRIVATE: CMU_PLL NUMERIC "0"
// Retrieval info: PRIVATE: DATA_RATE NUMERIC "0"
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Arria II GX"
// Retrieval info: PRIVATE: PMA NUMERIC "0"
// Retrieval info: PRIVATE: PROTO_SWITCH NUMERIC "0"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
// Retrieval info: CONSTANT: CBX_BLACKBOX_LIST STRING "-lpm_mux"
// Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Arria II GX"
// Retrieval info: CONSTANT: NUMBER_OF_CHANNELS NUMERIC "2"
// Retrieval info: CONSTANT: NUMBER_OF_RECONFIG_PORTS NUMERIC "1"
// Retrieval info: CONSTANT: enable_buf_cal STRING "true"
// Retrieval info: CONSTANT: reconfig_fromgxb_width NUMERIC "17"
// Retrieval info: CONSTANT: reconfig_togxb_width NUMERIC "4"
// Retrieval info: USED_PORT: busy 0 0 0 0 OUTPUT NODEFVAL "busy"
// Retrieval info: USED_PORT: reconfig_clk 0 0 0 0 INPUT NODEFVAL "reconfig_clk"
// Retrieval info: USED_PORT: reconfig_fromgxb 0 0 17 0 INPUT NODEFVAL "reconfig_fromgxb[16..0]"
// Retrieval info: USED_PORT: reconfig_togxb 0 0 4 0 OUTPUT NODEFVAL "reconfig_togxb[3..0]"
// Retrieval info: CONNECT: @reconfig_fromgxb 0 0 17 0 reconfig_fromgxb 0 0 17 0
// Retrieval info: CONNECT: @reconfig_clk 0 0 0 0 reconfig_clk 0 0 0 0
// Retrieval info: CONNECT: reconfig_togxb 0 0 4 0 @reconfig_togxb 0 0 4 0
// Retrieval info: CONNECT: busy 0 0 0 0 @busy 0 0 0 0
// Retrieval info: GEN_FILE: TYPE_NORMAL recon.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL recon.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL recon.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL recon.bsf TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL recon_inst.v FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL recon_bb.v FALSE
// Retrieval info: LIB_FILE: altera_mf
// Retrieval info: LIB_FILE: lpm
