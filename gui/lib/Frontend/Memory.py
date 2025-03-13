from ast import mod
import tkinter as tk
from tkinter import ttk

from math import ceil, log
class Memory:
    def __init__(self, master, size, title, width=300, height=100, highlight=False):
        self.title = title
        
        self.size = size
        self.vals = [0 for i in range(size)]
        
        self.highlight = highlight
        if self.highlight:
            self.highlight_idx = 0
        self.modified = None
        
        self.frame = self.MemoryFrame(self, master, width, height)
        
    def grid(self, col=0, row=0):
        self.frame.grid(column=col, row=row)
        self.frame.grid_all()
    
    def load(self, data):
        self.modified = [False for i in range(self.size)]
        for i in range(self.size):
            self.modified[i] = self.vals[i] != data[i]
            self.vals[i] = data[i]
        self.frame.update()
    
    def highlight_pos(self, pos):
        self.frame.change_highlight(pos)
    class MemoryFrame(ttk.LabelFrame):
        def __init__(self, memory, master, width, height):
            self.width = width
            self.height = height
            
            self.memory = memory
            
            super().__init__(master, text=self.memory.title, width=self.width, height=self.height, borderwidth=2, relief="solid", padding=5)
            
            self.init_tree_scroll()
            
            
        def init_tree_scroll(self):
            self.tree = ttk.Treeview(self, columns=("address", "data"), selectmode="none")
            self.tree.column("#0", width=10, stretch=False)
            self.tree.column("address", width=75, anchor="center", stretch=False)
            self.tree.heading("address", text="Address")
            self.tree.column("data", width=150, anchor="center", stretch=False)
            self.tree.heading("data", text="Data")
            self.tree.bind("<Motion>", "break") # Disable column resizing (strech=False doesn't)
            
            if self.memory.highlight:
                self.tree.tag_configure("focus", background="yellow") # Highlighting for instruction memory (current instruction)
            self.tree.tag_configure("modified", foreground="red") # Highlighting for any value changes
            
            self.scrollbar = ttk.Scrollbar(self, orient="vertical", command=self.tree.yview)
            self.tree.configure(yscrollcommand=self.scrollbar.set)
            self.tree.bind("<MouseWheel>", lambda e: self.tree.yview_scroll(-1 * (e.delta // 120), "units"))
        
        def grid_all(self):
            self.tree.grid(column=0, row=0, sticky="nsew")
            self.scrollbar.grid(column=1, row=0, sticky="ns")
            
            for i, val in enumerate(self.memory.vals):
                self.tree.insert("", "end", i, text="", values=(self.str_addr(i), self.str_val(val)))
                
        def str_val(self, val):
            return f"0x{val:08x}"
        
        def str_addr(self, addr):
            address = f"{addr:x}"
            address_length = ceil(log(self.memory.size, 2)/4.0)
            padding = ['0' for i in range(address_length - len(address))]
            return "0x" + "".join(padding) + address
        
        def update(self):
            for i, val in enumerate(self.memory.vals):
                tag = ("modified",) if self.memory.modified[i] else ()
                self.tree.item(i, values=(self.str_addr(i), self.str_val(val)), tags=tag)
                if self.memory.modified[i]:
                    self.tree.see(i)
        
        def change_highlight(self, new_highlight):
            if self.memory.highlight:
                self.tree.item(self.memory.highlight_idx, tags=())
                self.memory.highlight_idx = new_highlight
                self.tree.item(self.memory.highlight_idx, tags=("focus",))
                self.tree.see(self.memory.highlight_idx)
                
        