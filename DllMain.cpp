#include <Windows.h>
#include "Console.hpp"
#include "Autohop.hpp"
#include "Autostrafe.hpp"
#include "Optimizer.hpp"

BOOL WINAPI DllMain(HINSTANCE hinstDll, DWORD fdwReason, LPVOID lpvReserved)
{
	if (fdwReason == DLL_PROCESS_ATTACH)
	{
		DisableThreadLibraryCalls(hinstDll);

		const HANDLE consoleHandle = CreateThread(nullptr, 0, (LPTHREAD_START_ROUTINE)ConsoleThread, hinstDll, 0, nullptr);
		const HANDLE autohopHandle = CreateThread(nullptr, 0, (LPTHREAD_START_ROUTINE)AutohopThread, 0, 0, nullptr);
		const HANDLE autostrafeHandle = CreateThread(nullptr, 0, (LPTHREAD_START_ROUTINE)AutostrafeThread, 0, 0, nullptr);
		const HANDLE optimizerHandle = CreateThread(nullptr, 0, (LPTHREAD_START_ROUTINE)OptimizerThread, 0, 0, nullptr);

		if (consoleHandle)
			CloseHandle(consoleHandle);

		if (autohopHandle)
			CloseHandle(autohopHandle);

		if (autostrafeHandle)
			CloseHandle(autostrafeHandle);

		if (optimizerHandle)
			CloseHandle(optimizerHandle);
	}

	return TRUE;
}