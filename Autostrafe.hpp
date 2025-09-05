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
			{
				*(int*)(client + forceLeft) = *(int*)(client + forceRight) = 0;
				runOnce = lastDir = false;
			}

			continue;
		}

		GetWindowRect(GetForegroundWindow(), &screen);
		GetCursorPos(&cursor);

		if (cursor.x < screen.right / 2 || cursor.x == screen.right / 2 && !lastDir) //continue strafing towards a direction even if the mouse is not moving
		{
			*(int*)(client + forceLeft) = (*(int*)(client + forceRight))--;
			runOnce = !(lastDir = false); //sets runOnce to true and lastDir to false (left)
		}
		else if (cursor.x > screen.right / 2 || cursor.x == screen.right / 2 && lastDir)
		{
			*(int*)(client + forceRight) = (*(int*)(client + forceLeft))--;
			runOnce = lastDir = true;
		}

		Sleep(1);
	}
}
