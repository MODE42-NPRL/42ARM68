#include "EmuLogo.h"

static uint8_t logo_data[480 * 360 / 8] = {[0 ... (480 * 360 / 8) - 1] = 0xFF};

struct EmuLogo EmuLogo = { 480, 360, logo_data };
