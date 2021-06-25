import matplotlib.pyplot as plt


with open('SN_frames_new.txt') as f:
    lines = f.readlines()
    x = [int(line.strip('n'),16) for line in lines]
plt.plot(x,'.')
plt.title("Frame numbers SN, nominal firmware")
plt.ylabel("FEM Header Frame Number")
plt.xlabel("Iterative Frame Counter")
plt.show()

a='''with open('TP_frames_new.txt') as f:
    lines = f.readlines()
    x = [int(line.strip('n'),16) for line in lines]
plt.plot(x,'.')
plt.title("Frame numbers TP")
plt.ylabel("FEM Header Frame Number")
plt.xlabel("Iterative Frame Counter")
plt.show()'''


with open('log_new.txt') as f:
    lines = f.readlines()
    x = [int(line.strip('n'),16) for line in lines]
plt.plot(x,'.')
plt.title("Test pattern")
plt.ylabel("ADC values")
plt.xlabel("Sample #")
plt.show()
