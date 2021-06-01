//exp/microboone/xmit_module_2010/readcontrol_110601/readcontrol/  june3,2011

//emulates the datastream from a daq module.
//10 16bit-headerwords precede datawords.
//16bit data is gearshifted to 24bits and then hammingcoded to 30 bits.
//a fst flag is sent with the first header word.
//a lst flag is sent with the last data word, or with the last header word.

module datagenerator1 (
clk16,clk128,init,
fsti,lsti,davi,dati,
fsto,lsto,davo,dato,
blko
);

input         clk16;
input         clk128;
input         init;
input         fsti;   //fst flag      from slowcontrol
input         lsti;   //lst flag      from slowcontrol
input         davi;   //dav flag      from slowcontrol
input [15:0]  dati;   //16bit data    from slowcontrol
output        fsto;   //test data fst
output        lsto;   //test data lst
output        davo;   //test data dav
output [31:0] dato;   //test data dat
output        blko;   //test data blk

//synchronize the slow control input data to clk128:
wire          empty;
wire          qlst;
wire          qfst;
wire   [15:0] qdat;
wire          qdav;

fifo512x18 fifo (  //showahead fifo
.aclr    (init),
.wrclk   (clk16),
.wrreq   (davi),
.data    ({lsti,fsti,dati}),
.rdclk   (clk128),
.rdreq   (!empty),
.rdempty (empty),
.q       ({qlst,qfst,qdat})
);

reg        init128;
reg        count;
reg        selecthed;
reg        selectdat;
reg [3:0]  wordcount;
reg [15:0] dat;
reg        dav;
reg        fst;
reg        lst;

//separate the headerwords from the data:
always @ (posedge clk128)
begin
                                        init128 <= init;
                               
    if      (init128)                      count <= 1'b0;
    else if (!empty & qfst)                count <= 1'b1;
//    else if (dav & (wordcount==10) |  lst) count <= 1'b0;
    else if (dav & (wordcount==12) |  lst) count <= 1'b0;
       
    if      (init128)                  wordcount <= 4'b0;
    else if (dav & count)              wordcount <= wordcount + 4'b1; 
    else if (!count)                   wordcount <= 4'b0;                     
                                    
    if      (init128)                  selecthed <= 1'b0;
    else if (!empty & qfst)            selecthed <= 1'b1;
//    else if (dav & (wordcount==9))     selecthed <= 1'b0;
    else if (dav & (wordcount==11))     selecthed <= 1'b0;
       
    if      (init128)                     selectdat <= 1'b0;
    else if (!empty & qfst)               selectdat <= 1'b0;
//    else if (dav & !lst & (wordcount==9)) selectdat <= 1'b1;
    else if (dav & !lst & (wordcount==11)) selectdat <= 1'b1;
    else if (lst)                         selectdat <= 1'b0;
             
                                             dat <= qdat;
                                             dav <= !empty;
                                             fst <= !empty & qfst;
                                             lst <= !empty & qlst;
end

//the first 10 words are header data:
wire [15:0] heddat;
wire        heddav;
wire        hedfst;
wire        hedlst;

assign      heddat = selecthed ? dat : 16'b0;
assign      heddav = selecthed & dav;
assign      hedfst = selecthed & fst;
assign      hedlst = selecthed & lst;

wire  [15:0] dat16;
wire         dav16;
wire         fst16;
wire         lst16;

//the 16bitwords following the header are gearshifted to 24bits:
assign       dat16 = selectdat ? dat : 16'b0;
assign       dav16 = selectdat & dav;
//assign       fst16 = selectdat & dav & (wordcount==10);
assign       fst16 = selectdat & dav & (wordcount==12);
assign       lst16 = selectdat & lst;

wire  [23:0] dat24;
wire         dav24;
wire         fst24;
wire         lst24;

gear16to24  gear16_24 (
.init      (init128),
.clk128    (clk128),
.datin     (dat16),
.davin     (dav16),
.fstin     (fst16),
.lstin     (lst16),
.datout    (dat24),
.davout    (dav24),
.fstout    (fst24),
.lstout    (lst24)
);

//the 24bitwords are hammingcoded to 30bits:
wire  [29:0] hamdat;
reg          hamlst;
reg          hamdav;

always @ (posedge clk128)
begin
       hamdav <= dav24;
       hamlst <= lst24;
end

hammingcode encoder (
.clock     (clk128),
.data      (dat24),
.q         (hamdat)
);

//the 32bit output stream:
wire  [31:0] dato;
wire         davo;
wire         lsto;

assign       fsto = hedfst;
assign       davo = heddav | hamdav;
assign       lsto = hedlst | hamlst;
assign       dato = selecthed ? {16'b0,heddat} : {2'b00,hamdat};

reg       block;
wire      blko;
always @ (posedge clk128)
begin
       if      (init128)       block <= 1'b0;
       else if (!empty & qfst) block <= 1'b1;
       else if (lsto)          block <= 1'b0; 
end
assign blko = block;
                                    
endmodule
