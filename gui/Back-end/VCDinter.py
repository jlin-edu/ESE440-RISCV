class VCDinter:
    def __init__(self, file):
        self.file = file
        self.open(self.file)
        self.cache = {} # Cache for last data collection, used when a read call is made before any new changes

    def read(self):
        # Read any new changes since last time
        if self.cache["time"] != self.get_time():
            self._init()
            self._parse()
            self._scan()
            self.cache = None # REPLACE WITH CORRECT VALUE
        return self.cache
        
    def _init(self):
        pass # Internal method to initialize for file reading
        
    def _parse(self):
        pass # Internal method to parse file
    
    def _scan(self):
        pass # Internal method to scan file data and extract needed values
    
    
    def open(self):
        pass # Open vcd file to monitor

    def close(self):
        pass # Close the vcd file being monitored
    
    def quit(self):
        # Destroy itself
        self.close()
    
    
    def get_time(self):
        pass # Get most recent time from file
    
    
    
    
    
    # Output: Dictionary with entries each signal (of importance?) in the design, 
    #         each mapped to a dictionary of their value changes with time stamps