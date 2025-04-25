import serial

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
    userCommand = input("Enter command (L = Load program, R = Run program, Q = Quit): ")
    while not userCommand in ['L', 'R', 'Q']:
        userCommand = input("Invalid commmand, try again: ")

    if userCommand == 'L':
        userProgram = input("Enter the program to use: ")
        ser.write("LOAD".encode())
        print("Loading program...")
        with open(userProgram, 'r') as program: # May need to wait for board to be ready
            lines = program.readlines()
            num_lines = len(lines)
            data = num_lines.to_bytes(2)
            ser.write(data)
            for line in lines:
                data = bytearray([int(line[8*i:8*(i+1)], 2) for i in range(4)])
                ser.write(data)
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
                    print(f"{decoded_data}")
        except serial.SerialException as e:
            print(f"Error: {e}")
        except KeyboardInterrupt:
            print("Exiting...")

    elif userCommand == 'Q':
        print("Quitting...")
        ser.write("QUIT".encode())
        ser.close()
        break