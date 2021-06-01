//exp/microboone/xmit_module_2011/readcontrol/  may20,2011

// add hamming code error / detection counter and 
// history fifo word count readout     8/30/2017

module  readback_counters (
clk16,crate,rd,
framecount,eventcount,
read1count,read2count,
read,bytout,
t1_err_c_counter,t1_err_d_counter,
t2_err_c_counter,t2_err_d_counter,
hist_wcount
);

input         clk16;
input  [4:0]  crate;
input         rd;
input  [23:0] framecount;
input  [23:0] eventcount;
input  [23:0] read1count;
input  [23:0] read2count;
input   [7:0] t1_err_c_counter;
input   [7:0] t1_err_d_counter;
input   [7:0] t2_err_c_counter;
input   [7:0] t2_err_d_counter;
output        read;
output [9:0]  bytout;
input  [10:0] hist_wcount;

reg    [23:0] framecnt;
reg    [23:0] eventcnt;
reg    [23:0] read1cnt;
reg    [23:0] read2cnt;

reg   [7:0] t1_err_c_cnt;
reg   [7:0] t1_err_d_cnt;
reg   [7:0] t2_err_c_cnt;
reg   [7:0] t2_err_d_cnt;

always @ (posedge clk16)
begin
      if   (rd) framecnt <= framecount;
      if   (rd) eventcnt <= eventcount;
      if   (rd) read1cnt <= read1count;
      if   (rd) read2cnt <= read2count;
//      if   (rd) read2cnt <= 24'haabbcc;

		if   (rd) t1_err_c_cnt <= t1_err_c_counter;
		if   (rd) t1_err_d_cnt <= t1_err_d_counter;
		if   (rd) t2_err_c_cnt <= t2_err_c_counter;
		if   (rd) t2_err_d_cnt <= t2_err_d_counter;
		
		if   (rd) hist_wcnt <= hist_wcount;

end

reg  [10:0]  hist_wcnt;
reg          read;
reg  [4:0]   count;
wire [9:0]   bytout;

always @ (posedge clk16)
begin
     if      (rd)         read <= 1'b1;
//     else if (count==14)  read <= 1'b0;
     else if (count==28)  read <= 1'b0;
     
     if      (!read)     count <= 4'b0000;
     else if (read)      count <= count + 4'b0001;
end

assign bytout = (count==1  ? {2'b01,8'hff}           : 10'b0) |
                (count==2  ? {2'b00,3'b0,crate}      : 10'b0) |
					 (count==3  ? {2'b10,8'h55}           : 10'b0) | 
					 (count==4  ? {2'b00,8'haa}           : 10'b0) | 
 
                (count==5  ? {2'b10,framecnt[15:8]}  : 10'b0) |                                        
                (count==6  ? {2'b00,framecnt[7:0]}   : 10'b0) |
					 (count==7  ? {2'b10,8'h00}           : 10'b0) |
                (count==8  ? {2'b00,framecnt[23:16]} : 10'b0) |

                (count==9  ? {2'b10,eventcnt[15:8]}  : 10'b0) |                                        
                (count==10 ? {2'b00,eventcnt[7:0]}   : 10'b0) |
					 (count==11 ? {2'b10,8'h00}           : 10'b0) |
                (count==12 ? {2'b00,eventcnt[23:16]} : 10'b0) |

                (count==13 ? {2'b10,read1cnt[15:8]}  : 10'b0) |                                        
                (count==14 ? {2'b00,read1cnt[7:0]}   : 10'b0) |
					 (count==15 ? {2'b10,8'h00}           : 10'b0) |
                (count==16 ? {2'b00,read1cnt[23:16]} : 10'b0) |

                (count==17 ? {2'b10,read2cnt[15:8]}  : 10'b0) |                                        
                (count==18 ? {2'b00,read2cnt[7:0]}   : 10'b0) |
					 (count==19 ? {2'b11,8'h00}           : 10'b0) |
                (count==20 ? {2'b00,read2cnt[23:16]} : 10'b0) |
  
                (count==21 ? {2'b10,t1_err_d_cnt[7:0]}  : 10'b0) |  
                (count==22 ? {2'b00,t1_err_c_cnt[7:0]}  : 10'b0) |  
                (count==23 ? {2'b10,t2_err_d_cnt[7:0]}  : 10'b0) |  
                (count==24 ? {2'b00,t2_err_c_cnt[7:0]}  : 10'b0) |
					 
                (count==25 ? {2'b10,5'b0,hist_wcnt[10:8]}  : 10'b0) |  
                (count==26 ? {2'b00,hist_wcnt[7:0]}  : 10'b0) |  
                (count==26 ? {2'b00,hist_wcnt[7:0]}  : 10'b0) |  
                (count==27 ? {2'b11,8'h00}  : 10'b0) |  
                (count==28 ? {2'b00,8'h00}  : 10'b0);


              
//                (count==3  ? {2'b10,framecnt[23:16]} : 10'b0) |                                        
//                (count==4  ? {2'b00,framecnt[15:8]}  : 10'b0) |
//                (count==5  ? {2'b10,framecnt[7:0]}   : 10'b0) |
                
//                (count==6  ? {2'b00,eventcnt[23:16]} : 10'b0) |                
//                (count==7  ? {2'b10,eventcnt[15:8]}  : 10'b0) |
//                (count==8  ? {2'b00,eventcnt[7:0]}   : 10'b0) |
                
//                (count==9  ? {2'b10,read1cnt[23:16]} : 10'b0) |                
//                (count==10 ? {2'b00,read1cnt[15:8]}  : 10'b0) |
//                (count==11 ? {2'b10,read1cnt[7:0]}   : 10'b0) |
                
//                (count==12 ? {2'b00,read2cnt[23:16]} : 10'b0) |
//                (count==13 ? {2'b11,read2cnt[15:8]}  : 10'b0) |
//                (count==14 ? {2'b00,read2cnt[7:0]}   : 10'b0) ;
					 
//assign bytout = (count==0  ? {2'b01,8'hff}           : 10'b0) |
//                (count==1  ? {2'b00,3'b0,crate}      : 10'b0) |
//					 (count==2  ? {2'b10,8'h55}           : 10'b0) | 
//					 (count==3  ? {2'b00,8'haa}           : 10'b0) | 


//                (count==4  ? {2'b10,8'hbb} : 10'b0) |                                        
//                (count==5  ? {2'b00,8'hcc} : 10'b0) |
//					 (count==6  ? {2'b10,8'h00} : 10'b0) |
//                (count==7  ? {2'b00,8'haa} : 10'b0) |
                
//                (count==3  ? {2'b10,framecnt[23:16]} : 10'b0) |                                        
//                (count==4  ? {2'b00,framecnt[15:8]}  : 10'b0) |
//                (count==5  ? {2'b10,framecnt[7:0]}   : 10'b0) |
                
//                (count==8  ? {2'b10,eventcnt[23:16]} : 10'b0) |                
//                (count==9  ? {2'b00,eventcnt[15:8]}  : 10'b0) |
//                (count==10  ? {2'b10,eventcnt[7:0]}   : 10'b0) |
                
//                (count==11  ? {2'b00,read1cnt[23:16]} : 10'b0) |                
//                (count==12 ? {2'b11,read1cnt[15:8]}  : 10'b0) |
//                (count==13 ? {2'b00,read1cnt[7:0]}   : 10'b0) ;
                
 //               (count==11 ? {2'b00,read2cnt[23:16]} : 10'b0) |
 //               (count==12 ? {2'b11,read2cnt[15:8]}  : 10'b0) |
 //               (count==13 ? {2'b00,read2cnt[7:0]}   : 10'b0) ;
                
endmodule
