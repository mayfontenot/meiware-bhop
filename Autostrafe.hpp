#pragma once
#include "Globals.hpp"

void AutostrafeThread()
{
	RECT screen;
	POINT cursor;
	bool runOnce = false;

	while (!GetAsyncKeyState(VK_END))
	{
		if (!conBools[CON_B_AUTOSTRAFE] || !GetAsyncKeyState(VK_XBUTTON2)) //if not active, then skip iteration and reset movement (only once)
		{
			if (runOnce)
				runOnce = *(bool*)(CLIENT + forceLeft) = *(bool*)(CLIENT + forceRight) = false;

			continue;
		}

		GetWindowRect(GetForegroundWindow(), &screen);
		GetCursorPos(&cursor);

		if (cursor.x < screen.right / 2)
			*(bool*)(CLIENT + forceLeft) = !(*(bool*)(CLIENT + forceRight) = false);
		else if (cursor.x > screen.right / 2)
			*(bool*)(CLIENT + forceRight) = !(*(bool*)(CLIENT + forceLeft) = false);

		runOnce = true;

		this_thread::sleep_for(chrono::milliseconds(1));
	}
}