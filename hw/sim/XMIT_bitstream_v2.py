#!/usr/bin/python


#This code is designed to take in one .txt file, passed with -f as an argument in the command line,
#of 32-bit chunked hexidecimal words organized in columns and separated by spaces, which will be
#converted to a binary stream. The binary stream gets saved as a text file with the date and time.
#Author: Harrison Siegel, 2020


import csv
import os
import time
from optparse import OptionParser


def main():
	#Set up parser to accept .txt file to be converted to bitstream.
	parser = OptionParser()	
	parser.add_option("-f","--file", dest="filename", help="Text file input to be converted to binary bitstream", metavar="FILE")
	(options,args) = parser.parse_args()
	print "Input file  = ", options.filename 
	#Create file named binary_stream<date and time>.txt
	timestr = time.strftime("_%Y%m%d-%H%M%S")	
	with open('binary_stream'+timestr+'.txt', 'wb') as outfile: 
		print "Output file = ", 'binary_stream'+timestr+'.txt'
	#Read out chunked words separated by spaces one at a time, convert the 16 bit word on the 
	#right first and the 16 bit word on the left second, to binary, then write these to the 
	#file opened above. 
		with open(options.filename,"rb+") as infile:
			reader = csv.reader(infile, delimiter = ' ')
			for row in reader:
				for word in row:
					if len(word)!=0:
						word1=word[0:4]
						word2=word[4:]
						outfile.write("\""+format(int(word2,16), '0>16b')+format(int(word1,16), '0>16b')+"\",\n")
			outfile.seek(-2, os.SEEK_END)
			outfile.truncate()

if __name__=="__main__":
	main()
