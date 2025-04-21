import serial

port = "COM5"
baudrate = 115200

try:
    ser = serial.Serial(port, baudrate)
    print(f"Connected to {port} at {baudrate} baud")
except serial.SerialException as e:
    print(f"Error opening serial port: {e}")
    exit()


data = "Hello world"

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

