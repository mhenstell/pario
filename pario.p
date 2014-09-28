// \file
/** PRU based parallel output driver.
 *
 * Generates up to 55 output signals from a memory mapped user buffer.
 * Optionally also drive a clock on one pin.
 *
 */
.origin 0
.entrypoint START

#include "pru.hp"

START:
    // Enable OCP master port
    // clear the STANDBY_INIT bit in the SYSCFG register,
    // otherwise the PRU will not be able to write outside the
    // PRU memory space and to the BeagleBon's pins.
    LBCO	r0, C4, 4, 4
    CLR		r0, r0, 4
    SBCO	r0, C4, 4, 4

    // Configure the programmable pointer register for PRU0 by setting
    // c28_pointer[15:0] field to 0x0120.  This will make C28 point to
    // 0x00012000 (PRU shared RAM).
    MOV		r0, 0x00000120
    MOV		r1, CTPPR_0
    ST32	r0, r1

    // Configure the programmable pointer register for PRU0 by setting
    // c31_pointer[15:0] field to 0x0010.  This will make C31 point to
    // 0x80001000 (DDR memory).
    MOV		r0, 0x00100000
    MOV		r1, CTPPR_1
    ST32	r0, r1


// register map
// The first 8 must agree with the struct pario_cmd_t in pario.h
#define data_addr	r0
#define count		r1
#define pru0r30_mask	r2
#define delay_count	r3
#define pru0r30_data0	r10
#define pru0r30_data1	r11
#define pru0r30_data2	r12
#define pru0r30_data3	r13
#define pru0r30_data4	r14
#define pru0r30_data5	r15
#define pru0r30_data6	r16
#define pru0r30_data7	r17

#define delay_iter	r20


RESET:
	MOV data_addr, 0
	SBCO data_addr, CONST_PRUDRAM, 0, 4

READ_LOOP:
	LBCO data_addr, CONST_PRUDRAM, 0, 4*4
	QBEQ READ_LOOP, data_addr, #0
	QBEQ EXIT, data_addr, #0xFF

OUTPUT_LOOP:
	QBEQ RESET, count, #0
	
	MOV r30, 1<<15
	LBBO pru0r30_data0, data_addr, 0, 4*8
	MOV r30, 0<<15
	
	MOV r30, pru0r30_data0
	MOV r30, pru0r30_data1
	MOV r30, pru0r30_data2
	MOV r30, pru0r30_data3
	MOV r30, pru0r30_data4
        MOV r30, pru0r30_data5
        MOV r30, pru0r30_data6
        MOV r30, pru0r30_data7
	

	//MOV delay_iter, delay_count
	//QBEQ delay_done, delay_iter, 0

//delay_loop:
	//SUB delay_iter, delay_iter, 1
	//QBNE delay_loop, delay_iter, 0

delay_done:
	ADD data_addr, data_addr, 4*8
	SUB count, count, 8
	QBA OUTPUT_LOOP

EXIT:
#ifdef AM33XX
    // Send notification to Host for program completion
    MOV R31.b0, PRU0_ARM_INTERRUPT+16
#else
    MOV R31.b0, PRU0_ARM_INTERRUPT
#endif

    HALT
