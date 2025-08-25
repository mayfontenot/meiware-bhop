AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	local min, max = Vector(-self.size.x / 2, -self.size.y / 2, -self.size.z / 2), Vector(self.size.x / 2, self.size.y / 2, self.size.z / 2)

	self:SetSolid(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetCollisionBounds(min, max)
	self:SetNotSolid(true)
	self:SetTrigger(true) --necessary for Touch
	self:DrawShadow(false)
end

function ENT:StartTouch(ent)
	if IsValid(ent) and ent:IsPlayer() then
		if not ent:IsBot() then
			local steamID = ent:SteamID()
			local timerStart = ReadFromCache(tempPlayerCache, 0, steamID, "timerStart")

			if timerStart > 0 then
				local time = CurTime() - timerStart
				local name = ent:Name()
				local style = ReadFromCache(tempPlayerCache, STYLE_AUTO, steamID, "style")
				local worldRecord = ReadFromCache(worldRecordsCache, 0, style, "time")
				local personalRecord = ReadFromCache(personalRecordsCache, 0, steamID, style)

				if time < worldRecord or worldRecord == 0 then
					WriteToCache(worldRecordsCache, {["steamID"] = steamID, ["name"] = name, ["time"] = time}, style)
					WriteToCache(personalRecordsCache, name, steamID, "name")
					WriteToCache(personalRecordsCache, time, steamID, style)
					WriteToCache(wrReplayCache, ReadFromCache(replayCache, {}, steamID), style)
					UpdatePersonalRecordsCache()
					UpdateWorldRecordsCache()

					local diff = worldRecord > 0 and " (-" .. FormatRecord(worldRecord - time) .. ")" or ""

					PrintMessage(HUD_PRINTTALK, "[" .. ALT_NAME .. "] " .. name .. " set a new " .. style .. " World Record of " .. FormatRecord(time) .. diff)
				elseif time < personalRecord or personalRecord == 0 then
					WriteToCache(personalRecordsCache, name, steamID, "name")
					WriteToCache(personalRecordsCache, time, steamID, style)
					UpdatePersonalRecordsCache()

					local diff = personalRecord > 0 and " (-" .. FormatRecord(personalRecord - time) .. ")" or ""

					PrintMessage(HUD_PRINTTALK, "[" .. ALT_NAME .. "] " .. name .. " finished " .. style .. " in " .. FormatRecord(time) .. diff)
				else
					ent:SendLua('chat.AddText(Color(151, 211, 255), "[" .. ALT_NAME .. "] You did not beat your Personal Record (+" .. FormatRecord(' .. time - personalRecord .. ') .. ")")')
				end

				WriteToCache(tempPlayerCache, 0, ent:SteamID(), "timerStart")
				UpdateTempPlayerCache()
			end
		end
	end
end