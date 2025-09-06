#pragma once
#include "SDK.hpp"

void AutostrafeThread()
{
	RECT screen;
	POINT cursor;
	bool lastDir = false, runOnce = false;

	while (!GetAsyncKeyState(VK_END))
	{
		if (!conBools[CON_B_AUTOSTRAFE] || !GetAsyncKeyState(VK_XBUTTON2)) //if not active, then skip iteration and reset movement (only once)
		{
			if (runOnce)
				runOnce = lastDir = *(bool*)(client + forceLeft) = *(bool*)(client + forceRight) = false;

			continue;
		}

		GetWindowRect(GetForegroundWindow(), &screen);
		GetCursorPos(&cursor);

		if (cursor.x < screen.right / 2)
			runOnce = !(lastDir = !(*(bool*)(client + forceLeft) = !(*(bool*)(client + forceRight) = false)));
		else if (cursor.x > screen.right / 2)
			runOnce = lastDir = *(bool*)(client + forceRight) = !(*(bool*)(client + forceLeft) = false);

		Sleep(1);
	}
}