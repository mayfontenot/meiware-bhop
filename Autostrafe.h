#pragma once
#include "SDK.h"

void AutostrafeThread()
{
	bool lastDir = false, runOnce = false;

	while (!GetAsyncKeyState(VK_END))
	{
		if (!cheats[CHEAT_AUTOSTRAFE] || !GetAsyncKeyState(VK_XBUTTON2))
		{
			if (runOnce)
			{
				*(int*)(client + forceLeft) = 0;
				*(int*)(client + forceRight) = 0;
				runOnce = lastDir = false;
			}

			continue;
		}

		if (cursor.x < screen.right / 2 || cursor.x == screen.right / 2 && !lastDir)
		{
			*(int*)(client + forceRight) = 0;
			*(int*)(client + forceLeft) = 1;
			lastDir = false;
		}
		else if (cursor.x > screen.right / 2 || cursor.x == screen.right / 2 && lastDir)
		{
			*(int*)(client + forceLeft) = 0;
			*(int*)(client + forceRight) = 1;
			lastDir = true;
		}

		runOnce = true;

		Sleep(1);
	}
}