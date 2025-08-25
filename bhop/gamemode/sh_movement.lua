function GM:SetupMove(ply, mv, cmd)
	local steamID = ply:SteamID()

	if SERVER and not ply:IsBot() then			--record replays
		local steamID = ply:SteamID()

		if ReadFromCache(tempPlayerCache, 0, steamID, "timerStart") > 0 then
			ply.replayMV = ply.replayMV and ply.replayMV + 1 or 1

			local pos, ang = mv:GetOrigin(), ply:EyeAngles()

			WriteToCache(replayCache, {["posX"] = pos.x, ["posY"] = pos.y, ["posZ"] = pos.z, ["angP"] = ang.p, ["angY"] = ang.y}, steamID, ply.replayMV)
		else
			WriteToCache(replayCache, {}, steamID)
			ply.replayMV = 0
		end
	end

	if SERVER and ply:IsBot() then						--play replay
		ply:SetMoveType(MOVETYPE_NONE)
		ply:SetRenderMode(RENDERMODE_NONE)
		ply:SetFOV(100)

		local mvTable = ReadFromCache(wrReplayCache, nil, ReadFromCache(tempPlayerCache, STYLE_AUTO, steamID, "style"))

		if mvTable then
			if not ply.replayMV then
				ply.replayMV = 1
			end

			if #GetSpectators(ply) > 0 and ply.replayMV == 1 then
				WriteToCache(tempPlayerCache, CurTime(), steamID, "timerStart")
				UpdateTempPlayerCache()
			end

			mv:SetOrigin(Vector(mvTable[ply.replayMV]["posX"], mvTable[ply.replayMV]["posY"], mvTable[ply.replayMV]["posZ"]))
			ply:SetEyeAngles(Angle(mvTable[ply.replayMV]["angP"], mvTable[ply.replayMV]["angY"], 0))

			if #GetSpectators(ply) > 0 then
				ply.replayMV = ply.replayMV + 1
			end

			if ply.replayMV > #mvTable or #GetSpectators(ply) == 0 then
				WriteToCache(tempPlayerCache, 0, steamID, "timerStart")
				UpdateTempPlayerCache()

				ply.replayMV = 1
			end
		end
	end

	if ply:GetMoveType() ~= MOVETYPE_WALK then return end

	local onGround = ply:OnGround()

	if ReadFromCache(tempPlayerCache, STYLE_AUTO, steamID, "style") ~= STYLE_MANUAL and onGround and cmd:KeyDown(IN_JUMP) and ply:WaterLevel() < 2 then	--autohop
		mv:SetOldButtons(mv:GetButtons() - IN_JUMP)
	end

	if onGround and ply:Crouching() and cmd:KeyDown(IN_JUMP) then	--crouch boost fix, credit to FiBzY
        ply:SetDuckSpeed(0)
        ply:SetUnDuckSpeed(0)
    else
        ply:SetDuckSpeed(0.4)
        ply:SetUnDuckSpeed(0.2)
    end

	if onGround then return end

	local style = ReadFromCache(tempPlayerCache, STYLE_AUTO, steamID, "style")

	if style == STYLE_SIDEWAYS or style == STYLE_W_ONLY then			--movement restrictions
		mv:SetSideSpeed(0)

		if style == STYLE_W_ONLY and mv:GetForwardSpeed() < 0 then
			mv:SetForwardSpeed(0)
		end
	elseif style == STYLE_A_ONLY then
		mv:SetForwardSpeed(0)

		if mv:GetSideSpeed() > 0 then
			mv:SetSideSpeed(0)
		end
	elseif style == STYLE_HALF_SIDEWAYS and (mv:GetForwardSpeed() == 0 or mv:GetSideSpeed() == 0) then
		mv:SetForwardSpeed(0)
		mv:SetSideSpeed(0)
	end
end

local AIR_ACCEL = 500

function GM:Move(ply, mv)
	if ply:OnGround() or ply:Team() == TEAM_SPECTATOR then return end

	local style = ReadFromCache(tempPlayerCache, STYLE_AUTO, ply:SteamID(), "style")
	local vel, ang = mv:GetVelocity(), mv:GetMoveAngles()
	local forward, right = ang:Forward(), ang:Right()
	local fSpeed, sSpeed = mv:GetForwardSpeed(), mv:GetSideSpeed()
	local maxSpeed = mv:GetMaxSpeed()

	if style == STYLE_AUTO then
		if mv:KeyDown(IN_MOVELEFT) then
			sSpeed = sSpeed - AIR_ACCEL
		elseif mv:KeyDown(IN_MOVERIGHT) then
			sSpeed = sSpeed + AIR_ACCEL
		end
	elseif style == STYLE_SIDE_WAYS then
		if mv:KeyDown(IN_FORWARD) then
			fSpeed = fSpeed + AIR_ACCEL
		elseif mv:KeyDown(IN_BACK) then
			fSpeed = fSpeed - AIR_ACCEL
		end
	end

	forward.z, right.z = 0, 0

	forward:Normalize()
	right:Normalize()

	local wishVel = forward * fSpeed + right * sSpeed
	wishVel.z = 0

	local wishSpeed = wishVel:Length()

	if wishSpeed > maxSpeed then
		wishVel = wishVel * (maxSpeed / wishSpeed)
		wishSpeed = maxSpeed
	end

	local wishSpeedDir = wishSpeed
	wishSpeedDir = math.Clamp(wishSpeedDir, 0, 32.8)

	local wishDir = wishVel:GetNormal()
	local currentDir = mv:GetVelocity():Dot(wishDir)
	local addSpeed = wishSpeedDir - currentDir

	if addSpeed <= 0 then return end

	local accelSpeed = AIR_ACCEL * FrameTime() * wishSpeed

	if accelSpeed > addSpeed then
		accelSpeed = addSpeed
	end

	vel = vel + wishDir * accelSpeed

	mv:SetVelocity(vel)

	return false
end