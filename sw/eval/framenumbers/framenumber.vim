%s/^.*\(FFFFFFFF F...FFFF F...F... F...\).*$/\1/
g/........ ........ ........ ......../d
%s/FFFFFFFF F...FFFF ........ F//g
saveas SN_frames.txt
