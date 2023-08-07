from tkinter import *
import sys
import os

os.system("taskkill /im SimpleFNFEngine.exe /F")
os.system("taskkill /im cmd.exe /F")

errMsg:str = str(sys.argv[1]).replace('%', '\n')
 
root = Tk()
root.title("Crash handler")

root.resizable(False, False)

label = Label(text=errMsg, justify=LEFT)
label.pack()

root.mainloop()