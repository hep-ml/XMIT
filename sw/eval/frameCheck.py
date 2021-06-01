#f = open("frtest","r")
f = open("SNNominal","r") 
scale = 16 ## equals to hexadecimal                                                                                            
num_of_bits = 16
tot = 0
intgrl = 0
intgrlN = 0
nsamps = 0
hdrcnt = 0
amp = 0
N = 11
frame=0

dakl;hfsdakjhfkjsdalfjs               wlb = bin(int(wlh, scale))[2:].zfill(num_of_bits)
                if (wf[0]=="F" or wrh[0]=="1" or wlh[0]=="1"):
                        hdrcnt += 1
                        if (hdrcnt == 5):
                          #      print(wlh)
                                femheader=[wlh,wrh]
                                #print(femheader)
                                frame1 = int(wrh[1:], 16) + int(wlh[1:], 16)
                                #print("FRAMENUM FEMHeader = " + str(frame1))
                        if (hdrcnt == 8):
                                if (wrh[0] == "1"):
                                        chnlheader=[wlh,wrh[1:]]
                                        #print(chnlheader[1])
                                        frame2=int(wrb[-12:-6],2)
                                        #print("FRAMENUM CHNLHeader = " + str(frame2))
                                        #print(chnlheader)
                                        #print(femheader)
                                        #print(frame1)
                                        #print(frame2)
                                        if(frame1 == frame2):
                                                print("FRAMENUM FEMHeader = " + str(frame1)) 
                                        elif(frame1 != frame2):
                                                print("Mismatch in frame numbers! Lets calculate masked frame number")
                                                print("Frame1: " + str(frame1))
                                                print("Frame2: " + str(frame2))
                                                frameword_lh="F"+chnlheader[1]
                                                frameword_rh=femheader[1]
                                                print("NewFrameWord_LH: " + str(frameword_lh))
                                                print("NewFrameWord_RH: " + str(frameword_rh))
                                                print("NewFrameWord :" + str(frameword_lh)+str(frameword_rh))
                                                frameword_lb=bin(int(frameword_lh, scale))[2:].zfill(num_of_bits)
                                                frame=int(frameword_rh[1:], 16) + int(frameword_lb[-12:-6],2)
                                                print("(Masked)FRAMENUM FEMHeader = " + str(frame))

                elif (wf == "E0000000"):
                        hdrcnt = 0
