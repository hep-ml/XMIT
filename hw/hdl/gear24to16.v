//exp/microboone/study2011/verify24to16_10123/verify24to16/ march8,2011
//convert the 24bit stream to a 16bit stream.
 
module  gear24to16 (init,
clk128,clk192,datin,davin,fstin,lstin,
datout,davout,fstout,lstout
);

input         init;
input         clk128;
input         clk192;
input [23:0]  datin;
input         davin;
input         fstin;
input         lstin;

output [15:0] datout;
output        fstout;
output        davout;
output        lstout;

reg   [1:0]   pair;
reg           co;
reg   [26:0]  x;
reg   [26:0]  y;

wire          load;
assign        load = co & (x[26] & y[26]);


wire   z /* synthesis keep */;
assign z = (x[15:0]==0) ;

always @ (posedge clk128)
begin
 if      (init)          x <= 27'd0;
 else if (davin)         x <= {davin,fstin,lstin,datin};
 else if (x[26] & y[26]) x <= 27'h0000000;

 if      (init)          y <= 27'd0;
 else if (davin & x[26]) y <= x;
 else if (x[26] & y[26]) y <= 27'h0000000;

  if      (init)                  pair <= 1'b0;
  else if (fstin)                 pair <= 2'b01;
  else if (davin & (pair==2'b01)) pair <= 2'b00;  
  else if (davin)                 pair <= pair + 2'b01;
  
  if      (pair==1)                 co <= 1'b1;
  else                              co <= 1'b0;
end


wire   rdack;
assign rdack = !empty & (seq==2);

wire         empty;
wire  [26:0] yo;
wire  [26:0] xo;
wire         zo;

reg  [1:0]  seq;
reg  [15:0] dato;
reg         fstout;
reg         davo;
reg         lsto;

fifi256x55  fifo ( //show-ahead fifo
.data({z,y,x}),
.wrreq(load),
.wrclk(clk128),
.rdclk(clk192),
.rdreq(rdack),
.rdempty(empty),
.q({zo,yo,xo})
);


always @ (posedge clk192)
begin
 if   (!empty & yo[26] & yo[25] & !xo[25] & (seq==0)) fstout <= 1'b1;
 else                                                 fstout <= 1'b0;
 
     if      (empty)                seq <= 2'b00;    
     else if (!empty & (seq==0))    seq <= 2'b01;
     else if (!empty & (seq==1))    seq <= 2'b10;
     else if (!empty & (seq==2))    seq <= 2'b00;     
           
     if      (!empty & (seq==0))   dato <= yo[23:8];
     else if (!empty & (seq==1))   dato <={yo[7:0],xo[23:16]};
     else if (!empty & (seq==2))   dato <= xo[15:0];
     else                          dato <= 16'h0000;
     
     if      (!empty & (seq==0))                             davo <= 1'b1;
     else if (!empty & (seq==1) & !(yo[24] & zo))            davo <= 1'b1;
     else if (!empty & (seq==2) & !((xo[24] | yo[24]) & zo)) davo <= 1'b1;
     else                                                    davo <= 1'b0;

     if      (!empty & (seq==0) & yo[24])        lsto <= 1'b1;
     else if (!empty & (seq==1) & xo[24] &  zo)  lsto <= 1'b1; 
     else if (!empty & (seq==2) & xo[24] & !zo)  lsto <= 1'b1; 
     else                                        lsto <= 1'b0;                               
end

wire   lstout;
assign lstout = lsto;

wire   davout;
assign davout = davo;

wire   [15:0] datout;
assign        datout = dato;

endmodule
