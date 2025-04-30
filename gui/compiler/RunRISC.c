/*
 * RunRISC.c: program to run on the ARM core of the Minized
 * 			  to control the RISC-V processor
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xuartps.h"
#include "sleep.h"

#define MEM_SIZE 1024
#define INSTR_SIZE (MEM_SIZE/2)
#define DATA_SIZE (MEM_SIZE/2)
#define DATA_BLOCK_SIZE (DATA_SIZE/4)

#define INSTR_MEM 0
#define DATA_MEM (MEM_SIZE/2)
#define DATA_BLOCK_0 DATA_MEM
#define DATA_BLOCK_1 (DATA_BLOCK_0 + DATA_BLOCK_SIZE)
#define DATA_BLOCK_2 (DATA_BLOCK_1 + DATA_BLOCK_SIZE)
#define DATA_BLOCK_3 (DATA_BLOCK_2 + DATA_BLOCK_SIZE)

#define INSTRUCTION_COUNT 2 // 2 bytes
#define INSTRUCTION_SIZE 4 	// 4 bytes per word

#define COMMAND_SIZE 4 // Size of commands (LOAD, RUNP, QUIT)

#define UART_DEVICE_ID XPAR_XUARTPS_0_DEVICE_ID

#define ASSERT_RESET hw[0] = 1;
#define DEASSERT_RESET hw[0] = 0;

volatile unsigned int* bram = (volatile unsigned int*)XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR;
volatile unsigned int* hw = (volatile unsigned int*)XPAR_PIPELINED_NEW_0_S00_AXI_BASEADDR;

u32 initData[DATA_SIZE];

static u8 SendBuffer[32];
static u8 RecvBuffer[32];

XUartPs Uart_PS;
void setupUart() {
	XUartPs_Config* Config = XUartPs_LookupConfig(UART_DEVICE_ID);
	XUartPs_CfgInitialize(&Uart_PS, Config, Config->BaseAddress);
	for (int i = 0; i < 32; i++) {
		SendBuffer[i] = 0;
		RecvBuffer[i] = 0;
	}
}

void resetMem() {
	for (int i = 0 ; i < MEM_SIZE; i++)
		bram[i] = 0;
}

void storeData() {
	for (int i = DATA_MEM; i < DATA_MEM + DATA_SIZE; i++)
		initData[i - DATA_MEM] = bram[i];
}

void resetData() {
	for (int i = DATA_MEM; i < DATA_MEM + DATA_SIZE; i++)
		bram[i] = initData[i - DATA_MEM];
}

void printMem(int start, int count, char* name) {
	for (int i = start; i < start + count; i++)
		xil_printf("%s[%d] = 0x%x\r\n", name, i - start, bram[i]);
}

void printInst() {
	printMem(INSTR_MEM, INSTR_SIZE, "INSTR");
}

void printData() {
	printMem(DATA_MEM, DATA_SIZE, "DATA");
}

int isCommand(char command[COMMAND_SIZE + 1]) {
	for (int i = 0; i < 4; i++) {
		if (RecvBuffer[i] != command[i])
			return 0;
	}
	return 1;
}

void receiveN(int numBytes) {
	int RecvCount = 0;
	while (RecvCount < numBytes)
		RecvCount += XUartPs_Recv(&Uart_PS, &RecvBuffer[RecvCount], numBytes - RecvCount);
}

void sendStr(char* string, int numBytes) {
	for (int i = 0; i < numBytes; i++)
		SendBuffer[i] = string[i];
	XUartPs_Send(&Uart_PS, SendBuffer, numBytes);
	int count = 0;
	while (XUartPs_IsSending(&Uart_PS)) count++;
}

void receiveInstructions() {
	for (int i = 0; i < MEM_SIZE; i++) {
		receiveN(INSTRUCTION_SIZE);
		u32 instruction = 0;
		for (int j = 0; j < INSTRUCTION_SIZE; j++)
			instruction = (instruction << 8) + RecvBuffer[j];
		bram[i] = instruction;
	}
}

int main() {
    init_platform();
    ASSERT_RESET;
    resetMem();
    setupUart();
    xil_printf("READY\r\n");

    while(1) {
    	receiveN(COMMAND_SIZE); // Get command
    	if(isCommand("LOAD")) {
    		ASSERT_RESET;
    		resetMem();
    		receiveInstructions();
    		storeData();
    		printInst();
    		printData();

    	} else if(isCommand("RUNP")) {
    		ASSERT_RESET;
    		resetData();
    		DEASSERT_RESET;
    		while(hw[1]);
    		xil_printf("PROGRAM_DONE\r\n");
		printInst();
    		printData();

    	} else if(isCommand("PRIN")) {
    		printInst();
    		printData();

    	} else if(isCommand("QUIT")) {
    		break;
    	}
    	xil_printf("DONE\r\n");
    }

    cleanup_platform();
    return 0;
}
