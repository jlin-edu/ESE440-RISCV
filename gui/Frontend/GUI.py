import tkinter as tk
from tkinter import ttk

from Memory import Memory
from Register import Register
from RegisterFile import RegisterFile

class GUI(tk.Tk):
    def __init__(self):
        super().__init__()
        self.frame = ttk.Frame(self)
        self.load_widgets()
        self.grid_all()
        self.mainloop()
    
    def load_widgets(self):
        self.pc = Register(self, None, "Program Counter")
        self.registers = RegisterFile(self, "Register File", 4, 8)
        
        # Adjusts height of each memory view
        s = ttk.Style()
        s.configure("Treeview", rowheight=15)
        
        self.instruction_mem = Memory(self, 1024, "Instruction Memory")
        self.data_mem = Memory(self, 1024, "Data Memory")
    
    def grid_all(self):
        self.pc.grid(col=0, row=0, sticky="w")
        self.registers.grid(column=0, row=1, rowspan=2)
        self.instruction_mem.grid(col=1, row=1)
        self.data_mem.grid(col=1, row=2)

if __name__ == "__main__":
    test = GUI()