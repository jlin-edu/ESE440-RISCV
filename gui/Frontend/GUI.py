import tkinter as tk
from tkinter import ttk

from Controls import Controls
from Memory import Memory
from Register import Register
from RegisterFile import RegisterFile

class GUI(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Dire-WolVes RISC-V GUI v0.01")
        self.frame = ttk.Frame(self)
        self.load_widgets()
        self.grid_all()
        self.resizable(False, False)
        self.mainloop()
    
    def load_widgets(self):
        self.pc = Register(self, None, "Program Counter")
        self.registers = RegisterFile(self, "Register File", 4, 8)
        
        # Adjusts height of each memory view
        s = ttk.Style()
        s.configure("Treeview", rowheight=15)
        
        self.instruction_mem = Memory(self, 1024, "Instruction Memory")
        self.data_mem = Memory(self, 1024, "Data Memory")
        
        self.controls = Controls(self)
        
        self.stages = ttk.Frame(self, relief="solid", borderwidth=2)
        self.temp2 = ttk.Label(self.stages, text="Pipeline Stages", anchor="center") #TODO
    
    def grid_all(self):
        self.pc.grid(col=0, row=0, sticky="w")
        self.registers.grid(column=0, row=1, rowspan=2)
        self.instruction_mem.grid(col=1, row=1)
        self.data_mem.grid(col=1, row=2)
        
        self.controls.grid(column=1, row=0, columnspan=1, sticky="nsew")
        
        self.stages.grid(column=2, row=0, rowspan=3, sticky="nsew")
        self.temp2.grid(sticky="nsew")

if __name__ == "__main__":
    test = GUI()