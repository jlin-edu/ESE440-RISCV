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
            self.run = ttk.Button(self, text="Play")
            self.pause = ttk.Button(self, text="Pause")
            self.forward = ttk.Button(self, text="Step Forward")
            self.backward = ttk.Button(self, text="Step Back")
        
        def grid(self, **kwargs):
            super().grid(**kwargs)
            self.run.grid(column=0, row=0)
            self.pause.grid(column=1, row=0)
            self.forward.grid(column=2, row=0)
            self.backward.grid(column=3, row=0)