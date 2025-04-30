import serial
import subprocess
import os

port = "COM5"
baudrate = 115200

try:
    ser = serial.Serial(port, baudrate)
    print(f"Connected to {port} at {baudrate} baud")
except serial.SerialException as e:
    print(f"Error opening serial port: {e}")
    exit()

while True:
    data = ser.readline()
    if data:
        decoded_data = data.decode('utf-8').strip()
        if decoded_data == "READY":
            break

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

        with open(programName + ".bin", 'rb') as program:
            count = 0
            word = program.read(4)[::-1]
            while word:
                ser.write(word)
                count += 1
                word = program.read(4)[::-1]
            for i in range(count, 1024):
                ser.write(bytes([0, 0, 0, 0]))
        print("Done loading program")

        print("Instruction memory after loading:")
        while True:
            data = ser.readline()
            if data:
                decoded_data = data.decode('utf-8').strip()
                if decoded_data == "DONE":
                    break
                print(f"{decoded_data}")

    elif userCommand == 'R':
        print("Running program...")
        ser.write("RUNP".encode())
        try:
            while True:
                data = ser.readline()
                if data:
                    decoded_data = data.decode('utf-8').strip()
                    if decoded_data == "DONE":
                        break
                    elif decoded_data == "PROGRAM_DONE":
                        print("Program finished, displaying results:")
                    else: 
                        print(f"{decoded_data}")
        except serial.SerialException as e:
            print(f"Error: {e}")
        except KeyboardInterrupt:
            print("Exiting...")

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