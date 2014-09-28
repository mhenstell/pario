/** \file
 * Test the pario firmware with a square wave
 */
#include <stdio.h>
#include "pario.h"

int main(void)
{
	pario_t * const p = pario_init(0);
	uint32_t * const bits = (uint32_t*) p->virt;

	p->cmd->delay_time = 0;

	printf("virt: %p\n", (const void*) p->virt);
	printf("phys: %p\n", (const void*) p->phys);
	printf("cmd:  %p\n", (const void*) p->cmd);
	printf("pru0r30 mask0:  %08x\n", p->cmd->pru0r30_mask);

	// generate a square wave on all ports
	for (int i = 0 ; i < 256 ; i += 2)
	{
		bits[i] = 0xFFFFFFFF & ~(1 << 15);
		bits[i+1] = 0x00000000;
	}

	p->cmd->num_bits = 256;

	while (1)
	{
		sleep(1);
		p->cmd->phys_addr = p->phys;

		//sleep(1);
		//p->cmd->phys_addr = 0;
	}

	return 0;
}
