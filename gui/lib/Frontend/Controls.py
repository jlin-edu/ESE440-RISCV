import tkinter as tk
from tkinter import ttk

class Controls:
    def __init__(self, master):
        self.frame = self.ControlFrame(master, self)
    
    def grid(self, **kwargs):
        self.frame.grid(**kwargs)
        self.frame.grid_all()
        
    def regrid(self, **kwargs):
        self.frame.grid(**kwargs)
        
    def disable(self):
        self.frame.disable_buttons()
        
    def enable(self):
        self.frame.enable_buttons()
    
    class ControlFrame(ttk.Frame):
        def __init__(self, master, controller, **kwargs):
            self.controller = controller
            
            super().__init__(master, **kwargs)
            
            self.init_buttons()
            
        def init_buttons(self):
            self.run = ttk.Button(self, text="Play", command=self.master.controller.play)
            self.reset = ttk.Button(self, text="Reset", command=self.master.controller.reset)
            self.forward = ttk.Button(self, text="Step Forward", command=self.master.controller.step_forward)
            self.backward = ttk.Button(self, text="Step Back", command=self.master.controller.step_backward)
            self.test = ttk.Button(self, text="Test", command=self.master.controller.test)
        
        def grid(self, **kwargs):
            super().grid(**kwargs)
        
        def grid_all(self):
            self.run.grid(column=0, row=0)
            self.reset.grid(column=1, row=0)
            self.forward.grid(column=2, row=0)
            self.backward.grid(column=3, row=0)
            self.test.grid(column=4, row=0)

        def disable_buttons(self):
            self.reset.config(state="disabled")
            self.forward.config(state="disabled")
            self.backward.config(state="disabled")
            self.test.config(state="disabled")
            
        def enable_buttons(self):
            self.reset.config(state="normal")
            self.forward.config(state="normal")
            self.backward.config(state="normal")
            self.test.config(state="normal")