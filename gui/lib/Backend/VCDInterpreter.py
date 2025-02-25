
# IDEA: Use reset signal to determine when program loading ends and execution begins 
#           -> Have GUI toggle between seeing program load and only seeing execution

class VCDInterpreter:
    def __init__(self, VCDdata=None, memsize=1024):
        self.VCDdata = VCDdata
        self.memsize = memsize
        
        self.state = None
        
        # REPLACE WITH WIRE NAMES
        self.clk_net = "clk"
        self.reset_net = "reset"
        self.pc_net = "pc"
        self.regs_net = "register_file"
        self.inst_net = "inst_mem"
        self.data_net = "data_mem"
        
        # Symbols for each value
        self.clk = None
        self.reset = None
        self.pc = None
        self.regs = None
        self.inst = None
        self.data = None
    
    def load(self, data):
        self.VCDdata = data
    
    def extract(self, time):
        self.state = [0, [0 for i in range(32)], [0 for i in range(self.memsize)], [0 for i in range(self.memsize)]]
        self.state[0] = self.get_pc(time)
        self.state[1] = self.get_regs(time)
        self.state[2] = self.get_inst(time)
        self.state[3] = self.get_data(time)
        return self.state
    
    def get_pc(self, time):
        self.pc = self.get_net(self.pc, self.pc_net)
        data = self.VCDdata[self.pc]
        
        pc = 0
        for time_data, value in data[1].items():
            if time_data > time:
                break
            pc = -1 if value[1] == 'x' else int(value[1:], 2)
        return pc
    
    def get_regs(self, time):
        self.regs = self.get_net(self.regs, self.regs_net)
        data = self.VCDdata[self.regs]
        
        reg_data = 0
        for time_data, value in data[1].items():
            if time_data > time:
                break
            reg_data = 'b0' if value[1] == 'x' else value
        regs = [0 for i in range(31)]
        self.unpack(reg_data, regs)
        regs.insert(0, 0)
        return regs

    
    def get_inst(self, time):
        self.inst = self.get_net(self.inst, self.inst_net)
        data = self.VCDdata[self.inst]
        
        mem_data = 0
        for time_data, value in data[1].items():
            if time_data > time:
                break
            mem_data = 'b0' if len(value) <= 2 else value
        mem = [0 for i in range(self.memsize)]
        self.unpack(mem_data[1:], mem)
        return mem
    
    def get_data(self, time):
        self.data = self.get_net(self.data, self.data_net)
        data = self.VCDdata[self.data]
        
        mem_data = 0
        for time_data, value in data[1].items():
            if time_data > time:
                break
            mem_data = 'b0' if value[1] == 'x' else value
        mem = [0 for i in range(self.memsize)]
        self.unpack(mem_data, mem)
        return mem
    
    def get_time(self):
        self.clk = self.get_net(self.clk, self.clk_net)
        data = self.VCDdata[self.clk]
        return list(data[1].keys())[-1] # last time in clk data is most current time of simulation
    
    def get_period(self):
        self.clk = self.get_net(self.clk, self.clk_net)
        data = self.VCDdata[self.clk]
        return list(data[1].keys())[2] # index 0 is start, 1 is rising edge, 2 is falling edge. Thus 2 is the first full cycle
    
    def get_reset(self):
        self.reset = self.get_net(self.reset, self.reset_net)
        data = self.VCDdata[self.reset]
        return list(data[1].keys())[1] # reset will have an inital value, then the deassertion when instruction loading is finished
        
    def get_net(self, symbol, net):
        if not symbol:
            for key, value in self.VCDdata.items():
                if isinstance(value, list) and value[0] == net:
                    symbol = key
                    break
        return symbol
    
    def unpack(self, data, arr):
        if len(data) == 2:
            for i in range(len(arr)):
                arr[i] = int(data[1])
        elif len(data) - 1 <= 32:
            arr[0] = int(data[1:], 2)
        else:
            word_count = (len(data) - 1) // 32 # Calculate total number of full (32 bit) words. 
            partial_word = (len(data) - 1) - word_count*32 > 0 # Determine if there is a partial (<32 bit) word
            
            data = list(data)
            for i in range(len(data)):
                data[i] = '0' if data[i] == 'x' else data[i]
            data = "".join(data)
            
            if partial_word: # Read partial word if there is a one. It will be <32bits and is always the first word
                arr[word_count] = int(data[1:-word_count*32], 2)
            arr[0] = int(data[-32:], 2)
            for i in range(1, word_count):
                arr[i] = int(data[-((i+1)*32):-(i*32)], 2) # Get next word. Words in VCD are ordered backwards [word n, word n-1, ..., word 2, word 1, word 0]

        