import subprocess
import os

from .VCDInterpreter import VCDInterpreter
from .VCDInterface import VCDInterface
from .SerialUART import SerialUART

class Controller:
    def __init__(self, path, mem_size):
        self.VCD_inter = VCDInterface() # TODO: Functions to change VCDinterface file
        self.VCD_interp = VCDInterpreter(memsize=mem_size) # TODO: Functions to change VCDInterpreter data
        self.UART = SerialUART(self, mem_size)
        self.GUI = None
        self.mode = "VCD" # VCD or serial mode
        
        self.path = path
        
        self.mem_size = mem_size
        
        self.reset_time = -1 # In future save times to make lookup faster
        self.time = -1
    
    def open_vcd(self, file_name):
        self.VCD_inter.open(file_name)
        self.read()
        self.time = self.VCD_interp.get_reset()
        self.run()
        self.close_vcd()
    
    def close_vcd(self):
        self.VCD_inter.close()
    
    def read(self):
        self.VCD_data = self.VCD_inter.read()
        self.VCD_interp.load(self.VCD_data)
    
    def play(self):
        if self.mode == "VCD":
            self.time = self.VCD_interp.get_time()
        self.run()
        
    def reset(self):
        self.time = self.VCD_interp.get_reset()
        self.run()
        
    def step_forward(self):
        self.time += self.VCD_interp.get_period()
        self.run()
    
    def step_backward(self):
        self.time -= self.VCD_interp.get_period()
        self.run()
    
    def run(self):
        if self.mode == "VCD":
            self.VCD_state = self.VCD_interp.extract(self.time)
            self.GUI.write(self.VCD_state)
        else:
            self.UART.send("RUNP")
            hardware_state = self.UART.recv_state_packet()
            #hardware_state = self.UART.recv_state()
            self.GUI.write(hardware_state)
        
    def file_open(self):
        if self.mode == "VCD":
            self.GUI.VCD_dialog()
        else:
            self.GUI.C_dialog()
    
    def connect(self):
        if self.mode == "VCD":
            self.mode = "SERIAL"
            self.GUI.change_mode()
            self.UART.open()
            self.GUI.reset_state()

    def get_Xil(self):
        if os.path.exists("C:/Xilinx"):
            return "C:/Xilinx"
        appdata_path = os.path.join(os.path.expanduser('~'), "AppData")
        for root, directories, _ in os.walk(appdata_path):
            for directory in directories:
                if directory == "Xilinx":
                    return os.path.join(root, directory)
        return self.GUI.Xilinx_dialog()

    def get_XPR(self):
        project_dir = self.path
        for _ in range(2):
            project_dir = os.path.dirname(project_dir)
        for root, _, files in os.walk(project_dir):
            for file in files:
                if file.find(".xpr") != -1:
                    return os.path.join(root, file)
        return self.GUI.XPR_dialog()
    
    def get_ELF(self, sdk_path):
        directories = [directory for directory in os.listdir(sdk_path) if os.path.isdir(os.path.join(sdk_path, directory))]
        for directory in directories:
            if directory + "_bsp" in directories and directory != "fsbl":
                return os.path.join(sdk_path, directory, "Debug", directory + ".elf")
        return self.GUI.sdk_dialog(sdk_path)

    def startSDK(self):
        xsct_path = os.path.join(self.get_Xil(), "SDK", "2018.2", "bin", "xsct").replace('\\', '/')
        template_path = os.path.join(self.path, "xsct_commands_template.tcl").replace('\\', '/')
        script_path = os.path.join(self.path, "xsct_commands.tcl").replace('\\', '/')
        
        xpr_path = self.get_XPR()
        project_path = os.path.dirname(xpr_path)
        project_name = os.path.basename(project_path)
        sdk_path = os.path.join(project_path, project_name + ".sdk")

        hw_path = os.path.join(sdk_path, "base_zynq_wrapper_hw_platform_0", "system.hdf").replace('\\', '/')
        bit_path = os.path.join(sdk_path, "base_zynq_wrapper_hw_platform_0", "base_zynq_wrapper.bit").replace('\\', '/')
        ps7_init_path = os.path.join(sdk_path, "base_zynq_wrapper_hw_platform_0", "ps7_init.tcl").replace('\\', '/')
        elf_path = self.get_ELF(sdk_path).replace('\\', '/')
        with open(script_path, 'w') as command_script:
            with open(template_path, 'r') as template_script:
                for line in template_script:
                    if line.find("HARDWARE") > 0:
                        pos = line.find("HARDWARE")
                        line = line[:pos] + hw_path + line[pos+len("HARDWARE"):]
                    elif line.find("BITSTREAM") > 0:
                        pos = line.find("BITSTREAM")
                        line = line[:pos] + bit_path + line[pos+len("BITSTREAM"):]
                    elif line.find("PS7_INIT") > 0:
                        pos = line.find("PS7_INIT")
                        line = line[:pos] + ps7_init_path + line[pos+len("PS7_INIT"):]
                    elif line.find("ELF") > 0:
                        pos = line.find("ELF")
                        line = line[:pos] + elf_path + line[pos+len("ELF"):]
                    command_script.write(line)
        subprocess.run([xsct_path, script_path], shell=True)
    
    def disconnect(self):
        if self.mode == "SERIAL":
            self.mode = "VCD"
            self.GUI.change_mode()
            self.UART.close()
            self.GUI.reset_state()
    
    def send_file(self, Cfile):
        programName = self.UART.getName(Cfile)
        binFile = self.UART.CtoBin(Cfile)
        if not self.UART.binUTD(binFile, Cfile):
            self.UART.compileC(programName)
            
        self.UART.send("LOAD")
        #self.UART.send_file(binFile)
        self.UART.send_file_packet(binFile)
        
        hardware_state = self.UART.recv_state_packet() #self.UART.recv_state()
        self.GUI.write(hardware_state)
    
    def test(self):
        self.play()
        self.VCD_inter.open(f"{self.path}\\Regression_Test.vcd")
        test_data = self.VCD_inter.read()
        self.VCD_interp.load(test_data)
        time = self.VCD_interp.get_time()
        test_state = self.VCD_interp.extract(time)
        self.VCD_inter.close()
        
        if self.VCD_state != test_state:
            print("Test Failed: Mismatching state")
        elif self.VCD_data != test_data:
            print("Test Failed: Signal Incorrect")
            
            failed_net = None
            fail_time = -1
            expected_val = None
            found_val = None
            for test_key, data_key in zip(test_data, self.VCD_data):
                test_values = test_data[test_key]
                data_values = self.VCD_data[data_key]
                
                if isinstance(test_values, list) and isinstance(data_values, list):
                    test_net = test_values[0]
                    test_times = test_values[1]
                    
                    data_net = data_values[0]
                    data_times = data_values[1]
                    
                    for i in range(len(test_times)):
                        test_time = list(test_times.keys())[i]
                        test_value = test_times[test_time]
                        
                        data_time = list(data_times.keys())[i]
                        data_value = data_times[data_time]
                        
                        if test_time != data_time:
                            print(f"Error: Missing time data at time {test_time} in net {test_net}")
                            break
                        
                        if test_value != data_value and (fail_time < 0 or test_time < fail_time):
                            fail_time = test_time
                            failed_net = test_net
                            expected_val = test_value
                            found_val = data_value
                        
            print(f"Error: net {failed_net} has incorrect value of {found_val} at time {fail_time}, expected {expected_val}")
                    
        else:
            print("Test Success!")
