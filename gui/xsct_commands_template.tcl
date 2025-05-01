connect -url tcp:127.0.0.1:3121

# Load hardware platform
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Avnet MiniZed V1 1234-oj1A"} -index 0
loadhw -hw HARDWARE -mem-ranges [list {0x40000000 0xbfffffff}]
stop

# Ensure CPU is halted
configparams force-mem-access 1

# Program FPGA
fpga -f  BITSTREAM

# Run ps7_init
source PS7_INIT
ps7_init
ps7_post_config

# Reset processor
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Avnet MiniZed V1 1234-oj1A"} -index 0
rst -processor

# Load application
dow ELF

# Clear forced access
configparams force-mem-access 0

# Run program
con