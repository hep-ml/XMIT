import operator

class TP:
	"""Single Trigger Primitive"""

	def __init__(self,fem,event,length,frame,timetick,channel,nvalues,integral,integralovern,amplitude):
		# constructor
		self.fem = fem
		self.event = event
		self.frame = frame
		self.length = length
		self.timetick = timetick
		self.channel = channel
		self.nvalues = nvalues
		self.integral = integral
		self.integralovern = integralovern
		self.amplitude = amplitude
	
	def __repr__(self): 
		# for printing
		return "TPF\nFEM,"+repr(self.fem)+"\nEVENT,"+repr(self.event)+"\nFRAME,"+repr(self.frame)+"\nLENGTH,"+repr(self.length)+"\nTIMETICK,"+repr(self.timetick)+"\nCHANNEL,"+repr(self.channel)+"\nNVALUES,"+repr(self.nvalues)+"\nINTEGRAL,"+repr(self.integral)+"\nINTEGRALOVERN,"+repr(self.integralovern)+"\nAMPLITUDE,"+repr(self.amplitude)+"\nEND"




def test():
	# Let's create an empty list in which we will put our TPs
	TPs = []
	
	# Now let's create our TP, with femnumber = 0, eventno = 1, length = 2 etc)
	NewTP = TP(0,1,2,3,4,5,6,7,8,9)
	
	# You can access or change the inidvidual values
	print(NewTP.length)
	NewTP.length = 100
	print(NewTP.length)

	# Let's add it to our list
	TPs.append(NewTP)

	# To add another TP, you could also do (for femnumber = 100, eventno = 101 etc)
	TPs.append(TP(100,101,102,103,104,105,106,107,108,109))

	# Let's try to print the list, which will call __repr__

	# Let's add another TP
	TPs.append(TP(50,51,52,53,54,55,56,57,58,59))

	# Not let's sort the list with using "channel" as key
	TPs_sorted = sorted(TPs,key=operator.attrgetter("channel"))

	# Let's verify
	print(TPs_sorted)

	# So you get sorted TPs! If you want to new groups, you could make a list of lists, and put TP groups in there (here, we add the same TP group twice)
	ListOfLists = []
	ListOfLists.append(TPs)
	ListOfLists.append(TPs)
	print(ListOfLists)





