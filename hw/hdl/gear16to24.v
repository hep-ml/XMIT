//exp/microboone/study2011/verify24to16_101231/verify24to16/  april26,2011
//changes a 16bit data-stream into a 24bit data-stream.
 
module  gear16to24 (init,
clk128,datin,davin,fstin,lstin,
datout,davout,fstout,lstout
);
//16bit stream:
input         init;
input         clk128;
input  [15:0] datin;
input         davin;
input         fstin;
input         lstin;

//24bit stream: 
output [23:0] datout;
output        davout;
output        fstout;
output        lstout;

//input fifo provides space for last words:
wire        lsti;
wire        fsti;
wire [15:0] dati;
wire        empty;
wire        ack;
wire        hold;
wire   ld;
reg  [18:0] a,b,c;
reg  [24:0] ab,bc;
reg  [24:0] abc;

fifo256x18  fifo ( //lookahead fifo
.data   ({lstin,fstin,datin}),
.wrreq  (davin),
.clock  (clk128),
.empty  (empty),
.rdreq  (ack),
.q      ({lsti,fsti,dati})
);
assign ack = !empty & !hold;
assign hold = a[17] | b[17];
assign ld = (a[18] & b[18] & c[18]);

always @ (posedge clk128)
begin
  if      (init)                          a <= 19'd0;      
  else if (ack & !lsti)                   a <= {1'b1,1'b0,fsti,dati[15:0]};
  else if (ack &  lsti)                   a <= {1'b1,1'b1,1'b0,dati[15:0]};
  else if (a[17] & !b[18] & !c[18])       a <= {1'b1,18'd0};
  else if (b[17] &          !c[18])       a <= {1'b1,18'd0};
  else if (a[17] &  b[18] & !c[18])       a <= {1'b1,18'd0};
  else if (ld)                            a <= 19'h00000;
 
  if      (init)                          b <= 19'd0;   
  else if (ack & fsti)                    b <= 19'h00000;
  else if (ld)                            b <= 19'h00000;    
  else if (ack & a[18])                   b <= a[18:0];
  else if (a[17] & !b[18] & !c[18])       b <= a[18:0];
  else if (b[17] &          !c[18])       b <= a[18:0];
  else if (a[17] &  b[18] & !c[18])       b <= a[18:0];

  if      (init)                          c <= 19'd0; 
  else if (ack & fsti)                    c <= 19'h00000;
  else if (ld)                            c <= 19'h00000;     
  else if (ack & a[18] & b[18])           c <= b[18:0];
  else if (a[17] & !b[18] & !c[18])       c <= b[18:0];
  else if (b[17] &          !c[18])       c <= b[18:0];
  else if (a[17] &  b[18] & !c[18])       c <= b[18:0];

  if      (init)                         bc <= 25'd0; 
  else if (ld)                           bc <= {c[18],c[15:0],b[15:8]};
  else if (ab[24] & bc[24])              bc <= 25'h000000;  

  if      (init)                         ab <= 25'd0;  
  else if (ld)                           ab <= {1'b1,b[7:0],a[15:0]};
  else if (ab[24] & !bc[24])             ab <= 25'h000000;

  if      (init)                        abc <= 25'd0;     
  else if (ab[24] & bc[24])             abc <= {bc};
  else if (ab[24] &!bc[24])             abc <= {ab};
  else                                  abc <= 25'h000000;     
end

reg    fst;
reg    fstout;
reg    lstflg;
reg    ulstflg;
reg    lstout;

always @ (posedge clk128)
begin
  if      (ld & (c[17:16]==2'b01))          fst <= 1'b1;
  else                                      fst <= 1'b0;
                                         fstout <= fst;

   if     (ld & (a[17] | b[17] | c[17])) lstflg <= 1'b1;
   else                                  lstflg <= 1'b0;   
                                        ulstflg <= lstflg;
                                         lstout <= ulstflg;

                                        lstout  <= ulstflg;                                   
end

wire [23:0] datout;
wire        davout;

assign datout = abc[23:0];
assign davout = abc[24];

endmodule
