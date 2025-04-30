import serial
import serial.tools.list_ports
import subprocess
import os

class SerialUART:
    def __init__(self, controller, mem_size):
        self.controller = controller
        self.mem_size = mem_size
        self.baud = 115200
        
    def find_port(self):
        ports = serial.tools.list_ports.comports()
        for port in ports:
            if port.vid == 0x0403 and port.pid == 0x6010:
                self.com = port.device;    
    
    def open(self):
        self.find_port();
        self.port = serial.Serial(self.com, self.baud)
        while True:
            data = self.receive()
            if data and data == "READY":
                return
    
    def close(self):
        if self.port:
            self.send("QUIT")
            self.port.close();
    
    def send(self, data):
        self.port.write(data.encode())
    
    def receive(self):
        data = self.port.readline()
        return data.decode("utf-8").strip() if data else None
    
    def getName(self, Cfile):
        return Cfile[:Cfile.rfind('.')]
    
    def CtoBin(self, Cfile):
        programName = self.getName(Cfile)
        return programName + ".bin"
    
    def binUTD(self, bin, Cfile):
        return os.path.exists(bin) and not (os.path.getmtime(Cfile) > os.path.getmtime(bin))
    
    def compileC(self, programName):
        compiler = subprocess.Popen([self.controller.path + "\\compiler\\compile.bat"], stdin=subprocess.PIPE, shell=True)
        compiler.communicate(input=programName.encode())
        compiler.wait()
    
    def send_file(self, bin):
        with open(bin, 'rb') as program:
            count = 0
            word = program.read(4)[::-1]
            while word:
                self.port.write(word)
                count += 1
                word = program.read(4)[::-1]
            for i in range(count, self.mem_size):
                self.port.write(bytes([0, 0, 0, 0]))
                
    def recv_state(self):
        state = [0, [0 for i in range(32)], [0 for i in range(self.mem_size // 2)], [0 for i in range(self.mem_size // 2)]]
        count = 0
        while True:
            data = self.receive()
            if data:
                if data == "DONE":
                    break
                elif data == "PROGRAM_DONE":
                    continue
                data_val = int(data[data.find("0x")+2:], 16)
                if count < self.mem_size // 2:
                    state[2][count] = data_val
                else:
                    state[3][count - (self.mem_size // 2)] = data_val
                count += 1
        return state
