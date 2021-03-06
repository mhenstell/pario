/** \file
 * PRU beaglebone parallel output driver.
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdarg.h>
#include <string.h>
#include <inttypes.h>
#include <errno.h>
#include <unistd.h>
#include "pario.h"
#include "pru.h"

/** GPIO pins used by the pario firmware.
 *
 * The device tree should handle this configuration for us, but it
 * seems horribly broken and won't configure these pins as outputs.
 * So instead we have to repeat them here as well.
 *
 * This maps all of the pins, even if you don't have them
 * mapped in the gpio masks.
 *
 * \todo: Find a way to unify this with the defines in the .p file
 */

static const uint8_t pru0r30[] = {
	0, 1, 2, 3, 5, 7, 14, 15
};

#define ARRAY_COUNT(a) ((sizeof(a) / sizeof(*a)))


/*
 * Configure all of our output pins.
 * These must have also been set by the device tree overlay.
 * If they are not, some things will appear to work, but not
 * all the output pins will be correctly configured as outputs.
 */
static void
pario_gpio_init(
	pario_cmd_t * const cmd
)
{

	for (unsigned i = 0 ; i < ARRAY_COUNT(pru0r30) ; i++)
	{
		cmd->pru0r30_mask |= 1 << pru0r30[i];
	}
}


pario_t *
pario_init(
	int pru_num
)
{
	pario_t * const p = calloc(sizeof(*p), 1);
	if (!p)
		return NULL;

	pru_t * const pru = pru_init(pru_num);

	memcpy(p, &(pario_t) {
		.cmd	= pru->data_ram,
		.phys	= pru->ddr_addr,
		.virt	= pru->ddr,
	}, sizeof(*p));

	*p->cmd = (pario_cmd_t) {
		.phys_addr	= 0,
		.num_bits	= 0,
		.pru0r30_mask	= 0,
		.delay_time	= 0,
	};

	pario_gpio_init(p->cmd);
	pru_exec(pru, "./pario.bin");

	return p;
}
