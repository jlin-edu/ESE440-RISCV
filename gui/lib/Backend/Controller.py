from .VCDInterpreter import VCDInterpreter
from .VCDInterface import VCDInterface

class Controller:
    def __init__(self):
        self.VCD_inter = VCDInterface() # TODO: Functions to change VCDinterface file
        self.VCD_interp = VCDInterpreter() # TODO: Functions to change VCDInterpreter data
        self.GUI = None
        
        self.reset_time = -1 # In future save times to make lookup faster
        self.time = -1
    
    def open(self, file_name):
        self.VCD_inter.open(file_name)
        self.read()
        self.time = self.VCD_interp.get_reset()
        self.run()
    
    def read(self):
        self.VCD_data = self.VCD_inter.read()
        self.VCD_interp.load(self.VCD_data)
    
    def play(self):
        self.time = self.VCD_interp.get_time()
        self.run()
        
    def reset(self):
        self.time = self.VCD_interp.get_reset()
        self.run()
        
    def step_forward(self):
        self.time += self.VCD_interp.get_period()
        self.run()
    
    def step_backward(self):
        self.time -= self.VCD_interp.get_period()
        self.run()
    
    def run(self):
        self.VCD_state = self.VCD_interp.extract(self.time)
        self.GUI.write(self.VCD_state)