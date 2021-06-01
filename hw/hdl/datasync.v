//exp/microboone/xmit_module_2010/test_100923/linkcontrol/ sept23,2010
//(exp/phenix/dcm2/dcm_2s60_070115/dcm_2s60/link/   jan15,2006)

//Synchronizes 36bit data sent across two clock domains
//that share the same frequency but different phase.


module  datasync (
init,inclk,datain,outclk,dataout
);
input         init;
input         inclk;
input  [35:0] datain;
input         outclk;
output [35:0] dataout;

reg   [2:0]   wradd;
reg   [2:0]   addsync1,addsync2,rdadd;

always @ (posedge inclk)
begin
     if      (init)          wradd <= 3'b000;
     else if (wradd==3'b000) wradd <= 3'b001;
     else if (wradd==3'b001) wradd <= 3'b011;
     else if (wradd==3'b011) wradd <= 3'b010;
     else if (wradd==3'b010) wradd <= 3'b110;
     else if (wradd==3'b110) wradd <= 3'b111;
     else if (wradd==3'b111) wradd <= 3'b101;
     else if (wradd==3'b101) wradd <= 3'b100;
     else if (wradd==3'b100) wradd <= 3'b000;
end

always @ (posedge outclk)
begin
     addsync1 <= wradd;
     addsync2 <= addsync1;
     rdadd    <= addsync2;
end

dp8x36  dpram (
.wrclock    (inclk),
.wren       (!init),
.data       (datain),
.wraddress  (wradd),
.rdclock    (outclk),
.rdaddress  (rdadd),
.q          (dataout)
);

endmodule