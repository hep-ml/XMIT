framelength = 17
words = []
with open('TP_FRAMES.txt') as my_file:
    for word in my_file:
        words.append(word.strip('\n')[::-1]) #Reverse list
# print("Number of frames: " + str(len(words)))
TPFs = []
Labels = ['LENGTH','CHANNEL','EVENTNO','FRAMENO','TIMETICK','TOT1','TOT2','TOT3','INTN','IOT1','IOT2','IOT3','INT','AMP']
for i in range(0,len(words)):
	frame = []
	for j in range(0,framelength):
		frame.append(words[i][j*16:(j+1)*16])
	TPFs.append([])
	lengthofroi_bin = frame[1][0:8]+frame[0]
	TPFs[i].append(int(lengthofroi_bin[::-1],2))
	channel_bin = frame[13][8:14]
	TPFs[i].append(int(channel_bin[::-1],2))
	eventno_bin = frame[2]+frame[1][8:16]
	TPFs[i].append(int(eventno_bin[::-1],2))
	frameno_bin = frame[15][0:6]+frame[14][0:16]+frame[13][14:16]
	TPFs[i].append(int(frameno_bin[::-1],2))
	timetick_bin = frame[16][0:4]+frame[15][6:16]
	TPFs[i].append(int(timetick_bin[::-1],2))
	tot1_bin = frame[3][0:12]
	TPFs[i].append(int(tot1_bin[::-1],2))
#	tot2_bin = frame[4][0:8]+frame[3][12:16]
#	TPFs[i].append(int(tot2_bin[::-1],2))
	TPFs[i].append(0) # SIMPLIFIED
#	tot3_bin = frame[5][0:4]+frame[4][8:16]
#	TPFs[i].append(int(tot3_bin[::-1],2))
	TPFs[i].append(0) # SIMPLIFIED
	in_bin = frame[6][0:12]+frame[5][4:16]
	TPFs[i].append(int(in_bin[::-1],2))
#	iot1_bin = frame[8][0:4]+frame[7]+frame[6][12:16]
#	TPFs[i].append(int(iot1_bin[::-1],2))
	TPFs[i].append(0) # SIMPLIFIED
#	iot2_bin = frame[9][0:12]+frame[8][4:16]
#	TPFs[i].append(int(iot2_bin[::-1],2))
	TPFs[i].append(0) # SIMPLIFIED
#	iot3_bin = frame[11][0:4]+frame[10]+frame[9][12:16]
#	TPFs[i].append(int(iot3_bin[::-1],2))
	TPFs[i].append(0) # SIMPLIFIED
	integral_bin = frame[12][0:12]+frame[11][4:16]
	TPFs[i].append(int(integral_bin[::-1],2))
	amplitude_bin = frame[13][0:8]+frame[12][12:16]
	TPFs[i].append(int(amplitude_bin[::-1],2))

for TPF in TPFs:
	print('TPF')
	for i in range(0,len(TPF)):
		print(Labels[i]+","+str(TPF[i]))
	print('END')
