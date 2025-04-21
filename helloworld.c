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
#include "xparameters.h"
#include "platform.h"
#include "xil_printf.h"
//#include "xscugic.h"
//#include "xil_exception.h"
#include "xuartps.h"
#include "sleep.h"

#define size 40
#define DATA_MEM 512
#define MEM_SIZE 1024

#define UART_DEVICE_ID XPAR_XUARTPS_0_DEVICE_ID
//#define INTC_DEVICE_ID XPAR_SCUGIC_SINGLE_DEVICE_ID
//#define UART_INT_IRQ_ID XPAR_XUARTPS_1_INTR

volatile unsigned int* bram = (volatile unsigned int*)XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR;
volatile unsigned int* hw = (volatile unsigned int*)XPAR_PIPELINED_NEW_0_S00_AXI_BASEADDR;

int instructions[512]; // Array to write all instructions to from UART
static u8 SendBuffer[32];
static u8 RecvBuffer[32];

//volatile int TotalReceivedCount;
//volatile int TotalSentCount;

XUartPs Uart_PS;
//XScuGic InterruptController;

//void Handler(void* CallbeckRef, u32 Event, unsigned int EventData) {
//	if (Event == XUARTPS_EVENT_SENT_DATA)
//		TotalSentCount = EventData;
//
//	if (Event == XUARTPS_EVENT_RECV_DATA || Event == XUARTPS_EVENT_RECV_TOUT)
//		TotalReceivedCount = EventData;
//}

void setupUart() {
	XUartPs_Config* Config = XUartPs_LookupConfig(UART_DEVICE_ID);
	XUartPs_CfgInitialize(&Uart_PS, Config, Config->BaseAddress);
	for (int i = 0; i < 32; i++) {
		SendBuffer[i] = '0' + i;
		RecvBuffer[i] = 0;
	}

//	//Setup Interrupts
//	XScuGic_Config *IntcConfig = XScuGic_LookupConfig(INTC_DEVICE_ID);
//	XScuGic_CfgInitialize(&InterruptController, IntcConfig, IntcConfig->CpuBaseAddress);
//	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler, &InterruptController);
//	XScuGic_Connect(&InterruptController, UART_INT_IRQ_ID, (Xil_ExceptionHandler)XUartPs_InterruptHandler, (void*)&Uart_PS);
//	XScuGic_Enable(&InterruptController, UART_INT_IRQ_ID);
//	Xil_ExceptionEnable();
//
//	XUartPs_SetHandler(&Uart_PS, (XUartPs_Handler)Handler, &Uart_PS);
//	u32 IntrMask = XUARTPS_IXR_TOUT | XUARTPS_IXR_PARITY | XUARTPS_IXR_FRAMING |
//			XUARTPS_IXR_OVER | XUARTPS_IXR_TXEMPTY | XUARTPS_IXR_RXFULL |
//			XUARTPS_IXR_RXOVR;
//	XUartPs_SetInterruptMask(&Uart_PS, IntrMask);
//
//	XUartPs_SetRecvTimeout(&Uart_PS, 8);
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

    xil_printf("\r\nClearing BRAM values:\r\n");
    for (int i = 0 ; i < MEM_SIZE; i++)
    	bram[i] = 0;

    xil_printf("Writing to BRAM...\r\n");
    bram[0] = 0x0ff00093;
    bram[1] = 0x00102023;


    xil_printf("After writing, BRAM values:\r\n");
    for (int i = 0; i < size; i++)
    	xil_printf("bram[%d] = %x\r\n", i, bram[i]);

    xil_printf("Running program...\r\n");
    hw[0] = 0;

    sleep(1);

    xil_printf("Program finished, displaying results:\r\n");
    for (int i = DATA_MEM; i < DATA_MEM+15; i++)
    	xil_printf("bram[%d] = %x\r\n", i, bram[i]);


    cleanup_platform();
    return 0;
}
