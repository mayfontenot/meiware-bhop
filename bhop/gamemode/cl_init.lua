include("shared.lua")
include("sh_cache.lua")
include("sh_movement.lua")
include("sh_rngfix.lua")
include("cl_cache.lua")
include("cl_hud.lua")
include("cl_menu.lua")

function GM:InitPostEntity()		--hulls fix
	local ply = LocalPlayer()

	ply:SetHull(Vector(-16, -16, 0), Vector(16, 16, 62))
	ply:SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, 45))

	ply:SetViewOffset(Vector(0, 0, 64))
	ply:SetViewOffsetDucked(Vector(0, 0, 47))
end

function GM:CalcView(ply, origin, angles, fov, znear, zfar)     --view punch fix
    angles.r = 0

    return {origin = origin, angles = angles, fov = fov, znear = znear, sfar = zfar}
end

hook.Remove("PreDrawHalos", "AddPhysgunHalos")	--remove hooks that cause lag
hook.Remove("PlayerTick", "TickWidgets")
hook.Remove("PreDrawHalos", "PropertiesHover")
hook.Remove("PostDrawEffects", "RenderHalos")