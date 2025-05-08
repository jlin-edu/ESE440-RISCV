import serial
import serial.tools.list_ports
import subprocess
import os

from math import ceil

class SerialUART:
    def __init__(self, controller, mem_size):
        self.controller = controller
        self.mem_size = mem_size
        self.baud = 115200
        
        self.packet_size = 16
        self.packet_bytes = self.packet_size * 4
        self.num_packets = self.mem_size // self.packet_size
        
    def find_port(self):
        ports = serial.tools.list_ports.comports()
        for port in ports[::1]:
            if port.vid == 0x0403 and port.pid == 0x6010:
                self.com = port.device    
    
    def open(self):
        self.find_port()
        self.port = serial.Serial(self.com, self.baud)
        self.port.set_buffer_size(8192)
        self.controller.startSDK()
        
        data = b""
        while len(data) < 5:
            data += self.port.read(5 - len(data))
    
    def close(self):
        if self.port:
            self.send("QUIT")
            self.port.close()
    
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
    
    def send_file_packet(self, bin):
        data = b""
        while len(data) < 2:
            data += self.port.read(2 - len(data))
        with open(bin, 'rb') as program:
            for _ in range(self.num_packets):
                packet = []
                for _ in range(self.packet_size):
                    word = program.read(4)[::-1]
                    packet +=  list(bytearray(word)) if word else list(bytearray([0, 0, 0, 0]))
                self.port.write(bytes(packet))
                
                data = b""
                while len(data) < 2:
                    data += self.port.read(2 - len(data))
    
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
    
    def recv_state_packet(self):
        state = [0, [0 for i in range(32)], [0 for i in range(self.mem_size // 2)], [0 for i in range(self.mem_size // 2)]]
        for i in [2, 3]:
            total_bytes = b""
            self.port.write("OK".encode())
            for _ in range(self.num_packets // 2):
                packet = b""
                while len(packet) < self.packet_bytes:
                    packet += self.port.read(self.packet_bytes - len(packet))
                total_bytes += packet
                self.port.write("OK".encode())
            
            for j in range(0, len(total_bytes), 4):
                word_bytes = bytes(total_bytes[j:j+4])
                word = int.from_bytes(word_bytes)
                state[i][j//4] = word
        return state