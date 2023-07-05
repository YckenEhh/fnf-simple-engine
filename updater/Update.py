import requests, py7zr, io, os, sys, time
from tkinter import *
from tkinter import ttk
from threading import Thread

os.system("taskkill /im SimpleFNFEngine.exe /F")

def ui():

    window = Tk()
    window.geometry("235x105")
    window.title("FNF Updater")
    window.resizable(0, 0)

    label = Label(text = 'Installing...')
    label.pack()

    label1 = Label(text = 'FNF Updater writen by ycken')
    label1.pack(side=BOTTOM)

    progressbar =  ttk.Progressbar(orient="horizontal", mode="indeterminate")
    progressbar.pack(fill=X, padx=10, pady=10)
    progressbar.start()

    btn = Button(text="Cancel", command=sys.exit)
    btn.pack(side=BOTTOM)

    window.mainloop()

def download():
    dir:str = os.getcwd()
    githubUrl:str = sys.argv[1]
    r = requests.get(githubUrl)
    archive = py7zr.SevenZipFile(io.BytesIO(r.content), mode='r')
    archive.extractall(path=dir)
    archive.close()

    os.system("taskkill /im Update.exe /F")
    sys.exit()
    
Thread(target=ui).start()
Thread(target=download).start()