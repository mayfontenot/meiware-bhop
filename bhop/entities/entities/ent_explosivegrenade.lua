ENT.Type = "anim"

function ENT:OnRemove()
end

function ENT:PhysicsUpdate()
end

function ENT:PhysicsCollide(data, phys)
	if data.Speed > 50 then
		self.Entity:EmitSound(Sound("HEGrenade.Bounce"))
	end
end

if SERVER then
	function ENT:Initialize()
		self.Entity:SetModel("models/weapons/w_eq_fraggrenade.mdl")
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
		if self.timer < CurTime() then
			local damage = 0
			local pos = self.Entity:GetPos()
			local owner = self.GrenadeOwner
			local ref = self

			self.Entity:Remove()
			
			for _, ent in pairs(ents.FindInSphere(pos, 128)) do
				if ent:GetClass() == "func_button" then
					local tr = util.TraceLine({start = pos, endpos = ent:GetPos(), filter = {ent}, mask = MASK_SOLID})

					if tr.Fraction == 1 then
						ent:TakeDamage(dmg, owner, nil)
					end
				end
			end

			local exp = ents.Create("env_explosion")
			exp:SetKeyValue("spawnflags", 128)
			exp:SetPos(pos)
			exp:Spawn()
			exp:Fire("explode", "", 0)

			local exp = ents.Create("env_physexplosion")
			exp:SetKeyValue("magnitude", 150)
			exp:SetPos(pos)
			exp:Spawn()
			exp:Fire("explode", "", 0)
		end
	end
elseif CLIENT then
	function ENT:Draw()
		self.Entity:DrawModel()
	end

	function ENT:IsTranslucent()
		return true
	end
end