//exp/microboone/xmit_module_2010/readcontrol_110601/  june3,2011
//EP2AGX65DF25C
//top file

//modified for 16bit header word size.

// modified the transmit.v to deal with hold comback from pice boacrd
// increase FIFO size in the XMIT. 
// busy is from fifo half full on the trasmit

// use framecount in the compare to generate token for supernova
// reset framecount at bit 23

// change buys counter threshold from 0x400 to 0x4000 (16K)
// fixed time out counter error 8/21/2017

// change read2count for trigger readout increment 1 to 3 // 8/30/2017

// add history fifo readout                         8/30/2017  

// add hamming code detect/error  readout           8/30/2017






module readcontrol (
clock16,runin,syncin,trigin,
linkinclk,linkin,
token1,token2,token3,hold,accept,
xtal,gxb_tx1,gxb_tx2,gxb_rx1,gxb_rx2,
bytin,bytout,
clk128out,
indic1,indic2,indic3,indic4,tp1,tp2
);

input         clock16;      //system clock
input         runin;        //system run
input         syncin;       //system sync
input         trigin;       //system trigger

input         linkinclk;    //lvds clock from backplane-link
input  [8:0]  linkin;       //lvds data  from backplane-link

output        token1;       //trig  token  to backplane-link
output        token2;       //frame token  to backplane-link
output        token3;       //spare token  to backplane-link
output        accept;       //accept       to backplane-link
output        hold;         //hold         to backplane-link

input         xtal;         //156.25Mhz xtal
output [1:0]  gxb_tx1;      //trig data  to optics driver1,2
output [1:0]  gxb_tx2;      //frame data to optics driver1,2 

input  [1:0]  gxb_rx1;      //trig  optics receiver1 
input  [1:0]  gxb_rx2;      //trig  optics receiver2

input  [9:0]  bytin;        //slow-control input
output [9:0]  bytout;       //slow-control output

output        clk128out;

output        indic1;
output        indic2;
output        indic3;
output        indic4;
output        tp1;
output        tp2;


wire          opt1_status_n;
wire          opt2_status_n;
wire          opt1_status_s;
wire          opt2_status_s;

//assigned:
assign token3 = 1'b0;
//assign hold   = 1'b0;
assign  hold = ((busy2 & active2) | (busy1 & active1)) ;
//assign   hold = 1'b1;
assign accept = 1'b1;

//indicators:
wire   error;
assign indic1 = rx_locked;
//assign indic2 = active1;
//assign indic3 = active2;
//assign indic4 = error;
//assign indic4 = locked;
//assign indic4 = busy2 | busy1;
assign indic4 = linkdav;

//assign indic2 = test1;
//assign indic3 = test2;
assign indic3 = busy2;
assign indic2 = busy1;

//assign    tp1 = tx_digitalreset;
//assign    tp1 = dav1;
//assign    tp1 = data[35] | data[34] | data[33] | data[32];
//assign    tp1 = test_trig;
//assign    tp2 = davo;
//assign    tp2 = token1;
//assign    tp2 = dpa_probe;
//assign tp1 = linkdav;
//assign tp2 = token2;

assign tp1 = linkdav;
//assign tp2 = trigin;

//assign  tp1 = read2count[0];
//assign tp1 = active2;
//assign tp1 = read2;
//assign tp1 = clk16;
assign tp2 = busy1 | busy2;
//assign tp2 = tr_tp1;
//assign tp2 = clk48;
//assign  tp2 = read1count[0];
//assign tp2 = eventcount[0];
//assign tp2 = clk16;
//assign  tp2 = linkdav;

reg       test_trig;
reg [3:0] test_data;
reg [8:0] dpa_p;
reg       dpa_probe;

always @ (posedge clk16)
begin
	  dpa_p <= rx_dpa_locked;
	  dpa_probe <= dpa_p[0] | dpa_p[1] | dpa_p[2] | dpa_p[3] | dpa_p[4] | dpa_p[5] | dpa_p[6] | dpa_p[7] | dpa_p[8];
end


//clocks:
wire       locked;
wire       clk16;
wire       clk128;
wire       clk192;
wire       clk48;

pll16   clocks (
.inclk0    (clock16),
.locked    (locked),
.c0        (clk16),
.c1        (clk128),
.c2        (clk192),
.c3        (clk128out),
.c4        (clk48)
);

//system control inputs:
reg   run;
reg   sync;
reg   trig;
reg   trig1;
reg   trig2;

always @ (posedge clk16)
begin
      run  <= runin;
      sync <= syncin;
//      trig <= trigin;
      trig1 <= trigin;
		trig2 <= trig1;
		trig  <= trig1 & !trig2;   // clip the incoming trigger
end

//count the frames and triggers:
reg  [23:0]  framecount;        //frames
reg  [23:0]  eventcount;        //triggers

reg  [23:0]  framecount_t;        //frame counter to issue superNova token

reg  [15:0]  clk_counter;

always @ (posedge clk16)
begin
     if      (!run)        framecount <= 24'd0;
     else if (run & sync)  framecount <= framecount + 24'd1;
	  else if (counter_reset & !eob2s) framecount <= framecount - 24'h800000;  // protect against read2count not reset

     if      (!run)        eventcount <= 24'd0;
     else if (run & trig & ((clk_counter < 2 ) | (clk_counter >9)))  eventcount <= eventcount + 24'd1;

     if      (!run)        framecount_t <= 24'd0;
     else if (framecount>24'd8)  framecount_t <= framecount_t + 24'd1;
	  
	  if      (!run)        clk_counter <= 16'b0;
	  else if (run & sync)	clk_counter <= 16'b0;
	  else                  clk_counter <= clk_counter + 16'b1;
	  
end

reg         counter_reset;

always @ (posedge clk16)
begin
	  
     if      (!run)                    counter_reset <=  1'b0;
	  else if (read2count[23])           counter_reset <=  1'b1;
	  else                              counter_reset <=  1'b0;
	  
end


//count the transmitted events:
reg  [23:0]   read1count;      //triggered events readout
reg  [23:0]   read2count;      //supernova events readout

always @ (posedge clk16)
begin
      if      (!run)  read1count <= 24'd0;
      else if (eob1s)  read1count <= read1count + 24'd1;
//      else if (eob1)  read1count <= read1count + 24'd1;
		
		if      (!run)  read2count <= 24'd0;
      else if (eob2s)  read2count <= read2count + 24'd1;
		else if (eob1s)  read2count <= read2count + 24'd3;    /// becuase every trigger, we readout 4 frames of data
//		else if (eob1s)  read2count <= read2count + 24'd1;    /// becuase every trigger, we readout 3 frames of data (temp)
		else if (counter_reset & !sync) read2count <= read2count - 24'h800000; //// protect against framecount not reset
//		else if (eob2)  read2count <= read2count + 24'd1;
end

//read requests:
reg    read1;
reg    read2;
reg    eob;
wire   eob1s;
wire   eob2s;
wire   rd1;
wire   rd2;
wire   en1;
wire   en2;

//reg    start;   // add start to solve initial problem

assign rd1 = en1 & run & !read1 & (eventcount>read1count);
//assign rd1 = en1 & run & !read1 & (start | (eventcount>read1count));

//assign rd2 = en2 & run & !read2 & (framecount_t>read2count);
assign rd2 = en2 & run & !read2 & (framecount>read2count);

always @ (posedge clk16)
begin
    if      (!run)   read1 <= 1'b0;
    else if (rd1)    read1 <= 1'b1;
    else if (eob1s)  read1 <= 1'b0;

    if      (!run)   read2 <= 1'b0;
    else if (rd2)    read2 <= 1'b1;
    else if (eob2s)  read2 <= 1'b0;
    
//	if      (!run)   start <= 1'b1;
//	else if (rd1)    start <= 1'b0;
end

//read priority:
reg  [2:0] delay1;
reg        active1;
reg        active2;
wire       set1;
wire       set2;

assign     set1 = (read1 & !active2 & (delay1==3));
assign     set2 = (read2 & !active1 & !set1);

always @ (posedge clk16)
begin
  if      (!read1)          delay1 <= 3'd0;
  else if (active1)         delay1 <= 3'd0;
  else if (sync & read1)    delay1 <= delay1 + 3'd1;

  if      (!run)           active1 <= 1'b0;
  else if (eob1s)          active1 <= 1'b0;
  else if (set1)           active1 <= 1'b1;

  if      (!run)           active2 <= 1'b0;
  else if (eob2s)          active2 <= 1'b0;
  else if (set2)           active2 <= 1'b1; 
end

//tokens to the daq modules:
reg  udel1;
reg  udel2;
reg  token1;
reg  token2;

always @ (posedge clk16)
begin
                udel1 <= active1;
                udel2 <= active2;

        if     (active1 & !udel1) token1 <= 1'b1;
        else                      token1 <= 1'b0;

        if     (active2 & !udel2) token2 <= 1'b1;
        else                      token2 <= 1'b0;
end

/*
//busy from pci drops data but not headers:
reg    drop1;
reg    drop2; 
wire   dropdata;

always @ (posedge clk16)
begin        
        if      (!busy1 & active1 & !udel1) drop1 <= 1'b1;
        else if (!active1)                  drop1 <= 1'b0;

        if      (!busy2 & active2 & !udel2) drop2 <= 1'b1;
        else if (!active2)                  drop2 <= 1'b0; 
end

assign dropdata = drop1 | drop2;
*/

//syncronize eob from clk128 to clk16:
reg       sync_eob;
always @ (posedge clk128)
begin
      if      (!run)                 sync_eob <= 1'b0;
      else if (   eob   & !sync_eob) sync_eob <= 1'b1;
      else if (sr_eob[1] & sync_eob) sync_eob <= 1'b0;
end

reg [2:0] sr_eob;
always @ (posedge clk16)
begin
       sr_eob <= {sr_eob[1:0],sync_eob};
end

assign eob1s = active1 & sr_eob[1] & !sr_eob[2];
assign eob2s = active2 & sr_eob[1] & !sr_eob[2];

/////////////////////////////////////////////
// alignment module
rx_align          align(
.rxout        (rx_out),
.rxoutclock   (rx_outclock),
.rx_locked    (rx_locked),
.reset        (rxreset),
.aligni       (rx_chnl_data_align),
.aligno       (rx_ch_data_align)
);


/////////////////////////////////////////////////////////////////////////////////
//data returned from daq modules:
wire           rx_locked;
wire           rx_outclock;
wire  [35:0]   rx_out;
wire  [8:0]    rx_reset;
wire  [8:0]    rx_dpa_locked;
wire  [8:0]    rx_fifo_reset;
wire  [8:0]    rx_ch_data_align;


linki_v10          link (
.rx_locked     (rx_locked),
.rx_inclock    (linkinclk),
.rx_in         (linkin),
.rx_outclock   (rx_outclock),
.rx_out        (rx_out),
.rx_reset      (rx_reset),
.rx_dpa_locked (rx_dpa_locked),
.rx_fifo_reset (rx_fifo_reset),
.rx_channel_data_align (rx_ch_data_align),
.pll_areset     (rx_pll_reset)
);

wire   dpa_locked;
wire   rxreset;

wire   dpa_fifo_reset;
wire   rx_chnl_data_align;
wire   rx_pll_reset;


assign dpa_locked = (rx_dpa_locked==9'b111111111);
assign   rx_reset = rxreset ? 9'b111111111 : 9'b0;
assign rx_fifo_reset = dpa_fifo_reset ? 9'b111111111 : 9'b0;
//assign rx_ch_data_align = rx_chnl_data_align ? 9'b111111111 : 9'b0;

//synchronize the data to clk128:
wire  [35:0]   data;

datasync       synchronizer (
.init         (!run),
.inclk        (rx_outclock),
.datain       (rx_out),
.outclk       (clk128),
.dataout      (data)
);

// data transfer control:
wire       idle;
wire       val;
wire       space;
wire       block;

assign idle  = (data[35:32]==4'b0001);
assign val   = (data[35:32]==4'b1000); 
assign space = (data[35:32]==4'b1100);
//     tail  = (data[35:32]==4'b1110) ?

//32bit data with blk,dav,fst,lst flags:
reg        linkblk;
reg        linkdav;
reg        linkfst;
reg        linklst;
reg [31:0] linkdat;

always @ (posedge clk128)
begin
       if      (!run)          linkblk <= 1'b0;
       else if (val)           linkblk <= 1'b1;
       else if (idle)          linkblk <= 1'b0;
                          
       if      (!run)          linkdav <= 1'b0;
       else if (val & !space)  linkdav <= 1'b1;
       else                    linkdav <= 1'b0;
                            
        if    (val & !linkblk) linkfst <= 1'b1;
        else                   linkfst <= 1'b0;
        
        if    (idle & linkblk) linklst <= 1'b1;
        else                   linklst <= 1'b0; 
        
                               linkdat <= data[31:0];
                               test_data[3:0] <= data[35:32];
                               test_trig <= test_data[3] & !test_data[2] & !test_data[1]  & !test_data[0];           
end

wire        fst;
wire        lst;
wire        dav;
wire [31:0] dat;

wire        test1;
wire        test2;
wire        testdav;
wire        testfst;
wire        testlst;
wire [31:0] testdat;
wire        testblk;

//sync clk16 states to clk128:
reg       runs,active1s,active2s,test1s,test2s;
reg [4:0] modcounts;

always @ (posedge clk128)
begin
     runs      <= run;
     active1s  <= active1;
     active2s  <= active2;
     test1s    <= test1;
     test2s    <= test2;
     modcounts <= modcount;
end

assign block = !(test1s | test2s) ? linkblk : testblk;
assign   dav = !(test1s | test2s) ? linkdav : testdav;
assign   fst = !(test1s | test2s) ? linkfst : testfst;
assign   lst = !(test1s | test2s) ? linklst : testlst;
assign   dat = !(test1s | test2s) ? linkdat : testdat;

//define the beginning (bob) and end of the event block (eob):
reg  [4:0] blkcount;
reg        bob;

always @ (posedge clk128)
begin
     if       (!run)                    blkcount <= 4'd0;
     else if  (!(active1s | active2s))  blkcount <= 4'd0;
     else if  (lst)                     blkcount <= blkcount + 4'd1;

     if       (fst & (blkcount==5'b0))       bob <= 1'b1;
     else                                    bob <= 1'b0;
            
     if       (lst & (blkcount==modcounts))  eob <= 1'b1;
     else                                    eob <= 1'b0;     
end

//triggered or test data to the optics transmitter:
wire        block1;
wire        dav1;
wire        fst1;
wire        lst1;
wire [31:0] dat1;
wire        bob1;
wire        eob1;

assign block1 = (active1s | test1s) & block;
assign   dav1 = (active1s | test1s) & dav;
assign   fst1 = (active1s | test1s) & fst;
assign   lst1 = (active1s | test1s) & lst;
assign   dat1 = (active1s | test1s) ? dat : 32'd0;
assign   bob1 = (active1s | test1s) & bob;
assign   eob1 = (active1s | test1s) & eob;

wire [1:0]  gxb_tx1;
wire        busy1;
wire        xmit1_locked;
wire        xmit2_locked;
wire        tx_digitalreset;

wire [7:0]  t1_err_c_counter;
wire [7:0]  t1_err_d_counter;
wire [7:0]  t2_err_c_counter;
wire [7:0]  t2_err_d_counter;


transmit_neu_split      transmit_1 (
.run          (runs),
.clk128       (clk128),
.clk192       (clk192),
.clk48        (clk48),
.xtal         (xtal),
.bob          (bob1),
.block        (block1),
.fst          (fst1),
.lst          (lst1),
.dav          (dav1),
.data         (dat1),
.eob          (eob1),
.pll_locked   (xmit1_locked),
.tx_digitalreset (tx_digitalreset),
.gxb_tx       (gxb_tx1),
.gxb_rx       (gxb_rx1),
.busyout      (busy1),
.opt1_status  (opt1_status_n),
.opt2_status  (opt2_status_n),
.tp1          (tr_tp1),
.err_corrected_counter  (t1_err_c_counter),
.err_detected_counter  (t1_err_d_counter),
.coreclockout_out (coreclockout),
.txrdempty_f_in (txrdempty_f),
.wrusedw_f_in (wrusedw_f),
.tx_datain_f_in (tx_datain_f),
.cntrl_1_f_in(cntrl_1_f),
.ctrl_f_in (ctrl_f),
.busy_out (busy_neu_split)
); 
wire coreclockout;
wire txrdempty_f;
wire listq_f;
wire fstq_f;
wire [13:0] wrusedw_f;
wire [15:0] tx_datain_f;
wire cntrl_1_f;
wire ctrl_f;
wire busy_neu_split;


wire        tr_tp1;
wire        tr_tp2;

//supernova or test data to the optics transmitter:
wire        block2;
wire        dav2;
wire        fst2;
wire        lst2;
wire [31:0] dat2;
wire        bob2;
wire        eob2;

assign block2 = (active2s | test2s) & block;
assign   dav2 = (active2s | test2s) & dav;
assign   fst2 = (active2s | test2s) & fst;
assign   lst2 = (active2s | test2s) & lst;
assign   dat2 = (active2s | test2s) ? dat : 32'd0;
assign   bob2 = (active2s | test2s) & bob;
assign   eob2 = (active2s | test2s) & eob;

wire [1:0]  gxb_tx2;
wire        busy2;

wire [31:0] sn_data;
wire        sn_valid;

transmit       transmit_2 (
.run           (runs),
.clk128        (clk128),
.clk192        (clk192),
.clk48         (clk48),
.xtal          (xtal),
.bob           (bob2),
.block         (block2),
.fst           (fst2),
.lst           (lst2),
.dav           (dav2),
.data          (dat2),
.eob           (eob2),
.pll_locked    (xmit2_locked),
.tx_digitalreset (tx_digitalreset),
.gxb_tx        (gxb_tx2),
.gxb_rx        (gxb_rx2),
.busyout       (busy2),
.opt1_status  (opt1_status_s),
.opt2_status  (opt2_status_s),
.tp1           (tr_tp2),
.err_corrected_counter  (t2_err_c_counter),
.err_detected_counter  (t2_err_d_counter),
.coreclockout_in (coreclockout),
.txrdempty_f_out (txrdempty_f),
.wrusedw_f_out (wrusedw_f),
.tx_datain_f_out (tx_datain_f),
.cntrl_1_f_out (cntrl_1_f),
.ctrl_f_out (ctrl_f),
.busy_in (busy_neu_split)
);

//slow control from the backplane bus:
wire  [4:0]    modcount;
wire  [4:0]    crate;
wire           fsto;
wire           lsto;
wire           davo;
wire  [15:0]   dato;
wire           rdstatus;
wire           rdcounters;

slowcontrol    slow (
.clk16        (clk16),
.bytin        (bytin),
.modcount     (modcount),
.crate        (crate),
.en1          (en1),
.en2          (en2),
.test1        (test1),
.test2        (test2),
.fsto         (fsto),
.lsto         (lsto),
.davo         (davo),
.dato         (dato),
.rdstatus     (rdstatus),
.rxreset      (rxreset),
.rdcounters   (rdcounters),
.tx_digitalreset (tx_digitalreset),
.dpa_fifo_reset (dpa_fifo_reset),
.rx_chnl_data_align (rx_chnl_data_align),
.rx_pll_reset (rx_pll_reset),
.hist_read    (hist_read)
);

//the testdata generator:
datagenerator1 datagen (
.clk16        (clk16),
.clk128       (clk128),
.init         (!run),
.fsti         (fsto),
.lsti         (lsto),
.davi         (davo),
.dati         (dato),
.fsto         (testfst),
.lsto         (testlst),
.davo         (testdav),
.dato         (testdat),
.blko         (testblk)
);

//readback to the backplane bus:
wire        read_counters;
wire [9:0]  byto_counters;
wire        read_status;
wire [9:0]  byto_status;
wire [15:0] status;

readback_counters  rdbk_counters (
.clk16       (clk16),
.crate       (crate),
.rd          (rdcounters),
.framecount  (framecount),
.eventcount  (eventcount),
.read1count  (read1count),
.read2count  (read2count),
.read        (read_counters),
.bytout      (byto_counters),
.t1_err_c_counter  (t1_err_c_counter),
.t1_err_d_counter  (t1_err_d_counter),
.t2_err_c_counter  (t2_err_c_counter),
.t2_err_d_counter  (t2_err_d_counter),
.hist_wcount       (hist_wcount)
);

readback_status3 rdbk_status (
.clk16      (clk16),
.clk128     (clk128),
.init       (!run),
.crate      (crate),
.rd         (rdstatus),
.active1    (active1),
.active2    (active2),
.read1count (read1count),
.read2count (read2count),
.eob1       (eob1s),
.eob2       (eob2s),
.linkword   (linkdat[11:0]),
.linkfst    (linkfst),
.linkdav    (linkdav),
.rx_locked  (rx_locked),
.locked     (locked),
.xmit1_locked (xmit1_locked),
.xmit2_locked (xmit2_locked),
.dpa_locked (dpa_locked),
.read       (read_status),
.bytout     (byto_status),
.error      (error),
.opt1_status_n (opt1_status_n),
.opt2_status_n (opt2_status_n),
.opt1_status_s (opt1_status_s),
.opt2_status_s (opt2_status_s),
.busy_n        (busy1),
.busy_s        (busy2)
);

wire [10:0]     hist_wcount;
wire            hist_read;
wire [9:0]      hist_byout;
wire            hist_rout;

history      hist_silo (
.clk16          (clk16),
.clk_counter    (clk_counter),
.token1         (token1),
.token2         (token2),
.busy1          (busy1),
.busy2          (busy2),
.trig           (trig),
.framecount     (framecount),
.hist_read      (hist_read),
.run            (run),
.hist_wcount    (hist_wcount),
.hist_byout     (hist_byout),
.crate          (crate),
.read           (hist_rout)
);



wire [9:0]  muxo;
reg  [9:0]  bytout;

assign muxo = (read_status   ? byto_status   : 10'b0) |
              (hist_rout     ? hist_byout    : 10'b0) |
              (read_counters ? byto_counters : 10'b0) ;

//assign muxo = (read_status   ? byto_status   : 10'b0) |
//              (read_counters ? byto_counters : 10'b0) ;

always @ (posedge clk16)
begin
       bytout <=muxo;
end

endmodule
