
framelength = 17
words = []
with open('TP_FRAMES.txt') as my_file:
    for word in my_file:
        words.append(word.strip('\n'))#[::-1]) #Reverse list
# print("Number of frames: " + str(len(words)))
TPFs = []
Labels = ['LENGTH','CHANNEL','EVENTNO','FRAMENO','TIMETICK','TOT1','TOT2','TOT3','INTN','IOT1','IOT2','IOT3','INT','AMP']

print words[0]
print words[1]
print words[2]
print words[3]
print words[4]
print words[5]
print words[6]
print words[7]
print words[8]
print words[9]
print words[10]
### VALIDITYCHECK
state = 0 # header
cnt = 0
slot_address = None
i = 0
for word in words:
	if state == 0:
		if cnt == 0:
			if word == "1111111111111111":
				cnt += 1
				print("FEMStart")
		else:
			if word == "1111111111111111":
				cnt = 0
				state = 1
	elif state == 1:
		if word[0:4] == "1111":
			print word,cnt,state,i
			if cnt == 1:
				slot_address = int(word[-4:],2)
				print "Slot address", slot_address
			elif cnt == 2:
				n_words_bin = word[-4:]
			elif cnt == 3:
				n_words = int(word[-4:] + n_words_bin,2)
				print "Number of ADC words", n_words
			elif cnt == 4:
				eventno_bin = word[-4:]
			elif cnt == 5:
				eventno = int(word[-4:] + eventno_bin,2)
				print "Event no", eventno 
			elif cnt == 6:
				frameno_bin = word[-4:]
			elif cnt == 7:
				frameno = int(word[-4:] + frameno_bin,2)
				print "Frame no", frameno
			if cnt < 12:
				cnt += 1
			else:
				cnt = 0
				state = 2
	i += 1
