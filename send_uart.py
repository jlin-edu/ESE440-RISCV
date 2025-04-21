import serial

port = "COM5"
baudrate = 115200

try:
    ser = serial.Serial(port, baudrate)
    print(f"Connected to {port} at {baudrate} baud")
except serial.SerialException as e:
    print(f"Error opening serial port: {e}")
    exit()

"""userProgram = input("Enter the program to use:")
with open(userProgram, 'r') as program:
    lines = program.readlines()
    num_lines = len(lines)
    data = num_lines.to_bytes(2).decode()
    ser.write(data.encode())
    for line in lines:
        data = "".join([int(line[8*i:8*(i+1)], 2).to_bytes(1).decode() for i in range(4)])
        ser.write(data.encode())"""

data = "hello world"
try:
    ser.write(data.encode())
    print(f"Sent: {data}")
except serial.SerialException as e:
    print(f"Error writing to serial port: {e}")


try:
    while True:
        data = ser.readline()

        if data:
            decoded_data = data.decode('utf-8').strip()
            print(f"Received: {decoded_data}")

except serial.SerialException as e:
    print(f"Error: {e}")
except KeyboardInterrupt:
    print("Exiting...")
finally:
    ser.close()

