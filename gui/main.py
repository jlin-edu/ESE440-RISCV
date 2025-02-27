from lib.Backend.Controller import Controller
from lib.Frontend.GUI import GUI

from ctypes import windll
windll.shcore.SetProcessDpiAwareness(1) # This improves the resolution of the Tk App

"""
TODO:
- Pipeline status view
- Change data view (hex, bin, dec, signed, unsigned)
- Highlight value changes
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
    control = Controller()
    gui = GUI(control)
    
    