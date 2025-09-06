#pragma once
#include "SDK.hpp"
#include "Vector.hpp"
const float PI = atan(1.f) * 4.f;

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
	float oldYaw = 0, oldDelta = 0, oldSmoothness = 0;

	while (!GetAsyncKeyState(VK_END))
	{
        float yaw = *(float*)(engine + m_angAbsRotation + 0x4); //base is pitch, + 0x4 is yaw because a float is 4 bytes
		float idealYaw = atan2(32.8f, (*(Vector*)(client + m_vecAbsVelocity)).Length2D()) * (180.f / PI); //30.f for cs:s, 32.8f for gmod
		float delta = abs(yaw - idealYaw);

		if (oldDelta == 0 || oldSmoothness != conFloats[CON_FL_SMOOTHNESS])
		{
			oldDelta = delta;
			oldSmoothness = conFloats[CON_FL_SMOOTHNESS] * 10.f;
		}

		if ((abs(yaw - oldYaw) < conFloats[CON_FL_THRESHOLD] && conFloats[CON_FL_THRESHOLD] > 0) || !GetAsyncKeyState(VK_XBUTTON2) || !conBools[CON_B_OPTIMIZER]) //skip loop iteration if not active
			continue;

		if (*(bool*)(client + forceLeft))
			yaw += delta / (delta / (oldDelta / oldSmoothness)); //we don't want to snap to the angle, so we divide the angle by the same ratio each time for a flat change
		else if (*(bool*)(client + forceRight))
			yaw -= delta / (delta / (oldDelta / oldSmoothness));

        oldYaw = *(float*)(engine + m_angAbsRotation + 0x4) = NormalizeAngle(yaw); //sets both yaw and old yaw towards ideal yaw

		Sleep(1);
	}
}
