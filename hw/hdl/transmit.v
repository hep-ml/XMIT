//exp/microboone/xmit_module_2010/test_101008/readcontrol/ june3,2011

// decode the opticzl receive data to generated busy
// increase the 256X34 fifo size to 32KX34

// change busy threshold from 0x400 to 0x4000

// add hamming code error detect, correction counter


module transmit (
clk128,clk192,clk48,xtal,run,
bob,block,dav,fst,lst,data,eob,
gxb_tx,
gxb_rx,
busyout,
tx_digitalreset,pll_locked,
opt1_status,opt2_status,
tp1, err_corrected_counter,err_detected_counter,
coreclockout_in,
txrdempty_f_out,
wrusedw_f_out,
tx_datain_f_out,
cntrl_1_f_out,
ctrl_f_out,
busy_in
);

input         clk128;
input         clk192;
input         clk48;
input         xtal;
input         run;
input         bob;
input         block;
input         dav;
input         fst;
input         lst;
input  [31:0] data;
input         eob;

input         tx_digitalreset;
output        pll_locked;
output [1:0]  gxb_tx;
input  [1:0]  gxb_rx;
output        busyout;
output        opt1_status;
output        opt2_status;

output [7:0]  err_corrected_counter;
output [7:0]  err_detected_counter;


output        tp1;
wire          tp1;

//separate the 12 word header from the adc data:
reg         hedblk;
reg [3:0]   wordcount;
reg         udav;
reg [31:0]  udat;
reg         ufst;
reg         ulst;

wire [15:0] heddat;
wire        heddav;
wire        hedfst;
wire        hedlst;

reg         dblk;
reg         dfst;
wire        dlst;
wire        ddav;
wire [29:0] ddat;

reg         busyout;
wire        busy;



wire [17:0] tp_out;
wire tp_valid;
wire tp_overflow;

TP_module t1 (
.clk196   (clk192),
.rst      (!run),
.data_in  (xdata),
.data_out (tp_out),
.overflow (tp_overflow),
.valid    (tp_valid)
);

input coreclockout_in;
output txrdempty_f_out;
wire lstq_f;
wire fstq_f;
output [13:0] wrusedw_f_out;
input busy_in;
wire ack_f;
assign      ack_f = (!txrdempty_f_out & !busy_in);

fifo16kx18_f   xmitfifo_feature (  //show ahead fifo
.aclr       (!run),
.wrclk      (clk192),
.wrreq      (tp_valid),
.data       ({tp_out[1], tp_out[0], tp_out[17:2]}),
.rdclk      (coreclockout_in),
.rdreq      (ack_f),
.rdempty    (txrdempty_f_out),
.q          ({lstq_f,fstq_f,txq_f}),
.wrusedw    (wrusedw_f_out)
);
always @ (posedge coreclockout_in)
begin

		fifo_d_f <= txq_f;
		ack_q_f <= ack_f;
		lstq_d_f <= lstq_f;
		

		ufstq_f <= (!txrdempty_f_out & !busy_in) & fstq_f;
		
      if      (!run)              txblock_f <= 1'b0;
      else if (fstq_f ) txblock_f <= 1'b1;
      else if (lstq_d_f)          txblock_f <= 1'b0;
      
      
      txdav_f <= ack_q_f;
      txqq_f <= txq_f;           
end

reg         ufstq_f       ;

reg [15:0]	fifo_d_f;
reg         ack_q_f;        

reg         txblock_f;
reg  [15:0] txqq_f;
reg         txdav_f;
reg         lstq_d_f;

wire [15:0] txq_f;
                  
output [15:0] tx_datain_f_out;
assign tx_datain_f_out = (!txblock_f          ? {comma} : 16'b0) |
                   ( txblock_f &  txdav_f ? txqq_f          : 16'b0) |
                   ( txblock_f & !txdav_f ? {space} : 16'b0) ;
                 
output ctrl_f_out;
assign ctrl_f_out = !txblock_f | (txblock_f & !txdav_f);
output cntrl_1_f_out;
assign cntrl_1_f_out = txblock_f & !txdav_f;

always @ (posedge clk128)
begin
      if      (!run | !block)          hedblk <= 1'b0;
      else if (fst & block)            hedblk <= 1'b1;
      else if (wordcount==12)          hedblk <= 1'b0;   

      if      (!run | !block)       wordcount <= 4'b0;
      else if (block & dav & !dblk) wordcount <= wordcount + 4'b0001;
      else if (dblk)                wordcount <= 4'b0;
      
                                         udav <= dav;
                                         udat <= data;
                                         ulst <= lst;
                                         ufst <= fst;
      
      if      (!run | !block)                dblk <= 1'b0;
      else if ((wordcount==12) & dav & !lst) dblk <= 1'b1;
      else if (ulst)                         dblk <= 1'b0; 
      
      if      ((wordcount==12) & dav & !lst) dfst <= 1'b1;
      else                                   dfst <= 1'b0;
end

assign heddav = hedblk & udav;
assign heddat = hedblk ? udat[15:0] : 16'b0;
assign hedfst = hedblk & ufst;
assign hedlst = hedblk & udav & (wordcount==12);

assign   ddav = dblk & udav;
assign   dlst = dblk & ulst;
assign   ddat = dblk ? udat[29:0] : 29'b0;

wire        hedempty;
wire [15:0] heddata;
wire        hedfirst;
wire        hedlast;

//sync header data to clk192:
hedfifo256x18 hedfifo ( //showahead fifo
.aclr      (!run),
.wrclk     (clk128),
.wrreq     (heddav),
.data      ({hedlst,hedfst,heddat}),
.rdclk     (clk192),
.rdreq     (!hedempty),
.rdempty   (hedempty),
.q         ({hedlast,hedfirst,heddata})
);

//hamming decoder:
reg            hdav;
reg            hfst;
reg            hlst;
wire  [23:0]   hdat;

wire           err_detected /* synthesis keep */;
wire           err_corrected /* synthesis keep */;
wire           err_fatal /* synthesis keep */;

reg [7:0]      err_corrected_counter;
reg [7:0]      err_detected_counter;


decode24       hamming (        
.clock         (clk128),
.data          (ddat),
.err_detected  (err_detected),
.err_corrected (err_corrected),
.err_fatal     (err_fatal),
.q             (hdat) 
);


always @ (posedge clk128)
begin
	if (!run)   err_detected_counter <= 8'b0;
	else if (err_detected == 1'b1) err_detected_counter <= err_detected_counter + 8'b1;

	if (!run)   err_corrected_counter <= 8'b0;
	else if (err_corrected == 1'b1) err_corrected_counter <= err_corrected_counter + 8'b1;
end


always @ (posedge clk128)
begin
      hdav <= ddav;
      hfst <= dfst;
      hlst <= dlst;
end

//convert the 24bit 128mhz stream to a 16bit 192mhz stream:
wire [15:0] dato;
wire        davo;
wire        fsto;
wire        lsto;

gear24to16 stream16 (
.init      (!run),
.clk128    (clk128),
.clk192    (clk192),
.datin     (hdat),
.davin     (hdav),
.fstin     (hfst),
.lstin     (hlst),
.datout    (dato),
.davout    (davo),
.fstout    (fsto),
.lstout    (lsto)
);

wire        mfst;
wire        mlst;
wire        mdav;
wire [15:0] mdat;

assign      mfst = hedfirst  | fsto;
assign      mlst = hedlast   | lsto;
assign      mdav = !hedempty | davo;
assign      mdat = (!hedempty ? heddata : 16'b0) |
                   (davo      ? dato    : 16'b0) ;

wire         valid;
wire  [15:0] datms;
wire  [15:0] datls;

gear16to32  gear16_32 (
.clk        (clk192),
.init       (!run),
.fsti       (mfst),
.lsti       (mlst),
.davi       (mdav),
.dati       (mdat),
.fst        (),
.lst        (),
.dav        (valid),
.datms      (datms),
.datls      (datls)
);

//flag the beginning and end of the event block:
reg [3:0]  sr;
reg [18:0] delay;
reg        lstwd;
always @ (posedge clk192)
begin
                 sr <= {sr[2:0],bob};
              delay <= {delay[17:0],eob};
 
     if      (delay[17] & !delay[18]) lstwd <= 1'b1;
     else                             lstwd <= 1'b0;              
end
wire   fstwd;
assign fstwd = sr[1] & !sr[2];
                  
//output to the optics xmitter:
wire [31:0] xdata;
assign      xdata = (fstwd     ? {32'hffffffff}  : 32'd0) |
                    (valid     ? {datms,datls}   : 32'd0) |
                    (lstwd     ? {4'he,28'h0}    : 32'd0) ;

wire         xdav;
assign       xdav = fstwd | valid | lstwd;

wire        coreclockout;
wire        txrdempty;
wire [31:0] txq;
wire        lstq;
wire        fstq;
wire [14:0] wrusedw;

//
//  fifo half full now become busyout
//
always @ (posedge clk128)
begin
			if(wrusedw >= 15'h4000) busyout <= 1'b1;
			else if(wrusedw <= 15'h1000) busyout <= 1'b0;

//         busyout                <= busy;
end



//
// fifo size has been increase to 32K word
//
fifo256x34  xmitfifo (  //show-ahead fifo
.aclr       (!run),
.wrclk      (clk192),
.wrreq      (xdav),
//.wrreq      (tp_valid),
.data       ({lstwd,fstwd,xdata}),
//.data       ({tp_out[1], tp_out[0], tp_out[17:2],tp_out[17:2]}),
.rdclk      (coreclockout),
//rdreq      (!txrdempty),
.rdreq      (ack),
.rdempty    (txrdempty),
.q          ({lstq,fstq,txq}),
.wrusedw    (wrusedw)
);

wire        ack;
reg         ufstq       /* synthesis keep */;

assign      ack = (!txrdempty & !busy);

reg [31:0]	fifo_d;
reg         ack_q;        

reg         txblock;
reg  [31:0] txdata;
reg  [31:0] txqq;
reg         txdav;
reg         lstq_d;

always @ (posedge coreclockout)
begin

		fifo_d <= txq;
		ack_q <= ack;
		lstq_d <= lstq;
		

		ufstq <= (!txrdempty & !busy) & fstq;
		
      if      (!run)              txblock <= 1'b0;
      else if (fstq ) txblock <= 1'b1;
//      else if (fstq & !txrdempty) txblock <= 1'b1;
      else if (lstq_d)          txblock <= 1'b0;
      
//      if      (lstq & !txrdempty) endblock <= 1'b1;
//      else                        endblock <= 1'b0;
      
//                txdav <= !txrdempty;
				     txdav <= ack_q;
//                 txdav <= !txrdempty & !busy;
                 txqq <= txq;           
end

//parameter comma = {8'b10111100,8'b11000101}; //{k28.5,d5.6}
parameter comma = {8'b11000101,8'b10111100}; //{d5.6,k28.5}
parameter space = {8'b11110111,8'b11110111}; //{k23.7,k23.7}
                  
wire [31:0] tx_datain;
assign tx_datain = (!txblock          ? {comma,comma} : 32'b0) |
                   ( txblock &  txdav ? txqq          : 32'b0) |
                   ( txblock & !txdav ? {space,space} : 32'b0) ;
                 
wire   ctrl;
assign ctrl = !txblock | (txblock & !txdav);
wire   cntrl_1;
assign cntrl_1 = txblock & !txdav;


wire [1:0]          gxb_tx;
wire [31:0]         rx_dataout;  //saynthesis akeep//
wire                tx_digitalreset;
wire  [3:0]         rx_syncstatus;
wire  [3:0]         rx_ctrldetect;





xmitrec   transrec (
//transmitter:
.cal_blk_clk       (clk48),
.pll_inclk         (xtal),
.pll_locked        (pll_locked),
.tx_digitalreset   (tx_digitalreset),
.coreclkout        (coreclockout),
.tx_datain         (tx_datain),
.tx_ctrlenable     ({cntrl_1,ctrl,cntrl_1,ctrl}),
//.tx_ctrlenable     (4'b0), 
.tx_dataout        (gxb_tx),
.tx_clkout         (),

//receiver:
.reconfig_clk      (clk48),
.reconfig_togxb    (reconfig_togxb),
.reconfig_fromgxb  (reconfig_fromgxb),
.rx_cruclk         ({xtal,xtal}),
.rx_datain         (gxb_rx),
.rx_dataout        (rx_dataout),
.rx_ctrldetect     (rx_ctrldetect),
.rx_patterndetect  (rx_patterndetect),
.rx_syncstatus     (rx_syncstatus),
.rx_signaldetect   (),
.rx_errdetect      (), 
.rx_clkout         ()

);

wire [3:0]          reconfig_togxb;
wire [16:0]         reconfig_fromgxb;

recon     reconfig (
.reconfig_clk      (clk48),
.reconfig_fromgxb  (reconfig_fromgxb),
.reconfig_togxb    (reconfig_togxb),
.busy              ()
);

reg    busy1;
reg    busy2;

wire   opt1_status;
wire   opt2_status;
assign opt1_status = (rx_syncstatus[0] & rx_syncstatus[1]) ? 1'b1 : 1'b0;
assign opt2_status = (rx_syncstatus[2] & rx_syncstatus[3]) ? 1'b1 : 1'b0;

wire [3:0]   rx_patterndetect;
reg          sel_low, sel_high, ready_low, ready_high;
reg          validdata_low, validdata_high;
reg  [7:0]   udel_low, udel_high;
reg  [15:0]  data_low, data_high;
reg  [1:0]   cd_low, cd_high;
reg          cd1, cd2;
 

always @ (posedge coreclockout) 
begin
   if      (rx_patterndetect[1:0]==2) sel_low <= 1'b1; //( ==1) ?
   else if (rx_patterndetect[1:0]==1) sel_low <= 1'b0; //( ==2) ?

                                udel_low <= rx_dataout[15:8];
   if      (sel_low)            data_low <= {rx_dataout[7:0],udel_low};
   else                         data_low <= {rx_dataout[15:0]};
	
											    cd1 <= rx_ctrldetect[1];
   if      (sel_low)            cd_low <= {rx_ctrldetect[0],cd1};
   else                         cd_low <= {rx_ctrldetect[1:0]};
											  
	

   if ((rx_patterndetect[1:0]!=0) & opt1_status) ready_low <= 1'b1;
   else if                   (!opt1_status)      ready_low <= 1'b0;

   if (ready_low & (rx_patterndetect[1:0]==0)) validdata_low <= 1'b1;
   else                                        validdata_low <= 1'b0;
	
	if((data_low[14] | data_low[6]) & validdata_low & (cd_low == 2'b0))  busy1 <= 1'b1;
	else                                              busy1 <= 1'b0;


   if      (rx_patterndetect[3:2]==2) sel_high <= 1'b1; //( ==1) ?
   else if (rx_patterndetect[3:2]==1) sel_high <= 1'b0; //( ==2) ?

                                udel_high <= rx_dataout[31:24];
   if      (sel_high)           data_high <= {rx_dataout[23:16],udel_high};
   else                         data_high <= {rx_dataout[31:16]};
	
												    cd2 <= rx_ctrldetect[3];
   if      (sel_high)            cd_high <= {rx_ctrldetect[2],cd2};
   else                         cd_high <= {rx_ctrldetect[3:2]};


   if ((rx_patterndetect[3:2]!=0) & opt2_status) ready_high <= 1'b1;
   else if                   (!opt2_status)      ready_high <= 1'b0;

   if (ready_high & (rx_patterndetect[3:2]==0)) validdata_high <= 1'b1;
   else                                         validdata_high <= 1'b0;

	if((data_high[14] | data_high[6]) & validdata_high & & (cd_high == 2'b0))  busy2 <= 1'b1;
	else                                                busy2 <= 1'b0;

	
	
end

assign busy = busy1 | busy2;

//assign tp1 = rx_dataout[14] | rx_dataout[30] | rx_dataout[1];
assign tp1 = busy;
//assign busy = 1'b0;

//always @ (posedge clk192)
//begin
//			if((rx_dataout[14] | rx_dataout[6]) & !rx_ctrldetect[0] & !rx_ctrldetect[1] & opt1_status)  busy1 <= 1'b1;
//			else                                                                      busy1 <= 1'b0;
//			if((rx_dataout[30] | rx_dataout[22]) & !rx_ctrldetect[2] & !rx_ctrldetect[3] & opt2_status) busy2 <= 1'b1;
//			else                                                                      busy2 <= 1'b0;
//end

endmodule
