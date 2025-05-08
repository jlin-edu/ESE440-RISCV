#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xuartps.h"
#include "sleep.h"

#define MEM_SIZE 2048
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
#define WORD_SIZE 4 	// 4 bytes per word
#define PACKET_SIZE 16
#define PACKET_BYTES (PACKET_SIZE * WORD_SIZE)
#define MEM_PACKETS (MEM_SIZE / PACKET_SIZE)
#define DATA_PACKETS (DATA_SIZE / PACKET_SIZE)
#define INSTR_PACKETS (INSTR_SIZE / PACKET_SIZE)

#define COMMAND_SIZE 4 // Size of commands (LOAD, RUNP, QUIT)

#define UART_DEVICE_ID XPAR_XUARTPS_0_DEVICE_ID

#define ASSERT_RESET hw[0] = 1;
#define DEASSERT_RESET hw[0] = 0;

volatile unsigned int* bram = (volatile unsigned int*)XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR;
volatile unsigned int* hw = (volatile unsigned int*)XPAR_PIPELINED_NEW_0_S00_AXI_BASEADDR;

u32 initData[DATA_SIZE];

static u8 SendBuffer[32];
static u8 RecvBuffer[32];

static u8 PacketBuffer[PACKET_BYTES];

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


void sendPacket(int start) {
	for (int i = 0; i < PACKET_SIZE; i++) {
		u32 word = bram[start + i];
		for (int j = 0; j < WORD_SIZE; j++)
			PacketBuffer[WORD_SIZE * i + j] = (word  >> (8 * (3 - j))) & 0xff;
	}
	XUartPs_Send(&Uart_PS, PacketBuffer, PACKET_BYTES);
	receiveN(2);
}

void recvPacket(int start) {
	int RecvCount = 0;
	while (RecvCount < PACKET_BYTES)
		RecvCount += XUartPs_Recv(&Uart_PS, &PacketBuffer[RecvCount], PACKET_BYTES - RecvCount);
	for (int i = 0; i < PACKET_SIZE; i++) {
		u32 word = 0;
		for (int j = 0; j < WORD_SIZE; j++)
			word = (word << 8) + PacketBuffer[WORD_SIZE * i + j];
		bram[start + i] = word;
	}
	sendStr("OK", 2);
}

void receiveProgram() {
	sendStr("OK", 2);
	for (int i = 0; i < MEM_PACKETS; i++)
		recvPacket(PACKET_SIZE * i);
}

void sendInstructions() {
	receiveN(2);
	for (int i = 0; i < INSTR_PACKETS; i++)
		sendPacket(PACKET_SIZE * i);
}

void sendState() {
	receiveN(2);
	for (int i = 0; i < DATA_PACKETS; i++)
		sendPacket(PACKET_SIZE * i + DATA_MEM);
}

int main() {
    init_platform();
    ASSERT_RESET;
    resetMem();
    setupUart();
    sendStr("READY", 5);

    while(1) {
    	receiveN(COMMAND_SIZE); // Get command
    	if(isCommand("LOAD")) {
    		ASSERT_RESET;
    		resetMem();
    		receiveProgram();
    		storeData();
    		sendInstructions();
    		sendState();

    	} else if(isCommand("RUNP")) {
    		ASSERT_RESET;
    		resetData();
    		DEASSERT_RESET;
    		while(hw[1]);
    		sendInstructions();
    		sendState();

    	} else if(isCommand("PRIN")) {
    		printInst();
    		printData();

    	} else if(isCommand("QUIT")) {
    		break;
    	}
    }

    cleanup_platform();
    return 0;
}

