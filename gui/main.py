from lib.Backend.Controller import Controller
from lib.Frontend.GUI import GUI

"""
TODO:
- Pipeline status view
- Change data view (hex, bin, dec, signed, unsigned)
- Highlight value changes
- Manually set time to go to + show current time
- Run TCL commands
- Change program file + display name (either through DPI or change SV file)
- Mode button: single cycle vs pipeline
"""


if __name__ == "__main__":
    control = Controller()
    gui = GUI(control)
    
    