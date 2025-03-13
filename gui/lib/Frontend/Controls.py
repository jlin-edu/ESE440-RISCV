import tkinter as tk
from tkinter import ttk

class Controls:
    def __init__(self, master):
        self.frame = self.ControlFrame(master, self)
    
    def grid(self, **kwargs):
        self.frame.grid(**kwargs)
    
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
        
        def grid(self, **kwargs):
            super().grid(**kwargs)
            self.run.grid(column=0, row=0)
            self.reset.grid(column=1, row=0)
            self.forward.grid(column=2, row=0)
            self.backward.grid(column=3, row=0)