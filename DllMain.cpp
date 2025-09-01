#include "SDK.hpp"
#include "Console.hpp"
#include "Autostrafe.hpp"
#include "Optimizer.hpp"

BOOL WINAPI DllMain(HINSTANCE hinstDll, DWORD fdwReason, LPVOID lpvReserved)
{
	if (fdwReason == DLL_PROCESS_ATTACH)
	{
		DisableThreadLibraryCalls(hinstDll);

		const HANDLE sdkHandle = CreateThread(nullptr, 0, (LPTHREAD_START_ROUTINE)SDKThread, hinstDll, 0, nullptr);
		const HANDLE consoleHandle = CreateThread(nullptr, 0, (LPTHREAD_START_ROUTINE)ConsoleThread, 0, 0, nullptr);
		const HANDLE autostrafeHandle = CreateThread(nullptr, 0, (LPTHREAD_START_ROUTINE)AutostrafeThread, 0, 0, nullptr);
		const HANDLE optimizerHandle = CreateThread(nullptr, 0, (LPTHREAD_START_ROUTINE)OptimizerThread, 0, 0, nullptr);

		if (sdkHandle)
			CloseHandle(sdkHandle);

		if (consoleHandle)
			CloseHandle(consoleHandle);

		if (autostrafeHandle)
			CloseHandle(autostrafeHandle);

		if (optimizerHandle)
			CloseHandle(optimizerHandle);
	}

	return TRUE;
}