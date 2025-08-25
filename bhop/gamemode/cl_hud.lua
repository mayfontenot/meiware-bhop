local hide = {
	["CHudDamageIndicator"] = true, 
	["CHudGeiger"] = true, 
	["CHudHealth"] = true, 
	["CHudBattery"] = true, 
	["CHudSecondaryAmmo"] = true, 
	["CHudSuitPower"] = true
}
local SCR_W, SCR_H = ScrW(), ScrH()
local hudWidth, hudHeight, hudTexts = 0, 0, {}

local function AddHudRow(text, rowNum)
	local textWidth, textHeight = surface.GetTextSize(text)

	surface.SetTextPos(SCR_W / 2 - textWidth / 2, SCR_H - textHeight - hudHeight + textHeight * rowNum)
	surface.DrawText(text)
end

function GM:HUDPaint()
	surface.SetFont("HudDefault")

	local ply = LocalPlayer()
	local observerTarget = ply:GetObserverTarget()
	ply = IsValid(observerTarget) and observerTarget or ply

	local steamID = ply:SteamID()
	local style = ReadFromCache(tempPlayerCache, STYLE_AUTO, steamID, "style")
	local timerStart = ReadFromCache(tempPlayerCache, 0, steamID, "timerStart")
	local worldRecord = ReadFromCache(worldRecordsCache, 0, style, "time")
	local personalRecord = ReadFromCache(personalRecordsCache, 0, steamID, style)
	local time = timerStart > 0 and (FormatTime(CurTime() - timerStart)) or "Stopped"

	if ply:IsBot() then
		personalRecord = worldRecord
	end

	worldRecord = worldRecord > 0 and ("WR: " .. FormatRecord(worldRecord) .. " (" .. ReadFromCache(worldRecordsCache, "N/A", style, "name") .. ")") or "WR: None"
	personalRecord = personalRecord > 0 and ("PR: " .. FormatRecord(personalRecord)) or "PR: None"

	hudTexts = {}

	if IsValid(observerTarget) then
		table.insert(hudTexts, observerTarget:Name())
	end

	table.insert(hudTexts, style)
	table.insert(hudTexts, time)
	table.insert(hudTexts, math.Round(ply:GetVelocity():Length2D()) .. " u/s")
	table.insert(hudTexts, personalRecord)
	table.insert(hudTexts, worldRecord)

	local textWidth, textHeight = surface.GetTextSize(worldRecord)
	hudWidth = textWidth + textHeight * 2
	hudHeight = textHeight * (#hudTexts + 2)

	draw.RoundedBox(16, SCR_W / 2 - hudWidth / 2, SCR_H - textHeight - hudHeight, hudWidth, hudHeight, Color(0, 0, 0, 100))

	surface.SetTextColor(255, 255, 255)

	for k, v in ipairs(hudTexts) do
		AddHudRow(v, k)
	end

	local spectators = GetSpectators(ply)

	if #spectators > 0 then
		local text = "Spectators (" .. #spectators.. "):"
		local textWidth, textHeight = surface.GetTextSize(text)
		surface.SetTextPos(SCR_W - textWidth - textHeight, SCR_H / 3)
		surface.DrawText(text)

		for k, v in pairs(spectators) do
			local text = v:Name()
			textWidth, textHeight = surface.GetTextSize(text)
			textHeight = textHeight * 1.5
			surface.SetTextPos(SCR_W - textWidth - textHeight, SCR_H / 3 + k * textHeight)
			surface.DrawText(text)
		end
	end
end

local SCOREBOARD_WIDTH, SCOREBOARD_HEIGHT = SCR_W / 2, SCR_H / 1.75

local function AddScoreboardRow(rowNum, numColumns, ...)
	local elements = {...}

	local textHeight = select(2, surface.GetTextSize(elements[1]))
	textHeight = textHeight * 1.5

	for k, v in ipairs(elements) do
		surface.SetTextPos(SCR_W / 2 - SCOREBOARD_WIDTH / 2 + textHeight + (SCOREBOARD_WIDTH / numColumns * (k - 1)), SCR_H / 2 - SCOREBOARD_HEIGHT / 2 + textHeight * rowNum)
		surface.DrawText(v)
	end
end

local drawScoreboard = false

function GM:HUDDrawScoreBoard()
	if not drawScoreboard then return end

	draw.RoundedBox(16, SCR_W / 2 - SCOREBOARD_WIDTH / 2, SCR_H / 2 - SCOREBOARD_HEIGHT / 2, SCOREBOARD_WIDTH, SCOREBOARD_HEIGHT, Color(0, 0, 0, 100))

	surface.SetFont("HudDefault")
	surface.SetTextColor(255, 255, 255)

	AddScoreboardRow(1, 1, GetHostName())
	AddScoreboardRow(2, 1, "Tier " .. ReadFromCache(mapCache, 1, "tier") .. " " .. game.GetMap())
	AddScoreboardRow(3, 5, "Name", "Style", "Timer", "Personal Record", "Ping")

	for k, v in ipairs(team.GetPlayers(TEAM_PLAYER)) do
		local steamID = v:SteamID()
		local style = ReadFromCache(tempPlayerCache, STYLE_AUTO, steamID, "style")
		local timerStart = ReadFromCache(tempPlayerCache, 0, steamID, "timerStart")

		local personalRecord = ReadFromCache(personalRecordsCache, 0, steamID, style)
		personalRecord = personalRecord > 0 and FormatRecord(personalRecord) or "None"

		local time = timerStart > 0 and FormatTime(CurTime() - timerStart) or "Stopped"

		AddScoreboardRow(3 + k, 5, v:Name(), style, time, personalRecord, v:Ping())
	end

	local spectators = ""

	for k, v in ipairs(team.GetPlayers(TEAM_SPECTATOR)) do
		spectators = spectators .. (spectators ~= "" and ", " or "") .. v:Name()
	end

	if #team.GetPlayers(TEAM_SPECTATOR) > 0 then
		AddScoreboardRow(19, 1, "Spectators: " .. spectators)
	end
end

function GM:ScoreboardShow()
	drawScoreboard = true
end

function GM:ScoreboardHide()
	drawScoreboard = false
end

function GM:HUDShouldDraw(name)
	return not hide[name]
end

function GM:HUDItemPickedUp(itemName)
end