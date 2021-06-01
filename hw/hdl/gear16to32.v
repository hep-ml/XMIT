//exp/microboone/xmit_module_2010/junk2/  apri20,2011

//converts 16bit stream to a 32bit stream.

module gear16to32 (
clk,init,
davi,fsti,dati,lsti,
dav,datms,datls,lst,fst
);

input         clk;
input         init;
input         davi;
input         fsti;
input         lsti;
input  [15:0] dati;

output        dav;
output [15:0] datms;
output [15:0] datls;
output        lst;
output        fst;


reg    [18:0] a;
reg    [18:0] b;
reg    [31:0] c;
reg           dav;
reg           lst;
reg           fst;
reg           udel;

wire          ld;
assign        ld = (a[16] & b[16]) | b[17];

always @ (posedge clk)
begin
      if      (init)          a <= 19'b0;
      else if (davi)          a <= {fsti,lsti,1'b1,dati};
      else if (ld)            a <= 19'b0;
      else if (a[17]&!b[17])  a <= 19'b0;
      
      if      (init)          b <= 19'b0;
      else if (fsti)          b <= 19'b0;
      else if (ld)            b <= 19'b0;
      else if (davi & a[16])  b <= a;
      else if (a[17]& !b[17]) b <= a;

      if      (init)          c <= 32'b0;
      else if (ld)            c <= {a[15:0],b[15:0]};
      
      if      (a[17] & !b[16]) udel <= 1'b1;
      else if (udel)           udel <= 1'b0;
      else                     udel <= 1'b0;      
      
      if      (ld)                  fst <= b[18];
      else                          fst <= 1'b0;
      
      if      ((a[17] & ld) | udel) lst <= 1'b1;
      else                          lst <= 1'b0;
           
                                    dav <= ld;
end

assign  datms = c[31:16];
assign  datls = c[15:0];

endmodule
