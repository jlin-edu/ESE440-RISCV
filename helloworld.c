/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
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

#define UART_DEVICE_ID XPAR_XUARTPS_0_DEVICE_ID

volatile unsigned int* bram = (volatile unsigned int*)XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR;
volatile unsigned int* hw = (volatile unsigned int*)XPAR_PIPELINED_NEW_0_S00_AXI_BASEADDR;

static u8 SendBuffer[32];
static u8 RecvBuffer[4];

XUartPs Uart_PS;
void setupUart() {
	XUartPs_Config* Config = XUartPs_LookupConfig(UART_DEVICE_ID);
	XUartPs_CfgInitialize(&Uart_PS, Config, Config->BaseAddress);
	for (int i = 0; i < 32; i++) {
		SendBuffer[i] = '0' + i;
		RecvBuffer[i] = 0;
	}
}

void resetMem() {
	xil_printf("\r\nClearing BRAM values:\r\n");
	for (int i = 0 ; i < MEM_SIZE; i++)
		bram[i] = 0;
}

void printMem(int start, int count) {
	for (int i = start; i < start + count; i++)
		xil_printf("bram[%d] = 0x%x\r\n", i, bram[i]);
}

void printMemN(int N) {
	xil_printf("After writing, BRAM values:\r\n");
	printMem(0, N);
}

void printInst() {
	xil_printf("Instruction memory:\r\n");
	printMem(INSTR_MEM, INSTR_SIZE);
}

void printData() {
	xil_printf("Data memory:\r\n");
	printMem(DATA_MEM, DATA_SIZE);
}


void receiveInstructions() {
	int RecvCount = 0;
	while (RecvCount < INSTRUCTION_COUNT) // Get number of instructions (2 bytes)
		RecvCount += XUartPs_Recv(&Uart_PS, &RecvBuffer[RecvCount], INSTRUCTION_COUNT - RecvCount);
	int NumInstructions = (RecvBuffer[0] << 8) + RecvBuffer[1];// MSB first

	for (int i = 0; i < NumInstructions; i++) {
		RecvCount = 0;
		while (RecvCount < INSTRUCTION_SIZE)
			RecvCount += XUartPs_Recv(&Uart_PS, &RecvBuffer[RecvCount], INSTRUCTION_SIZE - RecvCount);
		int instruction = 0;
		for (int j = 0; j < INSTRUCTION_SIZE; j++)
			instruction = (instruction << 8) + RecvBuffer[j];
		bram[i] = instruction;
	}
}

int main() {
    init_platform();
    hw[0] = 1;
    setupUart();


    int RecvCount = 0;
    while (RecvCount < 11)
    	RecvCount += XUartPs_Recv(&Uart_PS, &RecvBuffer[RecvCount], 11-RecvCount);

    XUartPs_Send(&Uart_PS, SendBuffer, 32);

    int loop = 0;
    while (XUartPs_IsSending(&Uart_PS))
    	loop++;

    xil_printf("\r\n");
    for (int i = 0; i < RecvCount; i++)
    	xil_printf("%c", RecvBuffer[i]);

    resetMem();

    xil_printf("Writing to BRAM...\r\n");
    bram[0] = 0x0ff00093;
    bram[1] = 0x00102023;

    printMemN(40);

    xil_printf("Running program...\r\n");
    hw[0] = 0;

    sleep(1);

    xil_printf("Program finished, displaying results:\r\n");
    for (int i = DATA_MEM; i < DATA_MEM+15; i++)
    	xil_printf("bram[%d] = %x\r\n", i, bram[i]);


    cleanup_platform();
    return 0;
}
