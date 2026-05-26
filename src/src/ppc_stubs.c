/*
 * Empty PPC entry points when ARM68_ENABLE_PPC is OFF.
 * start.c still references InitPPC/StartupPPC when ppc_enable is set at runtime;
 * these stubs keep the link valid without building the PPC translator.
 */

void InitPPC(void)
{
}

void StartupPPC(void)
{
}
