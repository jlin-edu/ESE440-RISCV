import serial
import subprocess
import os
import time
from math import ceil

port = "COM4"
baudrate = 115200

packet_size = 16
mem_size = 16834
num_packets = mem_size // packet_size
packet_bytes = 4 * packet_size

try:
    ser = serial.Serial(port, baudrate)
    print(f"Connected to {port} at {baudrate} baud")
except serial.SerialException as e:
    print(f"Error opening serial port: {e}")
    exit()
ser.set_buffer_size(8192)

data = b""
while len(data) < 5:
    data += ser.read(5 - len(data))
#print(data)
while True:
    userCommand = input("Enter command (L = Load program, R = Run program, P = Print memory, Q = Quit): ")
    while not userCommand in ['L', 'R', 'P', 'Q']:
        userCommand = input("Invalid commmand, try again: ")

    if userCommand == 'L':
        userProgram = input("Enter the program to use: ")
        ser.write("LOAD".encode())
        print("Loading program...")
        programName = userProgram[:userProgram.rfind('.')]
        if not os.path.exists(programName + ".bin"): # Check version up to date
            path = os.path.dirname(os.path.abspath(__file__))
            compiler = subprocess.Popen([path + "\\compile.bat"], stdin=subprocess.PIPE, shell=True)
            compiler.communicate(input=programName.encode())
            compiler.wait()
        num_instr_packets = ceil(os.path.getsize(programName + ".bin") / packet_bytes)
        
        # with open(programName + ".bin", 'rb') as program:
        #     count = 0
        #     word = program.read(4)[::-1]
        #     while word:
        #         ser.write(word)
        #         count += 1
        #         word = program.read(4)[::-1]
        #     for i in range(count, 1024):
        #         ser.write(bytes([0, 0, 0, 0]))

        before = time.time()

        data = b""
        while len(data) < 2:
            data += ser.read(2 - len(data))
        #print(data)
        with open(programName + ".bin", 'rb') as program:
            for _ in range(num_packets):
                packet = []
                for _ in range(packet_size):
                    word = program.read(4)[::-1]
                    packet = packet + list(bytearray(word)) if word else packet + list(bytearray([0, 0, 0, 0]))
                ser.write(bytes(packet))
                
                data = b""
                while len(data) < 2:
                    data += ser.read(2 - len(data))
                #print(data)
        print("Done loading program")
        
        after = time.time()
        print(f"Took: {after-before}")

        print("Memory after loading:")
        # while True:
        #     data = ser.readline()
        #     if data:
        #         decoded_data = data.decode('utf-8').strip()
        #         if decoded_data == "DONE":
        #             break
        #         print(f"{decoded_data}")

        before = time.time()
        
        total_bytes = b""
        ser.write("OK".encode())
        for j in range(num_packets//2):
            packet = b""
            while len(packet) < packet_bytes:
                packet += ser.read(packet_bytes - len(packet))
            #print(packet)
            total_bytes += packet
            ser.write("OK".encode())
        
        ser.write("OK".encode())
        for j in range(num_packets//2):
            packet = b""
            while len(packet) < packet_bytes:
                packet += ser.read(packet_bytes - len(packet))
            #print(packet)
            total_bytes += packet
            ser.write("OK".encode())
        
        after = time.time()
        print(f"Took: {after-before}")
        input("Press enter to see results: ")
            
        for i in range(0, len(total_bytes), 4):
            word_bytes = bytes(total_bytes[i:i+4])
            word = int.from_bytes(word_bytes)
            print(f"bram[{i//4}] = 0x{word:x}")

    elif userCommand == 'R':
        print("Running program...")
        ser.write("RUNP".encode())
        # while True:
        #     data = ser.readline()
        #     if data:
        #         decoded_data = data.decode('utf-8').strip()
        #         if decoded_data == "DONE":
        #             break
        #         elif decoded_data == "PROGRAM_DONE":
        #             print("Program finished, displaying results:")
        #         else: 
        #             print(f"{decoded_data}")
        
        for j in range(num_packets):
            packet = bytearray(ser.read(packet_bytes))
            words = [int.from_bytes(bytes([packet[i], packet[i+1], packet[i+2], packet[i+3]])) for i in range(0, packet_size, 4)]
            for k, word in enumerate(words):
                print(f"bram[{packet_size * j + k}] = 0x{word:x}")

    elif userCommand == 'P':
        print("Printing memory...")
        ser.write("PRIN".encode())
        while True:
            data = ser.readline()
            if data:
                decoded_data = data.decode('utf-8').strip()
                if decoded_data == "DONE":
                    break
                print(f"{decoded_data}")

    elif userCommand == 'Q':
        print("Quitting...")
        ser.write("QUIT".encode())
        ser.close()
        break