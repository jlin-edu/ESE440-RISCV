import tkinter as tk
from tkinter import ttk

from .Register import Register

#TODO: Improve performance, change to either panes or some simpler geometry with less widgets
class RegisterFile:
    def __init__(self, master, title, columns=1, rows=1):
        self.title = title
        
        self.cols = columns
        self.rows = rows
        
        self.frame = self.RegisterFileFrame(master, self)
        self.registers = [[Register(self.frame, self, self.cols * j + i) for i in range(self.cols)] for j in range(self.rows)]
    
    def grid(self, row, column, **kwargs):
        self.frame.grid(row=row, column=column, **kwargs)
        for i in range(self.rows):
            for j in range(self.cols):
                self.registers[i][j].grid(j, i)
    
    def regrid(self, row, column, **kwargs):
        self.frame.grid(row=row, column=column, **kwargs)
    
    def grid_forget(self):
        self.frame.grid_forget()
    
    def set_val(self, value, row=0, column=0, modified=None):
        if row >= self.rows:
            print(f"Error: Row index out of range - Index: {row}, Rows:{self.rows}")
        elif column >= self.cols:
            print(f"Error: Column index out of range - Index: {column}, Columns:{self.cols}")
        else:
            self.registers[row][column].set_val(value, modified)

    def load(self, values):
        if len(values) > self.rows * self.cols:
            print(f"Error: Dimension size error")
        else:
            for i in range(self.rows * self.cols):
                row = i // self.cols
                col = i % self.cols
                modified = values[i] != self.registers[row][col].val
                self.set_val(values[i], row, col, modified)

    class RegisterFileFrame(ttk.LabelFrame):
        def __init__(self, master, register_file):
            self.register_file = register_file
            
            super().__init__(master, text=self.register_file.title, padding=3)
        

if __name__ == "__main__":
    root = tk.Tk()
    registers = RegisterFile(root, "Register File", 4, 8)
    registers.grid(0, 0)

    temp = [[registers.cols * j + i for i in range(registers.cols)] for j in range(registers.rows)]
    print(temp)
    registers.load(temp)

    root.mainloop()