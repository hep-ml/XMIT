//exp/microboone/xmit_module)2010/test_100923/readcontrol_101007 may23,2011

// add history read command 8/30/2017

module  slowcontrol (
clk16,bytin,
modcount,crate,
en1,en2,test1,test2,
//blko,
fsto,lsto,davo,dato,
rdstatus,rdcounters,rxreset,tx_digitalreset,
dpa_fifo_reset,rx_chnl_data_align,rx_pll_reset,
hist_read
);

input         clk16;     //system 16Mhz
input  [9:0]  bytin;     //control from the backplane bus
output [4:0]  modcount;  //number of daq modules on the link
output [4:0]  crate;     //crate address

output        en1;       //enable readout of triggered data
output        en2;       //enable readout of supernova data
output        test1;     //enable test data to xmitter1
output        test2;     //enable test data to xmitter2
//output        blko;
output        fsto;      //test data fst flag
output        lsto;      //test data lst flag
output        davo;      //test data dav flag
output [15:0] dato;      //test data 16 bits

output        rdstatus;  //read status         to backplane bus
output        rdcounters;//read counter values to backplane bus
output        rxreset;   //reset dpa
output        tx_digitalreset; //reste xmitters digita logic

output        dpa_fifo_reset;  // reset DPA FIFO 
output        rx_chnl_data_align; //rx_channel_data_align pulse

output        rx_pll_reset;
output        hist_read;

reg    [9:0]  msbyt;
reg    [9:0]  lsbyt;
always @ (posedge clk16)
begin
        lsbyt <= bytin;
        msbyt <= lsbyt;
end

wire        fst;
wire        nxt;
wire        lst;
wire [15:0] dat;

assign  fst = (msbyt[9:8]==1)&(lsbyt[9:8]==0);
assign  nxt = (msbyt[9:8]==2)&(lsbyt[9:8]==0);
assign  lst = (msbyt[9:8]==3)&(lsbyt[9:8]==0);
assign  dat = {msbyt[7:0],lsbyt[7:0]};

reg  [7:0] op;
always @ (posedge clk16)
begin
      if      (fst)  op <= lsbyt[7:0];     
end

//states:
reg  [4:0]  modcount;
reg  [4:0]  crate;
reg         en1;
reg         en2;
reg         test1;
reg         test2;

always @ (posedge clk16)
begin
      if     (lst & (op==1))  modcount <= lsbyt[4:0];
      if     (lst & (op==2))       en1 <= lsbyt[0];
      if     (lst & (op==3))       en2 <= lsbyt[0];
      if     (lst & (op==4))     test1 <= lsbyt[0];
      if     (lst & (op==5))     test2 <= lsbyt[0];
      if     (lst & (op==6))     crate <= lsbyt[4:0];
end

//commands:
reg  rdstatus;
reg  rdcounters;
reg  rxreset;
reg  tx_digitalreset;
reg  dpa_fifo_reset;
reg  rx_chnl_data_align;

reg  rx_pll_reset;

reg  hist_read;

always @ (posedge clk16)
begin
     if  (lst & (op==20)) rdstatus <= 1'b1;
     else                 rdstatus <= 1'b0;
     
     if  (lst & (op==21)) rdcounters <= 1'b1;
     else                 rdcounters <= 1'b0;
     
     if  (lst & (op==22))    rxreset <= 1'b1;
     else                    rxreset <= 1'b0;
     
     if  (lst & (op==23)) tx_digitalreset <= 1'b1;
     else                 tx_digitalreset <= 1'b0;

	  if  (lst & (op==24)) dpa_fifo_reset <= 1'b1;
     else                 dpa_fifo_reset <= 1'b0;

	  if  (lst & (op==25)) rx_chnl_data_align <= 1'b1;
     else                 rx_chnl_data_align <= 1'b0;
	  
	  if  (lst & (op==26)) rx_pll_reset <= 1'b1;
     else                 rx_pll_reset <= 1'b0;

	  if  (lst & (op==29)) hist_read <= 1'b1;
     else                 hist_read <= 1'b0;
	  

end

//test data to the datagenerator:
reg         arm;
//reg         blko;
reg         fsto;
reg         davo;
reg         lsto;
reg  [15:0] dato;

always @ (posedge clk16)
begin
      if      (fst & (lsbyt[7:0]==10))   arm <= 1'b1;
      else if (nxt)                      arm <= 1'b0;
      
//      if      ((nxt & arm) & (op==10))  blko <= 1'b1;
//      else if (lsto)                    blko <= 1'b0; 
      
      if      ((nxt & arm) & (op==10))  fsto <= 1'b1;
      else                              fsto <= 1'b0;
      
      if      ((nxt | lst) & (op==10))  davo <= 1'b1;
      else                              davo <= 1'b0;
      
      if      ((nxt | lst) & (op==10))  dato <= dat[15:0];
      else                              dato <= 16'd0;
      
      if      ( lst        & (op==10))  lsto <= 1'b1;
      else                              lsto <= 1'b0;      
end

endmodule
