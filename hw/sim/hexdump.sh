echo "Writing to hexdump$(date +"%Y")$(date +"%m")$(date +"%d").txt"
hexdump -v -e '8/4 "%08X ""\n"' $1 > hexdump$(date +"%Y")$(date +"%m")$(date +"%d").txt
