f = open("TP","r")
scale = 16 ## equals to hexadecimal
num_of_bits = 16
tot = 0
intgrl = 0
intgrlN = 0
tpcnt = 0
hdrcnt = 0
amp = 0
frm = 0
frmb = 0
for l in f:
	#print l
	for w in range(0,8):
		wf = l.split()[w]
		wrh = l.split()[w][4:]
		wlh = l.split()[w][0:4]
		wrb = bin(int(wrh, scale))[2:].zfill(num_of_bits)
		wlb = bin(int(wlh, scale))[2:].zfill(num_of_bits)
		wrd = int(wrh, 16)
		wld = int(wlh, 16)
		#print(wrd)
		if wf == "FFFFFFFF":
			hdrcnt = 0
		if (wf[0]=="F"):
			hdrcnt += 1
			#print("F WORD FOUND = " + str(hdrcnt))
			#if hdrcnt == 2:
				#print("NUM ADC WORDS = " + str(wrd) + str(wld))
			if hdrcnt == 5:
				if ((str(int(wrh[1:], 16)) + str(int(wlh[1:], 16))) != str(frm)):
					frm = str(int(wrh[1:]+wlh[1:], 16))
					frmb = bin(int(wrh[1:]+wlh[1:], 16))[2:].zfill(24)
					#print("FRAME NUM = " + frm + " bin    " + frmb)
					#print("FRAME NUM = " + str(int(wrh[1:], 16)) + str(int(wlh[1:], 16)))
	#			print("FRAME NUM = " + str(wrh[1:]) + str(wlh[1:]))
		if wrh[0] == "1":
			print("FRAME NUM = " + str(int(frmb[0:18]+wrb[4:10],2)))
			print("CHNL = " + str(int(wrb[-6:],2)))
			#print("binary = " + str(wrb))
			tpcnt = 0
			tot = ""
			intgrl = ""
			intgrlN = ""
			amp = ""
			nsamps = ""
		if wlh[0] == "1":
			print("FRAME NUM = " + str(int(frmb[0:18]+wlb[4:10],2)))
			print("CHNL = " + str(int(wlb[-6:],2)))
			#print("binary = " + str(wlb))
			tpcnt = 0
			tot = ""
			intgrl = ""
			intgrlN = ""
			amp = ""
                if wrb[0:2] == "01":
                        print("TIMETICK = " + str(int(wrb[2:],2)))
                if wlb[0:2] == "01":
                        print("TIMETICK = " + str(int(wlb[2:],2)))
		if wlh[0] == "C":
			tpcnt +=1
#		if tpcnt == 1:
#			tot = int(wrh[1:],16)
#		if tpcnt == 3:
#			intgrl = str(int(wrh[1:]+intgrl,16))
#		if tpcnt == 5:
#			intgrlN = str(int(wrh[1:]+intgrlN,16))
		if tpcnt == 1:
			tot = int(wlh[1:],16)
		if tpcnt == 3:
			intgrl = str(int(str(wlh[1:])+intgrl,16))
		if tpcnt == 5:
			intgrlN = str(int(str(wlh[1:])+intgrlN,16))
		if wrh[0] == "C":
			tpcnt +=1
		if tpcnt == 2:
			intgrl = str(wrh[1:])
		if tpcnt == 4:
			intgrlN = str(wrh[1:])
		if tpcnt == 6:
			amp = str(int(wrh[1:],16))			
			print("TOT = " + str(tot))
			print("INT = " + str(intgrl))
			print("INTN = " + str(intgrlN))
			print("AMP = " + str(amp))
			tpcnt = 0
			tot = ""
			intgrl = ""
			intgrlN = ""
			amp = ""
			nsamps = ""
		if wf == "E0000000":
			hdrcnt = 0
