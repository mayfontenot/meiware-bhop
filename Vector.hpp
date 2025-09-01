#pragma once
#include <cmath>

class Vector
{
public:
	float x, y, z;

	Vector()
	{
		x = 0.0f;
		y = 0.0f;
		z = 0.0f;
	}

	Vector(float _x, float _y, float _z)
	{
		x = _x;
		y = _y;
		z = _z;
	}

	inline float& operator[](char i)
	{
		return ((float*)this)[i];
	}

	inline Vector& operator=(const Vector& v)
	{
		x = v.x;
		y = v.y;
		z = v.z;

		return *this;
	}

	inline Vector& operator+=(const Vector& v)
	{
		x += v.x;
		y += v.y;
		z += v.z;

		return *this;
	}

	inline Vector& operator-=(const Vector& v)
	{
		x -= v.x;
		y -= v.y;
		z -= v.z;

		return *this;
	}

	inline Vector& operator*=(const Vector& v)
	{
		x *= v.x;
		y *= v.y;
		z *= v.z;

		return *this;
	}

	inline Vector& operator*=(const float& f)
	{
		x *= f;
		y *= f;
		z *= f;

		return *this;
	}

	inline Vector& operator/=(const Vector& v)
	{
		x /= v.x;
		y /= v.y;
		z /= v.z;

		return *this;
	}

	inline Vector& operator/=(const float& f)
	{
		x /= f;
		y /= f;
		z /= f;

		return *this;
	}

	inline Vector operator+(const Vector& v) const
	{
		return Vector(x + v.x, y + v.y, z + v.z);
	}

	inline Vector operator-(const Vector& v) const
	{
		return Vector(x - v.x, y - v.y, z - v.z);
	}

	inline Vector operator*(const Vector& v) const
	{
		return Vector(x * v.x, y * v.y, z * v.z);
	}

	inline Vector operator*(const float& f) const
	{
		return Vector(x * f, y * f, z * f);
	}

	inline Vector operator/(const Vector& v) const
	{
		return Vector(x / v.x, y / v.y, z / v.z);
	}

	inline Vector operator/(const float& f) const
	{
		return Vector(x / f, y / f, z / f);
	}

	inline bool operator==(const Vector& v) const
	{
		return v.x == x && v.y == y && v.z == z;
	}

	inline bool operator!=(const Vector& e) const
	{
		return e.x != x || e.y != y || e.z != z;
	}

	void Normalize()
	{
		if (isnan(x) || isinf(x))
			x = 0;

		if (isnan(y) || isinf(y))
			y = 0;

		if (isnan(z) || isinf(z))
			z = 0;

		while (x > 180)
			x -= 360;

		while (x < -180)
			x += 360;

		while (y > 180)
			y -= 360;

		while (y < -180)
			y += 360;

		while (z > 180)
			z -= 360;

		while (z < -180)
			z += 360;
	}

	void Clamp()
	{
		if (x > 89)
			x = 89;
		else if (x < -89)
			x = -89;

		if (y > 180)
			y = 180;
		else if (y < -180)
			y = -180;

		z = 0;
	}

	float Length2D()
	{
		return sqrt(x * x + y * y);
	}
};