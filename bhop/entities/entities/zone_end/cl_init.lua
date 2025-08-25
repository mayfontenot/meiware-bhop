include("shared.lua")

local color = Color(255, 0, 0)

function ENT:Draw()
	local min, max = self:GetCollisionBounds()

	self:SetRenderBounds(min, max)

	min = min + self:GetPos()
	max = max + self:GetPos()

	local b1, b2, b3, b4 = Vector(min.x, min.y, min.z), Vector(min.x, max.y, min.z), Vector(max.x, max.y, min.z), Vector(max.x, min.y, min.z) --bottom vertices
	local t1, t2, t3, t4 = Vector(min.x, min.y, max.z), Vector(min.x, max.y, max.z), Vector(max.x, max.y, max.z), Vector(max.x, min.y, max.z) --top vertices

	render.SetColorMaterial()

	render.StartBeam(5) --bottom, this makes a single beam, less memory usage
		render.AddBeam(b1, 1, 0, color)
		render.AddBeam(b2, 1, 0, color)
		render.AddBeam(b3, 1, 0, color)
		render.AddBeam(b4, 1, 0, color)
		render.AddBeam(b1, 1, 0, color)
	render.EndBeam()

	render.StartBeam(5) --top
		render.AddBeam(t1, 1, 0, color)
		render.AddBeam(t2, 1, 0, color)
		render.AddBeam(t3, 1, 0, color)
		render.AddBeam(t4, 1, 0, color)
		render.AddBeam(t1, 1, 0, color)
	render.EndBeam()

	render.DrawBeam(b1, t1, 1, 0, 0, color) --y
	render.DrawBeam(b2, t2, 1, 0, 0, color)
	render.DrawBeam(b3, t3, 1, 0, 0, color)
	render.DrawBeam(b4, t4, 1, 0, 0, color)
end