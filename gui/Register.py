# Register Class Python File by Alec Merves

import tkinter as tk
from tkinter import ttk

# Register Class, contains the register number and current value. 
# Internally contains a RegisterFrame class for handling the Register widgets
class Register:
    def __init__(self, master, reg_file, num, width=100, height=50):   
        self.file = reg_file   
        
        # Initialize the class variables
        self.num = num
        self.val = 0
        
        # Create the RegisterFrame, passing the master widget and itself to the constructor
        # The master widget is the widget that will contain the register, and the register class
        # itself is passed to allow the frame to reference it (might not be necessary!!)
        self.frame = self.RegisterFrame(master, self, width, height)
    
    # Setter method to modify the registers current value
    def set_val(self, new_val):
        self.val = new_val
        self.frame.set_val()
    
    # Grid method to place the frame in the specified position of the master widget,
    # as well as place all widgets within the frame
    def grid(self, col=0, row=0):
        self.frame.grid(column=col, row=row)
        self.frame.grid_all()
    
    # RegisterFrame inner class, used to manage the frame and widgets associated
    # with an external Register instance
    # Is a subclass of the tk.Frame class, thus inherently includes a Frame widget
    class RegisterFrame(ttk.Frame):
        def __init__(self, master, register, width, height):
            # Frame dimensions
            self.width = width
            self.height = height
            
            # Reference to the external register instance
            self.register = register
            
            # Call super-class (Frame) constructor, passing the master widget, as well as size
            # and style options (TODO: Create custom style)
            super().__init__(master, width=self.width, height=self.height, borderwidth=2, relief="solid", padding=(5,0))
            
            # StringVar to hold the register value, allows for automatic updates to the label
            # with changes to the register value. Also initializes to the starting register value
            self.val_str = tk.StringVar()
            self.set_val()
            
            # Initialize widgets
            self.init_num_label()
            self.init_val_label()
            self.init_sep()
        
        # Method to initialize the register number widget within the frame
        def init_num_label(self):
            self.num_label = ttk.Label(self, text=self.str_num(), anchor="center", width=len(self.val_str.get())+1)
        
        # Method to initialize the register value widget within the frame
        def init_val_label(self):
            self.val_label = ttk.Label(self, textvariable=self.val_str, anchor="center", width=len(self.val_str.get())+1)
        
        # Method to initialize the register separator widget within the frame
        def init_sep(self):
            self.separator = ttk.Separator(self, orient="horizontal")
        
        # Method to place all widgets within the frame
        def grid_all(self):
            self.num_label.grid(column=0, row=0, sticky="ew", ipadx=2, ipady=2)
            self.separator.grid(column=0, row=1, sticky="ew")
            self.val_label.grid(column=0, row=2, sticky="ew", ipadx=2, ipady=2)
        
        # String representation of the register's number (2 digit integer with preceding 'x')
        def str_num(self):
            return f"x{self.register.num:02}"

        # String representation of the register's value (8 digit hexidecimal with preceding '0x')
        def str_val(self):
            return f"0x{self.register.val:08x}"
        
        # Method to change the value of the StringVar corresponding to the value Label.
        def set_val(self):
            self.val_str.set(self.str_val())
