
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
        self.inst_net = "inst_mem"
        self.data_net = "data_mem"
        
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
        
        pc = 0
        for time_data, value in data[1].items():
            if time_data > time:
                break
            pc = -1 if value[1] == 'x' else int(value[1:], 2)
        return pc
    
    def get_regs(self, time):
        if not self.regs:
            for key, value in self.VCDdata.items():
                if isinstance(value, list) and value[0] == self.regs_net:
                    self.regs = key
                    break
        data = self.VCDdata[self.regs]
        
        reg_data = 0
        for time_data, value in data[1].items():
            if time_data > time:
                break
            reg_data = '0' if value[1] == 'x' else value
        regs = [0 for i in range(31)]
        self.unpack(reg_data, regs)
        regs.insert(0, 0)
        return regs

    
    def get_inst(self, time):
        if not self.data:
            for key, value in self.VCDdata.items():
                if isinstance(value, list) and value[0] == self.inst_net:
                    self.data = key
                    break
        data = self.VCDdata[self.data]
        
        mem_data = 0
        for time_data, value in data[1].items():
            if time_data > time:
                break
            mem_data = '0' if len(value) <= 2 else value
        mem = [0 for i in range(self.memsize)]
        self.unpack(mem_data[1:], mem)
        return mem
    
    def get_data(self, time):
        if not self.inst:
            for key, value in self.VCDdata.items():
                if isinstance(value, list) and value[0] == self.inst_net:
                    self.inst = key
                    break
        data = self.VCDdata[self.inst]
        
        mem_data = 0
        for time_data, value in data[1].items():
            if time_data > time:
                break
            mem_data = '0' if value[1] == 'x' else value
        mem = [0 for i in range(self.memsize)]
        self.unpack(mem_data, mem)
        return mem
    
    def unpack(self, data, arr):
        word_count = (len(data) - 1) // 32 # Calculate total number of full (32 bit) words. 
        partial_word = (len(data) - 1) / 32 > word_count # Determine if there is a partial (<32 bit) word
        if partial_word: # Read partial word if there is a one. It will be <32bits and is always the first word
            arr[word_count] = int(data[1:-(1 + word_count*32)], 2)
        arr[0] = int(data[-32:], 2)
        for i in range(1, word_count):
            arr[i] = int(data[-((i+1)*32):-(i*32)], 2) # Get next word. Words in VCD are ordered backwards [word n, word n-1, ..., word 2, word 1, word 0]