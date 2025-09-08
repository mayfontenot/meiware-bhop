#pragma once
#include "Globals.hpp"

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

float oldYaw = 0;

void OptimizerThread()
{
	while (!GetAsyncKeyState(VK_END))
	{
        float yaw = *(float*)(ENGINE + m_angAbsRotation + 0x4); //base is pitch, + 0x4 is yaw because a float is 4 bytes
		float idealYaw = atan2(32.8f, (*(Vector*)(CLIENT + m_vecAbsVelocity)).Length2D()) * (180.f / PI); //30.f for cs:s, 32.8f for gmod
		float delta = abs(yaw - idealYaw);

		if (delta < conFloats[CON_F_THRESHOLD] && conFloats[CON_F_THRESHOLD] > 0) || !GetAsyncKeyState(VK_XBUTTON2) || !conBools[CON_B_OPTIMIZER]) //skip loop iteration if not active
			continue;

		if (*(bool*)(CLIENT + forceLeft))
			yaw += delta / conFloats[CON_F_SMOOTHNESS]; //we don't want to snap to the angle, so we divide the angl by how smooth we want it to be
		else if (*(bool*)(CLIENT + forceRight))
			yaw -= delta / conFloats[CON_F_SMOOTHNESS];

        oldYaw = *(float*)(ENGINE + m_angAbsRotation + 0x4) = NormalizeAngle(yaw); //sets both yaw and old yaw towards ideal yaw

		this_thread::sleep_for(chrono::milliseconds(1));
	}

}
