bin_words = []
hex_words = []
with open('TP_FRAMES.txt') as my_file:
    for bin_word in my_file:
        bin_words.append(bin_word.strip('\n'))#[::-1]) #Reverse list

for bin_word in bin_words:
	hex_word = hex(int(bin_word, 2)).upper()[2:]
	hex_words.append(hex_word)
	print(hex_word)
