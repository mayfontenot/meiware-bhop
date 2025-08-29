#pragma once
#include <Windows.h>

//modules
const unsigned long long client = (unsigned long long)GetModuleHandleA("client.dll");
const unsigned long long engine = (unsigned long long)GetModuleHandleA("engine.dll");

//addresses
const unsigned long long forceLeft = 0xA34908;
const unsigned long long forceRight = forceLeft + 0x10;
const unsigned long long m_angAbsRotation = 0x6571FC;
const unsigned long long m_vecAbsVelocity = 0x86B110;

//enums
const int CON_FL_INDEX = 0, CON_B_INDEX = 1, CON_INDEX_COUNT = 2;
const int CON_FL_SMOOTHNESS = 0, CON_FL_THRESHOLD = 1, CON_FL_COUNT = 2;
const int CON_B_AUTOSTRAFE = 0, CON_B_OPTIMIZER = 1, CON_B_COUNT = 2;

//globals
float conFloats[CON_FL_COUNT] = {40, 0.022};
bool conBools[CON_B_COUNT] = {true, true};

RECT screen;
POINT cursor;

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
