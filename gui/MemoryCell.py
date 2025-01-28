import tkinter as tk
from tkinter import ttk

from math import ceil, log

class MemoryCell:
    def __init__(self, master, memory, value=0, address=0):
        self.master = master
        self.memory = memory
        self.value = value
        self.address = address
        
        self.frame = self.MemoryCellFrame(master, self)
        
    def grid(self, column=0, row=0):
        self.frame.grid(column, row)
    
    class MemoryCellFrame(tk.Frame):
        def __init__(self, master, cell):
            self.cell = cell
            
            super().__init__(master)
            
            self.value = tk.StringVar(value=self.str_val())
            self.address_length = ceil(log(self.cell.memory.size, 2)/4.0)
            self.address = self.str_addr()
            
            self.init_address_label()
            self.init_value_entry()
            self.init_separator()
    
        def init_address_label(self):
            self.address_label = ttk.Label(self, text=self.address, anchor="center", width=2+self.address_length)
        
        def init_value_entry(self):
            self.value_entry = ttk.Entry(self, textvariable=self.value, justify="right", width=10)
            
        def init_separator(self):
            self.separator = ttk.Separator(self, orient="vertical")
        
        def grid(self, col=0, row=0):
            super().grid(column=col, row=row, sticky="ew")
            self.address_label.grid(column=0, row=0)
            self.separator.grid(column=1, row=0, sticky="ns", padx=5)
            self.value_entry.grid(column=2, row=0)
        
        def str_val(self):
            return f"0x{self.cell.value:08x}"
        
        def str_addr(self):
            address = f"{self.cell.address:x}"
            padding = ['0' for i in range(self.address_length - len(address))]
            return "0x" + "".join(padding) + address