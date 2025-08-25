--RNG fix, credit to FiBzY
--commented by fibzy for mei

--cache all used tables
local lastGroundEnt = {} --stores the last known ground ent the ply was standing on
local lastTickPredicted = {} --stores which tick we last predicted movement for this ply 
local lastBase = {} --basevel trigger push applied last tick
local tick = {} --local tick counter for each player incremented in SetupMove
local btns = {} --the current input buttons IN_JUMP IN_DUCK etc... for this tick
local obtns = {} --The input buttons from the previous tick 
local vels  = {} --predicted velocity stored for this tick
local lastTeleport = {} --used in telefix
local lastCollision = {} --stores the tick when we last detected a slope collision
local lastLand = {} --used in telefix 

NON_JUMP_VELOCITY = 140 --this is the maximum upward Z velocity a ply can have and still be considered as not jumping defined in source engine
MIN_STANDABLE_ZNRM = 0.7 --this is the min stand z vector nrm is it a slope? or not 

local unducked = Vector(16, 16, 62) --fix hulls to match gmod not css there is a 17 units differece 
local ducked = Vector(16, 16, 45)
local duckdelta = unducked.z - ducked.z

--[[
    ClipVelocity(vel, nrm)
    calculates the result of a velocity vector bouncing off a surface normal!
    this is used for: projecting a velocity vector along a surface and velocity gain when sliding into sloped geometry

    vel: vector current velocity
    nrm: vector normal of the surface we hit 
    new velocity vector that has been clipped along the slope... 
	 
    we take the dot product of velocity and the normal this gives us how much of the velocity is pointed into the slope
    then subtract that portion from the original velocity to get the part along the surface instead of into it
    resulting vector lets us slide along the surface without sticking or bouncing 

    usage: used in downhill slopefix to determine when and how to slide along an inclined surface without speed gain
]]
function ClipVelocity(vel, nrm)
	local backoff = vel:Dot(nrm)

	return Vector(vel.x - nrm.x * backoff, vel.y - nrm.y * backoff, vel.z - nrm.z * backoff)
end

--[[
    PreventCollision(ply, origin, collision, veltick, mv)
    - called when a slope collision would normally stick the ply or give inconsistent velocity on ramps 
    - repositions the player slightly to bypass the collision result that would’ve caused bad stops 

    - saying to pretend we landed at the point just before the slope collision
    - adds 0.1 to the Z coordinate vertical height... 

    - this is a workaround to prevent clipping into the ground
    - it causes float glitches where the player hovers slightly
    - this function is fix to unstick the player from slope hits
]]
function PreventCollision(ply, origin, collision, veltick, mv)
	local no = collision - veltick

	no.z = no.z + 0.1
	lastTickPredicted[ply] = 0

	mv:SetOrigin(no)
end

--[[
    CanJump(ply)

	- tells the rngfix if the ply can jump or not its pretty short 
	- obtns[ply] is the oldbuttons we talked about and why its needed 
	- no jump input — return false
]]
local function CanJump(ply)
    if not btns[ply] or not obtns[ply] then return true end

    if (btns[ply] and IN_JUMP) ~= 0 then
        obtns[ply] = obtns[ply] - IN_JUMP

        return true
    end

    return false
end

--[[
	Duck(ply, origin, mins, max)

    - ensures that traces especially slope traces match what the plys collision bounds will be after a duck or unduck action
    - this is CRITICAL for consistent slope detection and edge bug fix while crouching 

    - updated origin moved up/down if duck state is changing 

		- mins: Always reset to standard Vector(-16, -16, 0) 
		 - max:  Set to either ducked or unducked size depending on crouch state gmod is 17 units changed

    1. detects if the player is about to duck
        - if they arent crouching but press IN_DUCK we simulate the duck state by raising origin plus adjusting BBox
    
    2. detects if player is trying to unduck
        - subtracts duck delta from origin as if we uncrouched
        - then traces to see if we have space to do it 
        - if trace hits something we undo the change cant unduck yet

    - without updating origin/maxs here, your trace hulls would mismatch the plys actual size next tick leading to slopefix activating when it shouldnt
	or failing to detect ramps/edgebugs altogether!

    - used by DoPreTickChecks() before trace any predictive trace that needs accurate crouch shape
]]
function Duck(ply, origin, mins, max)
	local ducking = ply:Crouching()
	local nextducking = ducking --assume we stay crouched
	
	if not ducking and bit.band(btns[ply], IN_DUCK) ~= 0 then 
		origin.z = origin.z + duckdelta --shift origin up so bbox sits lower
		nextducking = true 
	elseif bit.band(btns[ply], IN_DUCK) == 0 and ducking then 
		origin.z = origin.z - duckdelta --try moving bbox up unduck

		local tr = util.TraceHull{			--check if we can safely unduck
			start = origin,
			endpos = origin,
			mins = Vector(-16.0, -16.0, 0.0),
			maxs = unducked,
			mask = MASK_PLAYERSOLID_BRUSHONLY,
			filter = ply
		}

		if tr.Hit then 
			origin.z = origin.z + duckdelta --no no blocked revert
		else 
			nextducking = false --successful! we can stand
		end 
	end 

	mins = Vector(-16.0, -16.0, 0.0)
	max = nextducking and ducked or unducked --set height box

	return origin, mins, max
end

--[[
    PredictVelocity(ply, mv, cmd)

    - simulates what the next velocity would be if the engine applied movement acceleration this tick
    - this makes rngfix consistent by precomputing air acceleration before slope stuff triggers
    - without this you get messed up when turning uphill especially in styles that dont use strafe keys normally

    - returns a predicted velocity that accounts for air acceleration 
    - rngfix slope detection uses this to simulate the next trace movement
    - if skiped uphill turns on slopes will randomly ignore your strafe acceleration causing stickiness or dropped speed inconsistently
]]
local AIR_ACCEL = 500

function PredictVelocity(ply, mv, cmd)
	local style = ReadFromCache(tempPlayerCache, STYLE_AUTO, ply:SteamID(), "style")
	local vel, ang = mv:GetVelocity(), mv:GetMoveAngles()
	local forward, right = ang:Forward(), ang:Right()
	local fSpeed, sSpeed = mv:GetForwardSpeed(), mv:GetSideSpeed()
	local maxSpeed = mv:GetMaxSpeed()

	if style == STYLE_NORMAL then
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

	if addSpeed <= 0 then 
		return vel
	end

	local accelSpeed = AIR_ACCEL * FrameTime() * wishSpeed

	if accelSpeed > addSpeed then
		accelSpeed = addSpeed
	end

	vel = vel + wishDir * accelSpeed

	return vel
end

--[[
    DoPreTickChecks(ply, mv, cmd)

    core of rngfix:
    - this is where all the slope prediction magic happens
    - it traces player movement before it's applied to detect slope collisions and adjusts their path to prevent velocity loss or random stops!

    - gmod physics doesnt predict movement correctly on angled ramps especially when moving uphill or turning on them.
    - this fix simulates the next movement tick and pre resolves slope impacts letting you cancel invalid collisions before they ruin the players momentum
	 
    1. validation: must be alive walking and not underwater 
    2. store ground state lastGroundEnt used for jump detection and slope state
    3. Cancel if trying to jump if jump input is active and were on ground, don't apply slope fix prevents fixing mid jumps which would cause air problems
    4. track current and previous tick states

    5. predict airmove use PredictVelocity() to simulate what velocity would be after movement keys are applied stores in vels[ply]
    6. account for basevel push triggers or velocity modifiers adds base velocity to prediction skip this and push triggers break
    7. crouch compensation Duck() to trace properly if crouched without this slope traces flicker when crouching or uncrouching

    8. trace ahead predict where the player will land next tick we trace a hull from current to predicted position with velocity applied

    9. slope detection
        if trace hits something and..
           were not on the ground
           the surface is walkable z normal above MIN_STANDABLE_ZNRM
           were not jumping z velocity low then we consider it a slope were about  to hit mid air

    10. downhill
        if hitting a down ramp we calculate if our new velocity would be faster by sliding it this indicates were landing on a downslope
        if true skip fix and allow downhill slide 

     11. if NOT downhill
         that means were about to be blocked by a slope sideways or uphill
         we run PreventCollision() to move the player to a better position skipping the shit trace result 

    result:
	player gets smooth slope transitions no random velocity deaths 
    uphill movement works correctly even at high strafe speeds!
]]

local vec = Vector(0, 0, 0)

function DoPreTickChecks(ply, mv, cmd)
	if not ply:Alive() or ply:GetMoveType() ~= MOVETYPE_WALK or ply:WaterLevel() ~= 0 then return false end

	lastGroundEnt[ply] = ply:GetGroundEntity()

	if not CanJump(ply) and lastGroundEnt[ply] ~= NULL then return false end

	btns[ply] = mv:GetButtons()
	obtns[ply] = mv:GetOldButtons()
	lastTickPredicted[ply] = tick[ply]

    local vel = PredictVelocity(ply, mv, cmd) --take account for airmove 
	local shouldDoDownhillFixInstead = false --bool for if the fix should apply downhill or uphill
	local base = (bit.band(ply:GetFlags(), FL_BASEVELOCITY) ~= 0) and ply:GetBaseVelocity() or vec --if you dont do this to basevel push triggers wont work with the fix

	vel:Add(base)

	lastBase[ply] = base;
	vels[ply] = vel;

	--trace that includes duck to insure constant slopes
	local origin = mv:GetOrigin()
	local vMins = ply:OBBMins()
	local vMaxs = ply:OBBMaxs()
	local vEndPos = origin * 1

	vEndPos, vMins, vMaxs = Duck(ply, vEndPos, vMins, vMaxs)
	vEndPos = vEndPos + (vel * FrameTime())

	local tr = util.TraceHull{
		start = origin,
		endpos = vEndPos,
		mins = vMins,
		maxs = vMaxs,
		mask = MASK_PLAYERSOLID_BRUSHONLY,
		filter = ply
	}
	local nrm = tr.HitNormal 
	
	if tr.Hit then --if the trace hits something then do the slope fix  
		lastCollision[ply] = tick[ply]

		if ply:IsOnGround() then return false end 

		local collision = tr.HitPos

		--disable fix based off these 2 checks since its not needed at theses times
		if nrm.z < MIN_STANDABLE_ZNRM then return end 
		if vel.z > NON_JUMP_VELOCITY then return end

		local collision = tr.HitPos
		local veltick = vel * FrameTime()

		if nrm.z < 1.0 and nrm.x * vel.x + nrm.y * vel.y < 0.0 then --slope fix
			local newvel = ClipVelocity(vel, nrm)

			if newvel.x * newvel.x + newvel.y * newvel.y > vel.x * vel.x + vel.y * vel.y then 
				shouldDoDownhillFixInstead = true;
			end 

			if not shouldDoDownhillFixInstead then 
				PreventCollision(ply, origin, collision, veltick, mv)

				return
			end
		end 

		local edgebug = true 

		if edgebug then --Edgebug fix
			local fraction_left = 1 - tr.Fraction 
			local tickEnd = Vector()

			if (nrm.z == 1) then 
				tickEnd.x = collision.x + veltick.x * fraction_left
				tickEnd.y = collision.y + veltick.y * fraction_left
				tickEnd.z = collision.z
			else 
				local velocity2 = ClipVelocity(vel, nrm)

				if (velocity2.z > NON_JUMP_VELOCITY) then 
					return 
				else 
					velocity2 = velocity2 * FrameTime() * fraction_left
					tickEnd = collision + velocity2
				end 
			end

			local tickEndBelow = Vector()
			tickEndBelow.x = tickEnd.x
			tickEndBelow.y = tickEnd.y
			tickEndBelow.z = tickEnd.z - 2; --land height

			local tr_edge = util.TraceHull{
				start = tickEnd,
				endpos = tickEndBelow,
				mins = vMins,
				maxs = vMaxs,
				mask = MASK_PLAYERSOLID,
				filter = ply
			}

			if tr_edge.Hit then
				if tr_edge.HitNormal.z >= MIN_STANDABLE_ZNRM then return end 
				if TracePlayerBBoxForGround(tickEnd, tickEndBelow, vMins, vMaxs, ply) then return end
			end 
			
			PreventCollision(ply, origin, collision, veltick, mv)
		end
	end 
end 

--[[
	DoInclineCollisonFixes(ply, mv, nrm)

   - does the downhill landings when the ply touches a slope and gets no speed due to incorrect velocity processing
   - runs in FinishMove, after gmod has applied movement 
   - this is only called if the player did land this tick 

   - ply must be on ground
   - must not be jumping we skip fixing mid jumps 
   - vels[ply] must exist comes from PredictVelocity
    - current tick must match last predicted tick so we dont apply to wrong frame

   - clamps velocity against slope using ClipVelocity 
   - if clipped velocity has more speed downhill effect then were landing into a downslope apply the fix

   final touch: 
   - we kill vertical velocity newVelocity.z = 0 so the player sticks to the slope instead of bouncing 

   - smooth downhill landings no double boost bug
   - no weird zero speed landings 
]]
function DoInclineCollisonFixes(ply, mv, nrm) 
	if not ply:IsOnGround() or not CanJump(ply) or not vels[ply] then return end

	if tick[ply] ~= lastTickPredicted[ply] then return end --only apply the fix if this passed

	local velocity = vels[ply]
	local newVelocity = ClipVelocity(velocity, nrm)
	local downhill = newVelocity.x * newVelocity.x + newVelocity.y * newVelocity.y  > velocity.x * velocity.x + velocity.y * velocity.y

	if not downhill then 
		return 
	end 

	newVelocity.z = 0

	mv:SetVelocity(newVelocity)
end 

hook.Add("SetupMove", "RNGFix", function(ply, mv, cmd) --apply
	if not tick[ply] then 
		tick[ply] = 0
	end 

	tick[ply] = tick[ply] + 1 --count the ticks 

	DoPreTickChecks(ply, mv, cmd) --apply the fixes 
end)

--[[
    PlayerPostThink(ply, mv)

     post move:
   - this runs at the very end of player movement
   - it detects when a player just landed on a slope and lets us apply DoInclineCollisonFixes() to clean up their velocity 

   - some slope landings arent predictable in SetupMove 
   - this gives us one last chance after gmod finishes the move to say this landing sucks fix it 

    1. check if player is alive walking and not underwater
    2. trace directly downward from players origin by full bounding box height if we hit a surface below the player we grab the normal 
    3. if its a slope normal.z < 1 but still walkable normal.z > MIN_STANDABLE_ZNRM then we call DoInclineCollisonFixes() to clean up downhill impact 

    - This is NOT a predictor like DoPreTickChecks. 
    - This runs after the fact and applies a fix only if gmod didnt land you cleanly usually downhill cases

    - only on actual slope contact on ground 
    - only on walkable slope range 0.7 < normal.z  < 1.0 
]]
hook.Add("FinishMove", "RNGFixPost", function(ply, mv)
	if not ply:Alive() or ply:GetMoveType() ~= MOVETYPE_WALK or ply:WaterLevel() ~= 0 then return end 

	local origin = mv:GetOrigin()
	local vMins = ply:OBBMins()
	local vMaxs = ply:OBBMaxs()

	local vEndPos = origin * 1 
	vEndPos.z = vEndPos.z - vMaxs.z --trace to bottom of bounding box 

	local tr = util.TraceHull{
		start = origin,
		endpos = vEndPos,
		mins = vMins,
		maxs = vMaxs,
		mask = MASK_PLAYERSOLID,
		filter = ply
	}

	if tr.Hit then 
		local nrm = tr.HitNormal

		if nrm.z > MIN_STANDABLE_ZNRM and nrm.z < 1 then --only fix if standing on an incline not flat ground 
			DoInclineCollisonFixes(ply, mv, nrm)
		end 
	end
end)

--[[
	TracePlayerBBoxForGround(origin, originBelow, mins, maxs, ply)

    - custom trace that increases the chance of detecting valid walkable ground below the player especially useful when only part of your hitbox is touching a 
	slope like corners or edge ramps...

    - gmod only traces your full hitbox when doing grounding checks but if you're standing 
	  half on a slope and half inair, the trace may miss walkable ground falsely marking you asnot grounded 

    - this function traces partial slice of your bounding box in 4 patterns mostly side biased AABBs-ish to catch those edge hits

    - each trace hits a subset of the plys collision box 
        X− / Y−  | quadrant
        X+ / Y+  | quadrant
        X− / Y+  | quadrant
        X+ / Y−  | quadrant 

    - if any trace detects ground normal.z ≥  MIN_STANDABLE_ZNRM we consider it a valid walkable slope and return that trace result

    - if it returns nil, no slope was hit by any corner youre likely falling
    - if it returns tr, youve got at least partial grounding under one side
]]
function TracePlayerBBoxForGround(origin, originBelow, mins, maxs, ply)
	local origMins, origMaxs = Vector(mins), Vector(maxs)
	local tr = nil

	mins = origMins --trace 1 | bottom left corner slice
	maxs = Vector(math.min(origMaxs.x, 0.0), math.min(origMaxs.y, 0.0), origMaxs.z)
	tr = util.TraceHull({
		start = origin,
		endpos = originBelow,
		mins = mins,
		maxs = maxs,
		mask = MASK_PLAYERSOLID_BRUSHONLY,
	})

	if tr.Hit and tr.HitNormal.z >= MIN_STANDABLE_ZNRM then
		return tr
	end

	mins = Vector(math.max(origMins.x, 0.0), math.max(origMins.y, 0.0), origMins.z) --ytrace 2 | top right corner slice
	maxs = origMaxs
	tr = util.TraceHull({
		start = origin,
		endpos = originBelow,
		mins = mins,
		maxs = maxs,
		mask = MASK_PLAYERSOLID_BRUSHONLY
	})

	if tr.Hit and tr.HitNormal.z >= MIN_STANDABLE_ZNRM then
		return tr
	end

	mins = Vector(origMins.x, math.max(origMins.y, 0.0), origMins.z) --trace 3 | left front edge
	maxs = Vector(math.min(origMaxs.x, 0.0), origMaxs.y, origMaxs.z)
	tr = util.TraceHull({
		start = origin,
		endpos = originBelow,
		mins = mins,
		maxs = maxs,
		mask = MASK_PLAYERSOLID_BRUSHONLY
	})

	if tr.Hit and tr.HitNormal.z >= MIN_STANDABLE_ZNRM then
		return tr
	end

	mins = Vector(math.max(origMins.x, 0.0), origMins.y, origMins.z) --trace 4 | right back edge
	maxs = Vector(origMaxs.x, math.min(origMaxs.y, 0.0), origMaxs.z)
	tr = util.TraceHull({
		start = origin,
		endpos = originBelow,
		mins = mins,
		maxs = maxs,
		mask = MASK_PLAYERSOLID_BRUSHONLY
	})

	if tr.Hit and tr.HitNormal.z >= MIN_STANDABLE_ZNRM then
		return tr
	end

	return nil --nothing hit assume we maybe are falling or no valid walkable slope
end