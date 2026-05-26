#include "spinlock.h"

extern "C" {

spinlock_t PPCStart;

void InitPPC(void)
{
    PPCStart.lock = 1;
}

void StartupPPC(void)
{
}

void PPCReportInterrupt(int interrupt)
{
    (void)interrupt;
}

}
