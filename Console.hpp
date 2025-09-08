#pragma once
#include "Globals.hpp"

FILE* fConsole;
int conIndex = 0, conSubIndex = 0;
bool updateOutput = true;

void ConsoleThread(HINSTANCE hinstDll)
{
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

			cout << (conIndex == CON_F_INDEX && conSubIndex == CON_F_SMOOTHNESS ? "> " : "") << "Smoothness (e.g. 8 or 16): " << conFloats[CON_F_SMOOTHNESS] << endl;
			cout << (conIndex == CON_F_INDEX && conSubIndex == CON_F_THRESHOLD ? "> " : "") << "Threshold (e.g. 0, or multiply sensitivity by m_yaw): " << conFloats[CON_F_THRESHOLD] << endl;
			cout << (conIndex == CON_B_INDEX && conSubIndex == CON_B_AUTOHOP ? "> " : "") << "Autohop: " << (conBools[CON_B_AUTOHOP] ? "ON" : "OFF") << endl;
			cout << (conIndex == CON_B_INDEX && conSubIndex == CON_B_AUTOSTRAFE ? "> " : "") << "Autostrafe: " << (conBools[CON_B_AUTOSTRAFE] ? "ON" : "OFF") << endl;
			cout << (conIndex == CON_B_INDEX && conSubIndex == CON_B_OPTIMIZER ? "> " : "") << "Optimizer: " << (conBools[CON_B_OPTIMIZER] ? "ON" : "OFF") << endl;

			updateOutput = false;
		}

		if (GetAsyncKeyState(VK_UP) & 1)
		{
			conSubIndex--;

			updateOutput = true;
		}

		if (GetAsyncKeyState(VK_DOWN) & 1)
		{
			conSubIndex++;

			updateOutput = true;
		}

		if (conSubIndex < 0)
		{
			conSubIndex = 0;
			conIndex--;

			updateOutput = true;
		}

		if (conSubIndex >= CON_F_COUNT && conIndex == CON_F_INDEX || conSubIndex >= CON_B_COUNT && conIndex == CON_B_INDEX)
		{
			conSubIndex = 0;
			conIndex++;

			updateOutput = true;
		}

		if (conIndex < 0)
			conIndex = 0;

		if (conIndex >= CON_INDEX_COUNT)
			conIndex = CON_INDEX_COUNT - 1;

		if (GetAsyncKeyState(VK_LEFT) & 1 || GetAsyncKeyState(VK_RIGHT) & 1)
		{
			if (conIndex == CON_F_INDEX)
			{
				cout << "\nEnter new value: ";
				cin >> conFloats[conSubIndex];
			}

			if (conIndex == CON_B_INDEX)
				conBools[conSubIndex] = !conBools[conSubIndex];

			updateOutput = true;
		}

		this_thread::sleep_for(chrono::milliseconds(5));
	}

	fclose(fConsole);
	FreeConsole();
	FreeLibraryAndExitThread(hinstDll, EXIT_SUCCESS);
}