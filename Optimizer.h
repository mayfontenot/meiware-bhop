#pragma once
#include "SDK.h"
#include "Vector.h"

const float PI = 3.14159274101257324219f;

float NormalizeAngle(float ang)
{
    if (isnan(ang) || isinf(ang))
        ang = 0;

	while (ang > 180)
		ang -= 360;

	while (ang < -180)
		ang += 360;

	return ang;
}

void OptimizerThread()
{
    float oldYaw = 0;

	while (!GetAsyncKeyState(VK_END))
	{
        float yaw = *(float*)(engine + m_angAbsRotation + 0x4);

        if ((abs(yaw - oldYaw) < threshold && threshold > 0) || !GetAsyncKeyState(VK_XBUTTON2) || !cheats[CHEAT_OPTIMIZER])
        {
            oldYaw = yaw;

            continue;
        }

        int mouseX = (cursor.x - screen.right / 2) * CVAR_SENSITIVITY;
        float idealYaw = atan2(32.8f, (*(Vector*)(client + m_vecAbsVelocity)).Length2D()) * (180.f / PI); //30.f for cs:s

        if (*(int*)(client + forceLeft) == 1)
            yaw += idealYaw / smoothness + mouseX * CVAR_M_YAW;
        else if (*(int*)(client + forceRight) == 1)
            yaw -= idealYaw / smoothness - mouseX * CVAR_M_YAW;

        *(float*)(engine + m_angAbsRotation + 0x4) = oldYaw = NormalizeAngle(yaw);

		Sleep(1);
	}
}