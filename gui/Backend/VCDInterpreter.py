
# IDEA: Use reset signal to determine when program loading ends and execution begins 
#           -> Have GUI toggle between seeing program load and only seeing execution

class VCDInterpreter:
    def __init__(self, VCDdata, memsize=1024):
        self.VCDdata = VCDdata
        self.memsize = memsize
        
        self.state = None
        
        # REPLACE WITH WIRE NAMES
        self.pc_net = "pc"
        self.regs_net = "register_file"
        self.inst_net = ""
        self.data_net = "mem"
        
        # Symbols for each value
        self.pc = None
        self.regs = None
        self.inst = None
        self.data = None
    
    def extract(self, time):
        self.state = ['0', ['0' for i in range(32)], ['0' for i in range(self.memsize)], ['0' for i in range(self.memsize)]]
        self.get_pc(time)
        self.get_regs(time)
        self.get_inst(time)
        self.get_data(time)
    
    def get_pc(self, time):
        if not self.pc:
            for key, value in self.VCDdata.items():
                if isinstance(value, list) and value[0] == self.pc_net:
                    self.pc = key
                    break
        data = self.VCDdata[self.pc]
        
        pc = None
        for time_data, value in data[1].items():
            if time_data > time:
                break
            pc = value
        return pc
    
    def get_regs(self, time):
        if not self.regs[0]:
            for key, value in self.VCDdata.items():
                for i in range(3):
                    if value[i] == self.regs_net[i]:
                        self.regs[i] = key
                        break
        address = self.VCDdata[self.regs[0]]
        data = self.VCDdata[self.regs[1]]
        enable = self.VCDdata[self.regs[2]]
        
        reg_data = []

    
    def get_inst(self, time):
        pass
    
    def get_data(self, time):
        pass