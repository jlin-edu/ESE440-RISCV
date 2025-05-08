import os

from lib.Backend.Controller import Controller
from lib.Frontend.GUI import GUI

from ctypes import windll
windll.shcore.SetProcessDpiAwareness(1) # This improves the resolution of the Tk App

"""
TODO:
- Pipeline status view
- Change data view (hex, bin, dec, signed, unsigned)
- Manually set time to go to + show current time
- Run TCL commands
- Change program file + display name (either through DPI or change SV file)
- Mode button: single cycle vs pipeline
- Menubar (stub in place)
- Disassembler for instruction decoding? (might be too much)
- Breakpoints
- Don't automatically open file.
- Automatically open a vivado instance with the correct modules, run simulation with vcd logging, open vcd file just by opening a new program (vivado interface)
- Jump to end (current) vs step-by-step (set speed and watch)
"""


if __name__ == "__main__":
    current_file_path = __file__
    current_file_abs_path = os.path.abspath(current_file_path)
    current_directory_path = os.path.dirname(current_file_abs_path)
    
    control = Controller(current_directory_path, mem_size=2048)
    gui = GUI(control)
    
    
