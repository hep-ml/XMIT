
//Time slices to divide the collection plane channels                                                                               
for(int timeind=3200; timeind <= 7800; timeind+=boxwidtime){
  timeind_vec.push_back(timeind);
 }

//Channel slices to divide the collection plane channels                                                                            
for(int chnlind=ColPlStartChnl; chnlind<(ColPlEndChnl+boxwidch); chnlind+=boxwidch){
  chnlind_vec.push_back(chnlind);
 }
for (int i=0; i<tp_list.size(); ++i){
  if ((tp_list[i].channel > chnlind_vec[boxchcnt]) or (i==tp_list.size()-1)){
    if(tmpchnl_vec.size()==0){
      while(tp_list[i].channel > chnlind_vec[boxchcnt]){
	boxchcnt+=1;
      }
    }
    else{
      for(int time_ind=0; time_ind < timeind_vec.size()-1; time_ind++){
	sublist.clear();
	for (int tmpch=0; tmpch < tmpchnl_vec.size(); tmpch++){
	  if ((tmpchnl_vec[tmpch].time_start >= timeind_vec[time_ind]) and (tmpchnl_vec[tmpch].time_start < timeind_vec[time_ind+1]))
	    {
	      sublist.push_back({tmpchnl_vec[tmpch].channel, tmpchnl_vec[tmpch].time_start, tmpchnl_vec[tmpch].adc_integral, tmpchnl_vec[tmpch].adc_peak, tmpchnl_vec[tmpch].time_over_threshold});
	    }
	}
	maxadc = 0;

	if(sublist.size()>0){
	  for (int sl=0; sl<sublist.size(); sl++){
	    if (sublist[sl].adc_integral> maxadc) {
	      maxadc =  sublist[sl].adc_integral;
	      maxadcind = sl;
	      if(maxadc > braggE){
		tp_list_maxadc.push_back({sublist[maxadcind].channel, sublist[maxadcind].time_start, sublist[maxadcind].adc_integral, sublist[maxadcind].adc_peak, sublist[maxadcind].time_over_threshold});

		maxadc = 0;
	      }}}}
      }
      tmpchnl_vec.clear();
    }}
  if (tp_list[i].channel > chnlind_vec[boxchcnt]) boxchcnt+=1;
  if (tp_list[i].channel <= chnlind_vec[boxchcnt] or i==tp_list.size()){

    tmpchnl_vec.push_back({tp_list[i].channel, tp_list[i].time_start, tp_list[i].adc_integral, tp_list[i].adc_peak, tp_list[i].time_over_threshold});
  }}
