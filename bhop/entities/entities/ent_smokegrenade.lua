ENT.Type = "anim"

function ENT:OnRemove()
end

function ENT:PhysicsUpdate()
end

function ENT:PhysicsCollide(data, phys)
	if data.Speed > 50 then
		self.Entity:EmitSound(Sound("SmokeGrenade.Bounce"))
	end
end

if SERVER then
	function ENT:Initialize()
		self.Entity:SetModel("models/weapons/w_eq_smokegrenade.mdl")
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
			self:Remove()
		end
	end
elseif CLIENT then
	language.Add("ent_smokegrenade", "Grenade")

	function ENT:Initialize()
		self.Bang = false
	end

	function ENT:Draw()
		self.Entity:DrawModel()
	end

	function ENT:Think()
		if self.Entity:GetNWBool("Bang", false) and not self.Bang then
			self:Smoke()
			self.Bang = true
		end
	end

	local smokeparticles = {
		Model("particle/particle_smokegrenade"),
		Model("particle/particle_noisesphere")
	}

	function ENT:Smoke()
		local em = ParticleEmitter(self:GetPos())
		local r = 20

		for i = 1, 20 do
			local prpos = VectorRand() * r
			prpos.z = prpos.z + 32
			local p = em:Add(table.Random(smokeparticles), self:GetPos() + prpos)

			if p then
				local gray = math.random(75, 200)

				p:SetColor(gray, gray, gray)
				p:SetStartAlpha(255)
				p:SetEndAlpha(200)
				p:SetVelocity(VectorRand() * math.Rand(900, 1300))
				p:SetLifeTime(0)
				p:SetDieTime(math.Rand(50, 70))
				p:SetStartSize(math.random(140, 150))
				p:SetEndSize(math.random(1, 40))
				p:SetRoll(math.random(-180, 180))
				p:SetRollDelta(math.Rand(-0.1, 0.1))
				p:SetAirResistance(600)
				p:SetCollide(true)
				p:SetBounce(0.4)
				p:SetLighting(false)
			end
		end

		em:Finish()
	end

	function ENT:IsTranslucent()
		return true
	end
end