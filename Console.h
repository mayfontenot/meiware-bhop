#pragma once
#include "SDK.h"
#include <iostream>

using namespace std;

void ConsoleThread()
{
	FILE* fConsole;
	AllocConsole();
	SetConsoleTitleA("Meiware Bunny Hop v2025.08.08 (x64)");
	freopen_s(&fConsole, "CONOUT$", "w", stdout);
	freopen_s(&fConsole, "CONIN$", "r", stdin);

	int cheatIndex = 0;
	bool updateOutput = true;

	cout << "CVar sensitivity: ";
	cin >> CVAR_SENSITIVITY;

	cout << "CVar m_yaw (0.022): ";
	cin >> CVAR_M_YAW;

	cout << "Smoothness (6): ";
	cin >> smoothness;

	cout << "Threshold (0.088): ";
	cin >> threshold;

	while (!GetAsyncKeyState(VK_END))
	{
		if (updateOutput)
		{
			system("cls");

			cout << "© 2021 Meiware.net\nEND to uninject, UP/DOWN to navigate, LEFT/RIGHT to toggle\nHold MOUSE5 to activate\n" << endl;

			cout << (cheatIndex == CHEAT_AUTOSTRAFE ? "> " : "") << "Autostrafe: " << (cheats[CHEAT_AUTOSTRAFE] ? "ON" : "OFF") << endl;
			cout << (cheatIndex == CHEAT_OPTIMIZER ? "> " : "") << "Optimizer: " << (cheats[CHEAT_OPTIMIZER] ? "ON" : "OFF") << endl;

			updateOutput = false;
		}

		if (GetAsyncKeyState(VK_UP) & 1)
		{
			cheatIndex--;

			updateOutput = true;
		}

		if (GetAsyncKeyState(VK_DOWN) & 1)
		{
			cheatIndex++;

			updateOutput = true;
		}

		if (cheatIndex < 0)
			cheatIndex = CHEAT_COUNT - 1;

		if (cheatIndex >= CHEAT_COUNT)
			cheatIndex = 0;

		if (GetAsyncKeyState(VK_LEFT) & 1 || GetAsyncKeyState(VK_RIGHT) & 1)
		{
			cheats[cheatIndex] = !cheats[cheatIndex];

			updateOutput = true;
		}

		Sleep(1);
	}

	FreeConsole();
}