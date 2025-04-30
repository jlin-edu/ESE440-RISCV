import subprocess

vivado_path = r"C:\Xilinx\Vivado\2018.2\bin\vivado.bat"
xsct_path = r"C:\Xilinx\SDK\2018.2\bin\xsct"
script_path = r".\commands.tcl"

vivado_commands = [r"open_project C:/Users/SDL/Desktop/pipelined_03272025/pipelined_03272025/pipelined_03272025.xpr",
                    r"launch_sdk -workspace C:/Users/SDL/Desktop/pipelined_03272025/pipelined_03272025/pipelined_03272025.sdk -hwspec C:/Users/SDL/Desktop/pipelined_03272025/pipelined_03272025/pipelined_03272025.sdk/base_zynq_wrapper.hdf"]
vivado_launch = [vivado_path, "-mode", "tcl"]
"""process = subprocess.Popen(launch, 
                           stdin=subprocess.PIPE, 
                           stdout=subprocess.PIPE, 
                           stderr=subprocess.PIPE, 
                           text=True)
"""
subprocess.run([xsct_path, script_path], shell=True)