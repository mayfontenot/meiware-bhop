#pragma once
#include <Windows.h>
#include <thread>

//modules
const unsigned long long client = (unsigned long long)GetModuleHandleA("client.dll");
const unsigned long long engine = (unsigned long long)GetModuleHandleA("engine.dll");

//addresses
const unsigned long long m_hLocalPlayer = 0x948770;
const unsigned long long forceJump = 0xA37870;
const unsigned long long forceLeft = 0xA358B8;
const unsigned long long forceRight = forceLeft + 0x10;
const unsigned long long m_angAbsRotation = 0x6571FC;
const unsigned long long m_vecAbsVelocity = 0x86C110;

//offsets
const unsigned long long m_fFlags = 0x440;

//constants
const int CON_FL_INDEX = 0, CON_B_INDEX = 1, CON_INDEX_COUNT = 2;
const int CON_FL_SMOOTHNESS = 0, CON_FL_THRESHOLD = 1, CON_FL_COUNT = 2;
const int CON_B_AUTOHOP = 0, CON_B_AUTOSTRAFE = 1, CON_B_OPTIMIZER = 2, CON_B_COUNT = 3;

//globals
float conFloats[CON_FL_COUNT] = {8.f, 0.022f};
bool conBools[CON_B_COUNT] = {false, true, true};