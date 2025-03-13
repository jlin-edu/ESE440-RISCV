#monitor the whole DUT or just the PC + REGS + MEMS?

class VCDInterface:
    def __init__(self, file_name=None):
        self.file_name = file_name
        self.file = None
        self.cache = None # Cache for last data collection, used when a read call is made before any new changes
        
        if file_name:
            self.open()

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
        seen_mem = False
        while (file_line != "$enddefinitions $end"):
            file_line = self.readline()
            if file_line[:len("$var")] == "$var":
                line_contents = file_line.split(' ')
                if line_contents[4] == "mem":
                    if seen_mem == False:
                        line_contents[4] = "inst_mem"
                        seen_mem = True
                    else:
                        line_contents[4] = "data_mem"
                
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
    
    def open(self, file_name=None):
        if self.file:
            print("Error: File already open")
            return
        if file_name:
            self.file_name = file_name
        self.file = open(self.file_name, 'r')
        if not self.file:
            print(f"Error opening file: {self.file_name}")

    def close(self):
        if not self.file:
            print("Error: No file open")
            return
        self.file.close()
    
    def quit(self):
        self.close()
    
    # Obsolete time function, use VCDInterpreter.get_time()
    def get_time(self):
        self.file.seek(0, 0)
        file_line = self.file.readline()
        last_time = 0
        while(file_line != ""):
            if (file_line[0] == '#'):
                last_time = int(file_line[1:-1])
            file_line = self.file.readline()
        return last_time

    
        