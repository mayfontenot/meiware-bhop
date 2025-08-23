#pragma once
#include <Windows.h>

const unsigned long long client = (unsigned long long)GetModuleHandleA("client.dll");
const unsigned long long engine = (unsigned long long)GetModuleHandleA("engine.dll");
const unsigned long long forceLeft = 0xA34908;
const unsigned long long forceRight = 0xA34918;
const unsigned long long m_angAbsRotation = 0x6571FC;
const unsigned long long m_vecAbsVelocity = 0x86B110;
const int CHEAT_AUTOSTRAFE = 0, CHEAT_OPTIMIZER = 1, CHEAT_COUNT = 2;

RECT screen;
POINT cursor;
bool cheats[CHEAT_COUNT] = {};
float CVAR_SENSITIVITY, CVAR_M_YAW, smoothness, threshold;

void SDKThread(HINSTANCE hinstDll)
{
	while (!GetAsyncKeyState(VK_END))
	{
		GetWindowRect(GetForegroundWindow(), &screen);
		GetCursorPos(&cursor);

		Sleep(1);
	}

	FreeLibraryAndExitThread(hinstDll, EXIT_SUCCESS);
}