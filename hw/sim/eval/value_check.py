
verbose = False
plots = False
plotindex = 20001
printvalues = True
thresholds = [0,750,780]#[int("0000000000000001",2),int("0000000010000000",2),int("100000000000",2)]
#thresholds = [int("0000000000000001",2),int("0000000010000000",2),int("100000000000",2)]
N = int("00000000000000000000000000000110",2)
#ignoreFirst = True
if plots:from matplotlib import pyplot as plt

# Using readlines() 
file_input = open('input.vhd', 'r') 
Lines = file_input.readlines() 
Lines = Lines[11:-3]
values_bin = []
for line in Lines:
	line_bin = line[1:33]
	values_bin.append(line_bin[:16]) # is order correct?
	values_bin.append(line_bin[16:])

fragment_started = False
header = 0
TPs = []

class TP:
	def __init__(self, channel, frameno_6bit, header_values, N, thresholds):
		self.length = header_values[1]
		self.eventno = header_values[2]
		self.channel = channel
		self.frameno = frameno_6bit | ((header_values[3] >> 4) << 4)
		self.tots = [0,0,0]
		self.ints = [0,0,0]
		self.integer = 0
		self.integerN = 0
		self.maxamp = 0
		self.valuecnt = 0
		self.timetick = 0
		self.N = N
		self.thresholds = thresholds
		self.timetick_flag = False

		self.totsarr = [[],[],[]]
		self.intsarr = [[],[],[]]
		self.integerarr = []
		self.integerNarr = []
		self.maxamparr = []
		self.valuearr = []

	def print_vals(self):
		print("TPF")
		print("LENGTH,"+str(self.length))				
		print("CHANNEL,"+str(self.channel))				
		print("EVENTNO,"+str(self.eventno))				
		print("FRAMENO,"+str(self.frameno))				
		print("TIMETICK,"+str(self.timetick))				
		j = 0
		for tot in self.tots:
			if j == 0:					# SIMPLIFIED
				print("TOT"+str(j+1)+","+str(tot))
			else:						# SIMPLIFIED
				print("TOT"+str(j+1)+","+str(0)) 	# SIMPLIFIED
			j+=1
#		print("INTN,"+str(0))		
		print("INTN,"+str(self.integerN))				# SIMPLIFIED	
		j = 0
		for iot in self.ints:
#			print("IOT"+str(j+1)+","+str(iot))
			print("IOT"+str(j+1)+","+str(0))		# SIMPLIFIED
			j+=1
		print("INT,"+str(self.integer))				
		print("AMP,"+str(self.maxamp))				
		print("END")

	def update_timetick(self,timetick):
		self.timetick = timetick
		self.timetick_flag = True

	def update_vals(self,value,verbose,plots):
		if verbose:print(value)
		self.integer += value
		if self.valuecnt < self.N:
			self.integerN += value
		j = 0
		for threshold in self.thresholds:
#			if value >= threshold:
				self.tots[j] += 1
				self.ints[j] += value
			#print(j, self.tots[j])
				j += 1
		if value > self.maxamp:
			self.maxamp = value
		self.valuecnt += 1
		if verbose:self.print_vals()
		
		if plots:
			self.valuearr.append(value)
			self.integerarr.append(self.integer)
			self.integerNarr.append(self.integerN)
			self.maxamparr.append(self.maxamp)
			for j in range(len(self.thresholds)):
				self.totsarr[j].append(self.tots[j])
				self.intsarr[j].append(self.ints[j])

TP_cnt = -1
skip = False
plotsflag = plots
for i in range(len(values_bin)):
		if fragment_started and header < 6*2:
			if not skip:
				# print values_bin[i],values_bin[i+1],values_bin[i+1][-12:]+values_bin[i][-12:]
				header_values.append(int(values_bin[i][-12:]+values_bin[i+1][-12:],2))
				header += 2
				skip = True
			else:
				skip = False
		if i != 0:
			if values_bin[i] == "1111111111111111" and values_bin[i] == values_bin[i-1] and not fragment_started:
	#			if not ignoreFirst:
					fragment_started = True
					header_values = []
					header = 0
					skip = False
			if values_bin[i] == "1110000000000000":
				fragment_started = False
	#			ignoreFirst = False
		if header == 6*2 and fragment_started:
			if values_bin[i][0:4] == "0001":
				channel = int(values_bin[i][10:],2)
				frameno_6bit = int(values_bin[i][4:10],2)
				TPs.append(TP(channel,frameno_6bit,header_values,N,thresholds))
				TP_cnt += 1
			if values_bin[i][0:3] == "001":
				value = int(values_bin[i][4:],2)
				#print(values_bin[i],value,int(values_bin[i-1][4:],2))
				if plots and TP_cnt == plotindex: 
					plotsflag = True
				else:
					plotsflag = False
				TPs[TP_cnt].update_vals(value,verbose,plotsflag)
			if values_bin[i][0:2] == "01":
				timetick = int(values_bin[i][2:],2)
				TPs[TP_cnt].update_timetick(timetick)
if printvalues:
	for i in range(len(TPs)):
		TPs[i].print_vals()

if plots:
	index = plotindex
	plt.subplot(3,1,1)
	plt.ylabel("ADC #")
	plt.title("Trigger Primitives")
	plt.plot(TPs[index].valuearr, label = "ADC value")
	plt.plot(TPs[index].maxamparr, label = "Maximum Amplitude")
	for j in range(len(TPs[index].thresholds)):
		plt.plot([0,len(TPs[index].valuearr)],[TPs[index].thresholds[j],TPs[index].thresholds[j]],'--', label = "Threshold " + str(j))
	plt.plot([TPs[index].N,TPs[index].N+1.e-6],[min(TPs[index].thresholds),max(TPs[index].valuearr)],'--', label = "N")
	plt.subplot(3,1,2)
	plt.plot(TPs[index].integerarr, label  = "Integral")
	plt.plot(TPs[index].integerNarr, label  = "Integral over N samples")
	plt.subplot(3,1,3)
	plt.plot([0],[0],label  = "")
	plt.plot([0],[0],label  = "")
	for j in range(len(TPs[index].thresholds)):
		plt.subplot(3,1,2)
		plt.plot(TPs[index].intsarr[j], label = "Integral over threshold " + str(j))
		plt.subplot(3,1,3)
		plt.plot(TPs[index].totsarr[j], label = "Time over threshold " + str(j))
		plt.xlabel("Time")
	for i in [1,2,3]:
		plt.subplot(3,1,i)
		if i == 1:
			plt.legend(loc='lower right')
		else:
			plt.legend(loc='upper left')
	plt.show()
