#ifndef ARM68_KICKSTART_H
#define ARM68_KICKSTART_H

#include <stddef.h>

size_t arm68_kickstart_size(void);
void arm68_install_builtin_kickstart(void);

#endif
