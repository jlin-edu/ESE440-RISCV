import tkinter as tk
from tkinter import filedialog
from tkinter import ttk

from .Controls import Controls
from .Memory import Memory
from .Register import Register
from .RegisterFile import RegisterFile

# IDEAS: Have current instruction highlighted/tracked in the instruction memory view
# TODO: Menu bar to open files, start sim, close, etc

class GUI(tk.Tk):
    def __init__(self, controller):
        self.controller = controller
        controller.GUI = self
        
        super().__init__()
        self.title("Dire-WolVes RISC-V GUI v0.01")
        self.frame = ttk.Frame(self)
        self.load_widgets()
        self.grid_all()
        self.resizable(False, False)
        self.option_add("*tearOff", False)
        
        self.VCDfile = filedialog.askopenfilename(title="Select VCD File", filetypes=(("VCD Files", "*.vcd"), ("All Files", "*.*")))
        self.controller.open_vcd(self.VCDfile)
        
        self.mainloop()
    
    def load_widgets(self):
        self.pc = Register(self, None, "Program Counter")
        self.registers = RegisterFile(self, "Register File", 4, 8)
        
        # Adjusts height of each memory view
        s = ttk.Style()
        s.configure("Treeview", rowheight=20)
        s.map("Treeview", foreground=self.fixed_map('foreground', s), background=self.fixed_map('background', s))
        
        self.instruction_mem = Memory(self, 128, "Instruction Memory", highlight=True)
        self.data_mem = Memory(self, 128, "Data Memory")
        
        self.controls = Controls(self)
        
        self.stages = ttk.Frame(self, relief="solid", borderwidth=2)
        #self.temp2 = ttk.Label(self.stages, text="Pipeline Stages", anchor="center") #TODO
    
    def grid_all(self):
        self.pc.grid(col=0, row=0, sticky="w")
        self.registers.grid(column=0, row=1, rowspan=2)
        self.instruction_mem.grid(col=1, row=1)
        self.data_mem.grid(col=1, row=2)
        
        self.controls.grid(column=1, row=0, columnspan=1, sticky="nsew")
        
        self.stages.grid(column=2, row=0, rowspan=3, sticky="nsew")
        #self.temp2.grid(sticky="nsew")
        
    def load_menu(self):
        self.menu = tk.Menu(self)
        self['menu'] = self.menu
        
    def write(self, data):
        self.pc.set_val(data[0])
        self.registers.load(data[1])
        self.instruction_mem.load(data[2])
        self.instruction_mem.highlight_pos(data[0] // 4) # Highlight the instruction corresponding to the PC value (/ 4 since PC increments by 4)
        self.data_mem.load(data[3])

    def fixed_map(self, option, style):
        # Fix for setting text colour for Tkinter 8.6.9
        # From: https://core.tcl.tk/tk/info/509cafafae
        #
        # Returns the style map for 'option' with any styles starting with
        # ('!disabled', '!selected', ...) filtered out.

        # style.map() returns an empty list for missing options, so this
        # should be future-safe.
        return [elm for elm in style.map('Treeview', query_opt=option) if elm[:2] != ('!disabled', '!selected')]