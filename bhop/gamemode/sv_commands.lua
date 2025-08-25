util.AddNetworkString("replayStyle")

local function ChangeStyle(ply, newStyle)
	local steamID = ply:SteamID()

	if ReadFromCache(tempPlayerCache, STYLE_AUTO, steamID, "style") ~= newStyle then
		ply:Spawn()

		WriteToCache(tempPlayerCache, newStyle, steamID, "style")
		UpdateTempPlayerCache()
	end
end

local function UpdateZone(pos2, zone)
	local ent = zone == "start" and startZone or endZone

	pos2.z = pos2.z >= ent.pos1.z + 128 and pos2.z or ent.pos1.z + 128
	local pos = Vector((ent.pos1.x + pos2.x) / 2, (ent.pos1.y + pos2.y) / 2, (ent.pos1.z + pos2.z) / 2)

	local size = Vector(math.abs(pos2.x - ent.pos1.x), math.abs(pos2.y - ent.pos1.y), math.abs(pos2.z - ent.pos1.z))

	WriteToCache(mapCache, pos.x, zone .. "X")
	WriteToCache(mapCache, pos.y, zone .. "Y")
	WriteToCache(mapCache, pos.z, zone .. "Z")
	WriteToCache(mapCache, size.x, zone .. "L")
	WriteToCache(mapCache, size.y, zone .. "W")
	WriteToCache(mapCache, size.z, zone .. "H")

	ent:SetPos(pos)
	ent.size = size
	ent:Spawn()
end

net.Receive("replayStyle", function(len, ply)
	local bot = player.GetBots()[1]
	bot.replayMV = 1
	ChangeStyle(bot, net.ReadString())
end)

function GM:PlayerSay(sender, text, teamChat)
	if text[1] ~= "!" and text[1] ~= "/" then return text end

	text = string.sub(string.lower(text), 2)

	if text == "commands" or text == "help" then
		sender:SendLua('chat.AddText(Color(151, 211, 255), "[" .. ALT_NAME .. "] Press F1 for a list of commands.")')
	elseif text == "restart" or text == "r" then
		sender:Spawn()
		WriteToCache(tempPlayerCache, 0, sender:SteamID(), "timerStart")
		UpdateTempPlayerCache()
	elseif text == "usp" then
		sender:Give("weapon_usp")
	elseif text == "glock" then
		sender:Give("weapon_glock")
	elseif text == "remove" then
		sender:StripWeapons()
	elseif text == "auto" or text == "normal" or text == "n" then
		ChangeStyle(sender, STYLE_AUTO)
	elseif text == "manual" or text == "easy" or text == "legit" then
		ChangeStyle(sender, STYLE_MANUAL)
	elseif text == "sideways" or text == "sw" then
		ChangeStyle(sender, STYLE_SIDEWAYS)
	elseif text == "halfsideways" or text == "hsw" then
		ChangeStyle(sender, STYLE_HALF_SIDEWAYS)
	elseif text == "wonly" or text == "w" then
		ChangeStyle(sender, STYLE_W_ONLY)
	elseif text == "aonly" or text == "a" then
		ChangeStyle(sender, STYLE_A_ONLY)
	elseif text == "spectate" or text == "spec" then
		if sender:Team() == TEAM_SPECTATOR then
			sender:SetTeam(TEAM_PLAYER)
			sender:UnSpectate()
			sender:Spawn()
		else
			WriteToCache(tempPlayerCache, 0, sender:SteamID(), "timerStart")
			UpdateTempPlayerCache()

			sender:SetTeam(TEAM_SPECTATOR)
			sender:StripWeapons()
			sender:Spectate(OBS_MODE_IN_EYE)
		end
	elseif string.StartsWith(text, "tier ") then
		if ReadFromCache(playerCache, ROLE_USER, sender:SteamID(), "role") == ROLE_ADMIN then
			local tier = string.sub(text, 6)

			WriteToCache(mapCache, tier, "tier")
			UpdateMapCache()
		end
	elseif string.StartsWith(text, "map ") then
		if ReadFromCache(playerCache, ROLE_USER, sender:SteamID(), "role") == ROLE_ADMIN then
			ChangeLevel(string.sub(text, 5))
		end
	elseif text == "start pos1" then
		if ReadFromCache(playerCache, ROLE_USER, sender:SteamID(), "role") == ROLE_ADMIN then
			startZone.pos1 = sender:GetPos()
		end
	elseif text == "end pos1" then
		if ReadFromCache(playerCache, ROLE_USER, sender:SteamID(), "role") == ROLE_ADMIN then
			endZone.pos1 = sender:GetPos()
		end
	elseif text == "start pos2" then
		if ReadFromCache(playerCache, ROLE_USER, sender:SteamID(), "role") == ROLE_ADMIN then
			UpdateZone(sender:EyePos(), "start")
		end
	elseif text == "end pos2" then
		if ReadFromCache(playerCache, ROLE_USER, sender:SteamID(), "role") == ROLE_ADMIN then
			UpdateZone(sender:EyePos(), "end")
		end
	else
		sender:SendLua('chat.AddText(Color(151, 211, 255), "[" .. ALT_NAME .. "] Unknown command. Press F1 for a list of commands.")')
	end

	return ""
end