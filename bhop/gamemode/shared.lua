GM.Name = "Bunny Hop"
GM.Author = "Mei"
GM.Website = "meiware.net"
GM.TeamBased = false	--this is important, disables unwanted base gamemode features like the team menu and default spectator

DeriveGamemode("base")

ALT_NAME = "BHop Lite"
TEAM_SPECTATOR, TEAM_PLAYER = 1, 2
STYLE_AUTO, STYLE_MANUAL, STYLE_SIDEWAYS, STYLE_HALF_SIDEWAYS, STYLE_W_ONLY, STYLE_A_ONLY = "Auto", "Manual", "Sideways", "Half-sideways", "W-only", "A-only"
ROLE_USER, ROLE_MOD, ROLE_ADMIN = "User", "Mod", "Admin"

models = {
	"models/player/gasmask.mdl", 
	"models/player/riot.mdl", 
	"models/player/swat.mdl", 
	"models/player/urban.mdl", 
	"models/player/arctic.mdl", 
	"models/player/guerilla.mdl", 
	"models/player/leet.mdl", 
	"models/player/phoenix.mdl"
}

math.randomseed(os.time())	--we don't want random to be predicted

function FormatRecord(ns)			--high precision format for static time (chat notifications and menus)
	if type(ns) == 'boolean' then
		ns = 0
	end

	if ns > 3600 then
		return string.format("%d:%.2d:%.2d.%.03i", math.floor(ns / 3600), math.floor(ns / 60 % 60), math.floor(ns % 60), (ns - math.floor(ns)) * 1000)
	elseif ns > 60 then
		return string.format("%.1d:%.2d.%.03i", math.floor(ns / 60 % 60), math.floor(ns % 60), (ns - math.floor(ns)) * 1000)
	else
		return string.format("%.1d.%.03i", math.floor(ns % 60), (ns - math.floor(ns)) * 1000)
	end
end

function FormatTime(ns)				--short format for dynamic time elapsed, displaying precise time here isn't necessary, it updates faster than one can view
    if type(ns) == 'boolean' then
    	ns = 0
    end

	if ns > 3600 then
		return string.format("%d:%.2d:%.2d.%.1d", math.floor(ns / 3600), math.floor(ns / 60 % 60), math.floor(ns % 60), math.floor(ns * 10 % 10))
	elseif ns > 60 then 
		return string.format("%.1d:%.2d.%.1d", math.floor(ns / 60 % 60), math.floor(ns % 60), math.floor(ns * 10 % 10))
	else
		return string.format("%.1d.%.1d", math.floor(ns % 60), math.floor(ns * 10 % 10))
	end
end

function GetSpectators(ply)				--method for obtaining all spectators of the given player
	local spectators = {}

	for _, v in pairs(team.GetPlayers(TEAM_SPECTATOR)) do
		if v:GetObserverTarget() == ply then
			table.insert(spectators, v)
		end
	end

	return spectators
end

function GM:CreateTeams()
	team.SetUp(TEAM_SPECTATOR, "Spectator", Color(125, 125, 125))
	team.SetUp(TEAM_PLAYER, "Normal", Color(200, 200, 200))
end