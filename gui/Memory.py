import tkinter as tk
from tkinter import ttk

from MemoryCell import MemoryCell

# TODO: Change to a tree view with popup entry for modifying
class Memory:
    def __init__(self, master, size, title, width=300, height=100):
        self.title = title
        
        self.size = size
        self.vals = [0 for i in range(size)]
        
        self.frame = self.MemoryFrame(self, master, width, height)
        self.cells = [MemoryCell(self.frame.cell_frame, self, address=i) for i in range(size)]
        
    def grid(self, col=0, row=0):
        self.frame.grid(column=col, row=row)
        self.frame.grid_all()
    
    class MemoryFrame(ttk.LabelFrame):
        def __init__(self, memory, master, width, height):
            self.width = width
            self.height = height
            
            self.memory = memory
            
            super().__init__(master, text=self.memory.title, width=self.width, height=self.height, borderwidth=2, relief="solid", padding=5)
            
            self.init_canvas_scroll()
            
        def init_canvas_scroll(self):
            self.canvas = tk.Canvas(self, width=self.width, height=self.height)
            self.cell_frame = ttk.Frame(self.canvas)
            self.scrollbar = ttk.Scrollbar(self, orient="vertical", command=self.canvas.yview)
            self.canvas.configure(yscrollcommand=self.scrollbar.set)
            self.canvas.create_window((0, 0), window=self.cell_frame, anchor="nw")
            self.cell_frame.bind("<Configure>", lambda e: self.canvas.configure(scrollregion=self.canvas.bbox("all")))
            self.canvas.bind_all("<MouseWheel>", lambda e: self.canvas.yview_scroll(-1 * (e.delta // 120), "units"))
        
        def grid_all(self):
            self.canvas.grid(column=0, row=0, sticky="nsew")
            self.scrollbar.grid(column=1, row=0, sticky="ns")
            for cell in self.memory.cells:
                cell.grid(column=0, row=cell.address)

root = tk.Tk()
mem = Memory(root, 2**10, "Data Memory")
mem.grid(col=0, row=0)
root.mainloop()