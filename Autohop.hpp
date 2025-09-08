#pragma once
#include "SDK.hpp"

void AutohopThread()
{
	while (!GetAsyncKeyState(VK_END))
	{
		if (!conBools[CON_B_AUTOHOP] || !GetAsyncKeyState(VK_SPACE)) //skip iteration if not active
			continue;

		unsigned long long hLocalPlayer = *(unsigned long long*)(client + m_hLocalPlayer);

		if (*(int*)(client + forceJump) == 5 && !(*(int*)(hLocalPlayer + m_fFlags) & (1 << 0)))
			*(int*)(client + forceJump) = 4; //4 releases, 5 presses
		else if (*(int*)(client + forceJump) == 4 && *(int*)(hLocalPlayer + m_fFlags) & (1 << 0))
			*(int*)(client + forceJump) = 5;

		Sleep(1);
	}
}