#monitor the whole DUT or just the PC + REGS + MEMS?

class VCDInterface:
    def __init__(self, filename):
        self.filename = filename
        self.file = None
        
        self.open()
        
        self.cache = None # Cache for last data collection, used when a read call is made before any new changes

    def read(self):
        # Read any new changes since last time
        if not self.cache or self.cache["time"] != self.get_time():
            self._init()
            self._parse()
        return self.cache
        
    def _init(self):
        self.cache = {"time": 0}
        
        # Read time scale
        file_line = None
        self.file.seek(0, 0)
        while (file_line != "$timescale"):
            file_line = self.readline()
        self.cache["timescale"] = self.readline()
        
        # Read vars
        while (file_line != "$dumpvars"):
            file_line = self.readline()
            if file_line[:len("$var")] == "$var":
                line_contents = file_line.split(' ')
                if not line_contents[3] in self.cache:
                    self.cache[line_contents[3]] = [line_contents[4], {}]
        
    def _parse(self):
        file_line = None
        time = 0
        while (file_line != ""):
            file_line = self.file.readline()
            if file_line == "" or file_line == "\n" or file_line[0] == '$': 
                continue
            file_line = file_line.strip()
            
            if file_line[0] == '#':
                time = int(file_line[1:])
                self.cache["time"] = time
            else:
                line_contents = file_line.split(' ')
                if len(line_contents) == 1:
                    line_contents.append(line_contents[0][1])
                    line_contents[0] = line_contents[0][0]
                self.cache[line_contents[1]][1][time] = line_contents[0]    
    
    def readline(self):
        return self.file.readline().strip()
    
    
    def open(self):
        if self.file:
            print("Error: File already open")
            return
        self.file = open(self.filename, 'r')
        if not self.file:
            print(f"Error opening file: {self.filename}")

    def close(self):
        if not self.file:
            print("Error: No file open")
            return
        self.file.close()
    
    def quit(self):
        self.close()
    
    
    def get_time(self):
        self.file.seek(0, 0)
        file_line = self.file.readline()
        last_time = 0
        while(file_line != ""):
            if (file_line[0] == '#'):
                last_time = int(file_line[1:-1])
            file_line = self.file.readline()
        return last_time
    
    # Output: Dictionary with entries each signal (of importance?) in the design, 
    #         each mapped to a dictionary of their value changes with time stamps
    
from VCDInterpreter import VCDInterpreter
    
if __name__ == "__main__":
    test = VCDInterface("C:/Users/Alecm/Desktop/Programming/Vivado/Dire-WolVes/Pipelined Processor/Pipelined Processor.sim/sim_1/behav/xsim/test.vcd")
    test_interp = VCDInterpreter(test.read())