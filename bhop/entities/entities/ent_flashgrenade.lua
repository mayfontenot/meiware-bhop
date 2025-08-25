ENT.Type = "anim"

function ENT:OnRemove()
end

function ENT:PhysicsUpdate()
end

function ENT:PhysicsCollide(data, phys)
	if data.Speed > 50 then
		self.Entity:EmitSound(Sound("Flashbang.Bounce"))
	end
end

if SERVER then
	function ENT:Initialize()
		self.Entity:SetModel("models/weapons/w_eq_flashbang.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveCollide(MOVECOLLIDE_FLY_BOUNCE)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(false)
		self.Entity:SetGravity(0.4)
		self.Entity:SetElasticity(0.45)
		self.Entity:SetFriction(0.2)
		self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)

		local phys = self.Entity:GetPhysicsObject()

		if phys:IsValid() then
			phys:Wake()
		end

		self.timer = CurTime() + 3
	end

	function ENT:Think()
		if self.timer <= CurTime() then
			self.Entity:Remove()
		end
	end
elseif CLIENT then
	local Endflash, Startflash, FLASHTIMER, EFFECT_DELAY = 0, 0, 5, 2

	function ENT:Initialize()
		if not IsValid(self) then return end

		local ply = self

		timer.Simple(2.98, function()
			ply:DynFlash()
		end)
	end

	function ENT:DynFlash()
		if not IsValid(self) then return end

		local dynamicflash = DynamicLight(self:EntIndex())

		if not dynamicflash then return end

		dynamicflash.Pos = self:GetPos()
		dynamicflash.r = 255
		dynamicflash.g = 255
		dynamicflash.b = 255
		dynamicflash.Brightness = 5
		dynamicflash.Size = 1000
		dynamicflash.Decay = 1000
		dynamicflash.DieTime = CurTime() + 0.5
	end

	function ENT:Think()
	end

	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:IsTranslucent()
		return true
	end

	usermessage.Hook("flashbang_flash", function(um)
		Startflash = um:ReadLong()
		Endflash = um:ReadLong()
		FLASHTIMER = Endflash - Startflash
	end)

	hook.Add("HUDPaint", "FlashEffect", function()
		if Endflash > CurTime() then
			local Alpha

			if(Endflash - CurTime() > FLASHTIMER) then
				Alpha = 150
			else
				Alpha = (1 - (CurTime() - (Endflash - FLASHTIMER)) / (Endflash - (Endflash - FLASHTIMER))) * 150
			end

			surface.SetDrawColor(255, 255, 255, math.Round(Alpha))
			surface.DrawRect(0, 0, surface.ScreenWidth(), surface.ScreenHeight())
		end
	end)

	hook.Add("RenderScreenspaceEffects", "StunEffect", function()
		if (Endflash > CurTime() and Endflash - EFFECT_DELAY - CurTime() <= FLASHTIMER) then
			DrawMotionBlur(0, (1 - (CurTime() - (Endflash - FLASHTIMER)) / (FLASHTIMER)) / ((FLASHTIMER + EFFECT_DELAY) / (FLASHTIMER * 4)), 0)
		elseif (Endflash > CurTime()) then
			DrawMotionBlur(0, 0.01, 0)
		end
	end)
end