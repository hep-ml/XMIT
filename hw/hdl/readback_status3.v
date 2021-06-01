//exp/microboone/xmit_module_2011/readcontrol/ june3,2011

//monitor trigger number alignment and lockup.
// fixed time out counter error 8/21/2017

module  readback_status3 (
clk16,clk128,crate,init,rd,
active1,active2,read1count,read2count,eob1,eob2,
linkword,linkfst,linkdav,
rx_locked,locked,dpa_locked,xmit1_locked,xmit2_locked,
read,bytout,error,opt1_status_n,opt2_status_n,
opt1_status_s,opt2_status_s,busy_n,busy_s
);

input         clk16;
input         clk128;
input [4:0]   crate;
input         init;
input         rd;

input         active1;
input         active2;
input  [23:0] read1count;
input  [23:0] read2count;
input  [11:0] linkword;
input         linkfst;
input         linkdav;
input         eob1;
input         eob2;

input         rx_locked;
input         dpa_locked;
input         locked;
input         xmit1_locked;
input         xmit2_locked;
output        read;
output [9:0]  bytout;
output        error;
input         opt1_status_n;
input         opt2_status_n;
input         opt1_status_s;
input         opt2_status_s;
input         busy_n;
input         busy_s;

//syncronize inputs to clk128:
reg           inits;     
reg           active1s;
reg           active2s;
reg    [23:0] read1counts;
reg    [23:0] read2counts;

always @ (posedge clk128)
begin
             inits <= init;
          active1s <= active1;
          active2s <= active2;
       read1counts <= read1count;
       read2counts <= read2count;
end

//test the header trigger number for alignment:
reg [2:0] hedwd;
reg       align1_err;
reg       align2_err;
wire      error;

wire   testwd4;
assign testwd4 = linkdav & (hedwd==4);

wire   testwd5;
assign testwd5 = linkdav & (hedwd==5);

always @ (posedge clk128)
begin
   if      (inits | !(active1s | active2s)) hedwd <= 3'b000;
   else if (linkfst)                        hedwd <= 3'b001;
   else if (linkdav & (hedwd==3'b001))      hedwd <= 3'b010;
   else if (linkdav & (hedwd==3'b010))      hedwd <= 3'b011;  
   else if (linkdav & (hedwd==3'b011))      hedwd <= 3'b100;   
   else if (linkdav & (hedwd==3'b100))      hedwd <= 3'b101;   
   else if (linkdav & (hedwd==3'b101))      hedwd <= 3'b000;   
   
  if       (inits)                                               align1_err <= 1'b0;    
  else if  (testwd4 & active1s & (read1counts[23:12]!=linkword)) align1_err <= 1'b1;
  else if  (testwd5 & active1s & (read1counts[11:0] !=linkword)) align1_err <= 1'b1;  

  if       (inits)                                               align2_err <= 1'b0;
  else if  (testwd4 & active2s & (read2counts[23:12]!=linkword)) align2_err <= 1'b1;
  else if  (testwd5 & active2s & (read2counts[11:0] !=linkword)) align2_err <= 1'b1;  
end

reg  align1_error;
reg  align2_error;
always @ (posedge clk16)
begin
      align1_error <= align1_err;
      align2_error <= align2_err;
end

//test for lockup:
reg  udel1;
reg  udel2;
reg  timer1;
reg  timer2;
reg  [19:0] counter1;
reg  [19:0] counter2;

reg         time1_error;
reg         time2_error;

always @ (posedge clk16)
begin
      udel1 <= active1;

      if      (init)               timer1 <= 1'b0;
      else if (active1 & !udel1)   timer1 <= 1'b1; 
      else if (active1 & eob1)     timer1 <= 1'b0;
      
      if      (init | !timer1)     counter1 <= 20'b0;
      else                         counter1 <= counter1 + 20'b1; 
      
      if      (init)               time1_error <= 1'b0;
      else if (counter1>20'he0000) time1_error <= 1'b1;
end

always @ (posedge clk16)
begin
      udel2 <= active2;

      if      (init)               timer2 <= 1'b0;
      else if (active2 & !udel2)   timer2 <= 1'b1; 
      else if (active2 & eob2)     timer2 <= 1'b0;
      
      if      (init | !timer2)     counter2 <= 20'b0;
      else                         counter2 <= counter2 + 20'b1;
      
      if      (init)               time2_error <= 1'b0;
      else if (counter2>20'he0000) time2_error <= 1'b1;        
end

assign error = align2_error | align1_error | time2_error | time1_error;

wire [15:0] status;
assign      status = {align2_error,
                      align1_error,
                      time2_error,
                      time1_error,
							 opt1_status_n,
							 opt2_status_n,
							 opt1_status_s,
							 opt2_status_s,
							 busy_n,
							 busy_s,
                      1'b0,
                      xmit2_locked,
                      xmit1_locked,
                      dpa_locked,
                      rx_locked,
                      locked                      
                     };

reg           read;
reg  [2:0]    count;
wire [9:0]    bytout;

always @ (posedge clk16)
begin
     if      (rd)        read <= 1'b1;
     else if (count==4)  read <= 1'b0;
     
     if      (!read)    count <= 3'b000;
     else if (read)     count <= count + 3'b001;
end

assign bytout = (count==1  ? {2'b01,8'hff}         : 10'b0) |
                (count==2  ? {2'b00,3'b0,crate}    : 10'b0) | 
                
                (count==3  ? {2'b11,status[15:8]}  : 10'b0) |
                (count==4  ? {2'b00,status[7:0]}   : 10'b0) ;
                
endmodule

