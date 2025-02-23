from .VCDInterpreter import VCDInterpreter
from .VCDInterface import VCDInterface

class Controller:
    def __init__(self):
        self.VCD_inter = VCDInterface() # TODO: Functions to change VCDinterface file
        self.VCD_interp = VCDInterpreter() # TODO: Functions to change VCDInterpreter data