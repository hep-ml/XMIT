//
//  history module  
//
//  log time stamp of various signal
//
module history (
clk16, token1, token2, busy1, busy2, trig, framecount,
run, hist_read, hist_wcount, hist_byout,crate,read,clk_counter
);

input         clk16;
input         token1;
input         token2;
input         busy1;
input         busy2;
input         trig;
input [23:0]  framecount;
input         run;
input         hist_read;
input [4:0]   crate; 
input [15:0]  clk_counter; 
output [9:0]  hist_byout;
output [10:0] hist_wcount;
output        read;

reg           busy1_d;
reg           busy1_d1;
reg           busy1_clip;
reg           busy2_d;
reg           busy2_d1;
reg           busy2_clip;

wire          wrreq;
wire [31:0]   fifo_d;

always @ (posedge clk16)
begin
	busy1_d <= busy1;
	busy1_d1 <= busy1_d;
	busy1_clip <= busy1_d & !busy1_d1;

	busy2_d <= busy2;
	busy2_d1 <= busy2_d;
	busy2_clip <= busy2_d & !busy2_d1;
end

assign wrreq = busy2_clip | busy1_clip | trig | token1 | token2;
assign fifo_d[31] = token1;
assign fifo_d[30] = token2;
assign fifo_d[29] = trig;
assign fifo_d[28] = busy1_clip;
assign fifo_d[27] = busy2_clip;
assign fifo_d[23:16] = framecount[7:0];
assign fifo_d[15:0] = clk_counter;

wire        rdempty;
wire        wrfull;
wire [31:0] hist_out;

history_fifo fifo1 (
.aclr    (!run),
.data    (fifo_d),
.rdclk   (clk16),
.rdreq   (hist_read),
.wrclk   (clk16),
.wrreq   (wrreq),
.q       (hist_out),
.rdempty (rdempty),
.rdusedw (hist_wcount),
.wrfull  (wrfull)
);


reg          rd;

reg          read;
reg  [3:0]   count;


always @ (posedge clk16)
begin

	  rd <= hist_read;
	  
     if      (rd)         read <= 1'b1;
//     else if (count==14)  read <= 1'b0;
//     else if (count==24)  read <= 1'b0;
       else if (count==8)  read <= 1'b0;
     
     if      (!read)     count <= 4'b0;
     else if (read)      count <= count + 4'b1;
end

wire [9:0] hist_byout;

assign hist_byout = 
                (count==1  ? {2'b01,8'hff}           : 10'b0) |
                (count==2  ? {2'b00,3'b0,crate}      : 10'b0) |
					 (count==3  ? {2'b10,8'h55}           : 10'b0) | 
					 (count==4  ? {2'b00,8'haa}           : 10'b0) | 
 
                (count==5  ? {2'b10,hist_out[15:8]}  : 10'b0) |                                        
                (count==6  ? {2'b00,hist_out[7:0]}   : 10'b0) |
					 (count==7  ? {2'b11,hist_out[31:24]} : 10'b0) |
                (count==8  ? {2'b00,hist_out[23:16]} : 10'b0);

                

                
endmodule

