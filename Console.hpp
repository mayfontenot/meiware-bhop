#pragma once
#include "Globals.hpp"

void ConsoleThread(HINSTANCE hinstDll)
{
	FILE* fConsole;
	int conIndex = 0;
	bool updateOutput = true;

	AllocConsole();
	SetConsoleTitleA("Meiware Bunny Hop v2025.09.01 (x64)");
	freopen_s(&fConsole, "CONOUT$", "w", stdout);
	freopen_s(&fConsole, "CONIN$", "r", stdin);

	while (!GetAsyncKeyState(VK_END))
	{
		if (updateOutput)
		{
			system("cls");

			cout << "© 2021 Meiware.net\nEND to uninject, UP/DOWN to navigate, LEFT/RIGHT to change\nHold MOUSE5 to activate\n" << endl;

			cout << (conIndex == CON_B_AUTOHOP ? "> " : "") << "Autohop: " << (conBools[CON_B_AUTOHOP] ? "ON" : "OFF") << endl;
			cout << (conIndex == CON_B_AUTOSTRAFE ? "> " : "") << "Autostrafe: " << (conBools[CON_B_AUTOSTRAFE] ? "ON" : "OFF") << endl;
			cout << (conIndex == CON_B_OPTIMIZER ? "> " : "") << "Optimizer: " << (conBools[CON_B_OPTIMIZER] ? "ON" : "OFF") << endl;

			updateOutput = false;
		}

		if (GetAsyncKeyState(VK_UP) & 1)
		{
			conIndex--;
			updateOutput = true;
		}

		if (GetAsyncKeyState(VK_DOWN) & 1)
		{
			conIndex++;
			updateOutput = true;
		}

		if (conIndex < 0)
		{
			conIndex = CON_B_COUNT;
			updateOutput = true;
		}

		if (conIndex >= CON_B_COUNT)
		{
			conIndex = 0;
			updateOutput = true;
		}

		if (GetAsyncKeyState(VK_LEFT) & 1 || GetAsyncKeyState(VK_RIGHT) & 1)
		{
			conBools[conIndex] = !conBools[conIndex];
			updateOutput = true;
		}

		this_thread::sleep_for(chrono::milliseconds(10));
	}

	fclose(fConsole);
	FreeConsole();
	FreeLibraryAndExitThread(hinstDll, EXIT_SUCCESS);
}