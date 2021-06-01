//exp/microboone/aria_2011/study_link?rx_align_110816/  aug17,2011
//EP1AGX20cf484c6

//alignment logic for aria linkin.
//requires a 1000 input pattern sent to each linkin input.

// update the alcount to 4 bits     -- change 6/18/2011 -- chi
// update donex checking waiting from alcount>5 from 3
// update selx increment from alcount>5 from 3
// this is done so if incoming data is already aligned. The align pulse will send out 
// and donex bits will set before data return 


module rx_align (
rxoutclock,rxout,rx_locked,
reset,aligni,
aligno
);

input [35:0]  rxout;      //from linkin
input         rxoutclock; //from linkin
input         rx_locked;  //from linkin
input         reset;      //from slowcontrol
input         aligni;     //from slowcontrol
output [8:0]  aligno;     //to   linkin (rx_channel_data_align)


//slowcontrol starts the alignment sequence with aligni:
wire          outclock;
reg    [15:0] sr;
wire          start;

always @ (posedge rxoutclock)
begin
        sr[15:0] <= {sr[14:0],aligni};
end
assign  start = sr[15];

//bitslip patterns (to rx_channel_data_align) for the 9 serial inputs:
wire [8:0] aligno;
reg        al0,al1,al2,al3,al4,al5,al6,al7,al8;
                
assign aligno = al0 ? {1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1} : 9'b0 |
                al1 ? {1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0} : 9'b0 |
                al2 ? {1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0} : 9'b0 |
                al3 ? {1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0} : 9'b0 |                
                al4 ? {1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0} : 9'b0 |               
                al5 ? {1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0} : 9'b0 |
                al6 ? {1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0} : 9'b0 |
                al7 ? {1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0} : 9'b0 |
                al8 ? {1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0} : 9'b0 ;

//alignment test rxout=1000 for each of the 9 serial inputs:
wire    load0,load1,load2,load3,load4,load5,load6,load7,load8;

assign  load0 = (rxout[3:0]  ==4'b0001);
assign  load1 = (rxout[7:4]  ==4'b0001);
assign  load2 = (rxout[11:8] ==4'b0001);
assign  load3 = (rxout[15:12]==4'b0001);
assign  load4 = (rxout[19:16]==4'b0001);
assign  load5 = (rxout[23:20]==4'b0001);
assign  load6 = (rxout[27:24]==4'b0001);
assign  load7 = (rxout[31:28]==4'b0001);
assign  load8 = (rxout[35:32]==4'b0001);

reg          alsync;
reg   [3:0]  alcount;
reg          done0,done1,done2,done3,done4,done5,done6,done7,done8;
reg   [3:0]  sel;

always @ (posedge rxoutclock)
begin
//alignment generator:
   if      (!rx_locked)                   alsync <= 1'b0;
   else if (reset)                        alsync <= 1'b0;
   else if (start)                        alsync <= 1'b1;
   else if (done8 & load8 & (alcount>3))  alsync <= 1'b0;
   else                                   alsync <= alsync;

   if      (!rx_locked)         alcount <= 4'b0000;  
   else if (!alsync)            alcount <= 4'b0000;
   else if (alsync)             alcount <= alcount + 4'b0001;

//repeat alignment fo each of the 9 serial inputs:
   if      (!rx_locked)                           sel <= 4'b0000;
   else if (!alsync)                              sel <= 4'b0000;
   else if ((sel==0) & load0 & (alcount>5))       sel <= 4'b0001;
   else if ((sel==1) & load1 & (alcount>5))       sel <= 4'b0010;
   else if ((sel==2) & load2 & (alcount>5))       sel <= 4'b0011;
   else if ((sel==3) & load3 & (alcount>5))       sel <= 4'b0100;
   else if ((sel==4) & load4 & (alcount>5))       sel <= 4'b0101;
   else if ((sel==5) & load5 & (alcount>5))       sel <= 4'b0110;
   else if ((sel==6) & load6 & (alcount>5))       sel <= 4'b0111;
   else if ((sel==7) & load7 & (alcount>5))       sel <= 4'b1000;
   else if ((sel==8) & load8 & (alcount>5))       sel <= 4'b1001;

//alignment if rxout[]=1000:   
   if      (!rx_locked)                              done0 <= 1'b0;
   else if (!alsync)                                 done0 <= 1'b0;
   else if (alsync & load0 & (sel==0) & (alcount>5)) done0 <= 1'b1;
   
   if      (!rx_locked)                              done1 <= 1'b0;
   else if (!alsync)                                 done1 <= 1'b0;
   else if (alsync & load1 & (sel==1) & (alcount>5)) done1 <= 1'b1;

   if      (!rx_locked)                              done2 <= 1'b0;
   else if (!alsync)                                 done2 <= 1'b0;
   else if (alsync & load2 & (sel==2) & (alcount>5)) done2 <= 1'b1;
  
   if      (!rx_locked)                              done3 <= 1'b0;
   else if (!alsync)                                 done3 <= 1'b0;
   else if (alsync & load3 & (sel==3) & (alcount>5)) done3 <= 1'b1;

   if      (!rx_locked)                              done4 <= 1'b0;
   else if (!alsync)                                 done4 <= 1'b0;
   else if (alsync & load4 & (sel==4) & (alcount>5)) done4 <= 1'b1;
   
   if      (!rx_locked)                              done5 <= 1'b0;
   else if (!alsync)                                 done5 <= 1'b0;
   else if (alsync & load5 & (sel==5) & (alcount>5)) done5 <= 1'b1;

   if      (!rx_locked)                              done6 <= 1'b0;
   else if (!alsync)                                 done6 <= 1'b0;
   else if (alsync & load6 & (sel==6) & (alcount>5)) done6 <= 1'b1;
  
   if      (!rx_locked)                              done7 <= 1'b0;
   else if (!alsync)                                 done7 <= 1'b0;
   else if (alsync & load7 & (sel==7) & (alcount>5)) done7 <= 1'b1;
   
   if      (!rx_locked)                              done8 <= 1'b0;
   else if (!alsync)                                 done8 <= 1'b0;
   else if (alsync & load8 & (sel==8) & (alcount>5)) done8 <= 1'b1;  
   
   
//pulse each of the 9 bitslip patterns:
   if      (!alsync)                           al0 <= 1'b0;
   else if ((alcount==1) & (sel==0) & !done0)  al0 <= 1'b1;
   else if (alcount>2)                         al0 <= 1'b0;
   
   if      (!alsync)                           al1 <= 1'b0;
   else if ((alcount==1) & (sel==1) & !done1)  al1 <= 1'b1;
   else if (alcount>2)                         al1 <= 1'b0;

   if      (!alsync)                           al2 <= 1'b0;
   else if ((alcount==1) & (sel==2) & !done2)  al2 <= 1'b1;
   else if (alcount>2)                         al2 <= 1'b0;

   if      (!alsync)                           al3 <= 1'b0;
   else if ((alcount==1) & (sel==3) & !done3)  al3 <= 1'b1;
   else if (alcount>2)                         al3 <= 1'b0;

   if      (!alsync)                           al4 <= 1'b0;
   else if ((alcount==1) & (sel==4) & !done4)  al4 <= 1'b1;
   else if (alcount>2)                         al4 <= 1'b0;

   if      (!alsync)                           al5 <= 1'b0;
   else if ((alcount==1) & (sel==5) & !done5)  al5 <= 1'b1;
   else if (alcount>2)                         al5 <= 1'b0;

   if      (!alsync)                           al6 <= 1'b0;
   else if ((alcount==1) & (sel==6) & !done6)  al6 <= 1'b1;
   else if (alcount>2)                         al6 <= 1'b0;

   if      (!alsync)                           al7 <= 1'b0;
   else if ((alcount==1) & (sel==7) & !done7)  al7 <= 1'b1;
   else if (alcount>2)                         al7 <= 1'b0;

   if      (!alsync)                           al8 <= 1'b0;
   else if ((alcount==1) & (sel==8) & !done8)  al8 <= 1'b1;
   else if (alcount>2)                         al8 <= 1'b0;        
end

endmodule


