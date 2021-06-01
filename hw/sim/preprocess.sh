cp input_raw.vhd input.vhd
wc -l data.txt > outp.tmp
vim -n -c "source preprocess.vim" input.vhd 
rm outp.tmp
