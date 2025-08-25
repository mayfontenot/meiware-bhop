local MENU_WIDTH, MENU_HEIGHT = ScrH() / 2, ScrH() / 2

local panels = {}

local function AddPanel(name, class, parent)
	local panel = vgui.Create(class, parent)
	panel:SetSize(MENU_WIDTH - 88, MENU_HEIGHT - 48)
	panel:SetPos(80, 40)
	panel:SetVisible((#panels == 0 and true or false))

	function panel:Paint(w, h)
		surface.SetDrawColor(255, 255, 255)
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	function panel.VBar:Paint(w, h)
		surface.SetDrawColor(255, 255, 255)
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	function panel.VBar.btnUp:Paint(w, h)
		surface.SetDrawColor(255, 255, 255)
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	function panel.VBar.btnDown:Paint(w, h)
		surface.SetDrawColor(255, 255, 255)
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	function panel.VBar.btnGrip:Paint(w, h)
		surface.SetDrawColor(255, 255, 255)
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	local button = vgui.Create("DButton", parent)
	button:SetSize(64, 32)
	button:SetPos(8, 40 + #panels * 40)
	button:SetText(name)
	button:SetTextColor(Color(255, 255, 255))
	button.DoClick = function()
		for _, v in pairs(panels) do
			v:SetVisible(false)
		end

		panel:SetVisible(true)
	end

	function button:Paint(w, h)
		surface.SetDrawColor(255, 255, 255)
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	table.insert(panels, panel)

	return panel
end

function UpdatePanel(panel)
	panel:SetMultiSelect(false)

	for _, v in pairs(panel.Columns) do
		v.Header:SetTextColor(Color(255, 255, 255))

		function v.Header:Paint(w, h)
			surface.SetDrawColor(255, 255, 255)
			surface.DrawOutlinedRect(0, 0, w, h)
		end
	end

	for _, v in pairs(panel.Lines) do
		for _, k in pairs(v.Columns) do
			k:SetTextColor(Color(255, 255, 255))
		end

		function v:Paint(w, h)
		end
	end
end

local menuDrawn = false

concommand.Add("bhoplite_menu", function(ply, cmd, args)
	if menuDrawn then return end

	menuDrawn = true

	local frame = vgui.Create("DFrame")
	frame:SetSize(MENU_WIDTH, MENU_HEIGHT)
	frame:Center()
	frame:SetTitle(ALT_NAME .. " menu")
	frame:SetSizable(false)
	frame:SetDraggable(false)
	frame:SetVisible(true)
	frame:MakePopup()

	frame.lblTitle:SetColor(Color(255, 255, 255))
	frame.lblTitle:SetFont("HudDefault")

	function frame:Paint(w, h)
		surface.SetDrawColor(0, 0, 0, 100)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(255, 255, 255)
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	frame.btnMinim:SetVisible(false)
	frame.btnMaxim:SetVisible(false)
	frame.btnClose:SetVisible(false)

	local closeButton = vgui.Create("DButton", frame)
	closeButton:SetSize(24, 24)
	closeButton:SetPos(MENU_WIDTH - 24, 0)
	closeButton:SetText("")

	closeButton.DoClick = function()
		frame:Close()

		menuDrawn = false
	end

	function closeButton:Paint(w, h)
		surface.SetFont("CenterPrintText")

		local textWidth, textHeight = surface.GetTextSize("X")

		surface.SetDrawColor(255, 255, 255)
		surface.DrawOutlinedRect(0, 0, w, h)
		surface.SetTextPos(w / 2 - textWidth / 2, h / 2 - textHeight / 2)
		surface.DrawText("X")
	end

	panels = {}

	local commandsPanel = AddPanel("Commands", "DListView", frame)
	commandsPanel:AddColumn("Command")
	commandsPanel:AddColumn("Description")
	commandsPanel:AddLine("restart or r", "teleports you to the start zone")
	commandsPanel:AddLine("usp", "gives you a K&M .45 Tactical")
	commandsPanel:AddLine("glock", "gives you a 9×19mm Sidearm")
	commandsPanel:AddLine("remove", "strips you of all weapons")
	commandsPanel:AddLine("auto or normal or n", "changes your style to auto hop")
	commandsPanel:AddLine("manual or easy or legit", "changes your style to manual hop")
	commandsPanel:AddLine("sideways or sw", "changes your style to sideways")
	commandsPanel:AddLine("halfsideways or hsw", "changes your style to Half-Sideways")
	commandsPanel:AddLine("wonly or w", "changes your style to W-only")
	commandsPanel:AddLine("aonly or a", "changes your style to A-only")
	commandsPanel:AddLine("spectate or spec", "enter/exit the spectator team")
	commandsPanel:AddLine("tier <tier>", "Changes the map's tier. Admin only.")
	commandsPanel:AddLine("map <map>", "Save and changelevel. Admin only.")
	commandsPanel:AddLine("start pos1", "Create or modify start pos1 to your foot position. Admin only.")
	commandsPanel:AddLine("start pos2", "Create or modify start pos2 to your eye position. Admin only.")
	commandsPanel:AddLine("end pos1", "Create or modify end pos1 to your foot position. Admin only.")
	commandsPanel:AddLine("end pos2", "Create or modify end pos2 to your eye position. Admin only.")
	UpdatePanel(commandsPanel)

	local personalRecordsPanel = AddPanel("PR", "DListView", frame)
	personalRecordsPanel:AddColumn("SteamID")
	personalRecordsPanel:AddColumn("Name")
	personalRecordsPanel:AddColumn("Style")
	personalRecordsPanel:AddColumn("Time")
	for steamID, v in pairs(personalRecordsCache) do
		for style, time in pairs(v) do
			if style ~= "name" then
				personalRecordsPanel:AddLine(steamID, v["name"], style, FormatRecord(time) .. " s")
			end
		end
	end
	UpdatePanel(personalRecordsPanel)

	local worldRecordsIndex = 1
	local worldRecordsPanel = AddPanel("WR", "DScrollPanel", frame)
	for style, v in pairs(worldRecordsCache) do
		local label = vgui.Create("DLabel", worldRecordsPanel)
		label:SetWide(MENU_HEIGHT - 48)
		label:SetPos(8, 8 + 40 * (worldRecordsIndex - 1))
		label:SetTextColor(Color(255, 255, 255))
		label:SetText(v["steamID"] .. " " .. v["name"] .. " " .. style .. " " .. FormatRecord(v["time"]) .. " s")

		local buttonReplay = vgui.Create("DButton", worldRecordsPanel)
		buttonReplay:SetSize(64, 32)
		buttonReplay:SetPos(worldRecordsPanel:GetWide() - 144, 8 + 40 * (worldRecordsIndex - 1))
		buttonReplay:SetTextColor(Color(255, 255, 255))
		buttonReplay:SetText("Replay")
		buttonReplay.DoClick = function()
			net.Start("replayStyle")
			net.WriteString(style)
			net.SendToServer()
		end

		function buttonReplay:Paint(w, h)
			surface.SetDrawColor(255, 255, 255)
			surface.DrawOutlinedRect(0, 0, w, h)
		end

		worldRecordsIndex = worldRecordsIndex + 1
	end

	local mapsPanel = AddPanel("Maps", "DListView", frame)
	mapsPanel:AddColumn("Name")
	for _, v in pairs(mapsCache) do
		mapsPanel:AddLine(v)
	end
	UpdatePanel(mapsPanel)

	local playersPanel = AddPanel("Players", "DScrollPanel", frame)
	local players = player.GetHumans()
	table.RemoveByValue(players, LocalPlayer())
	for k, v in pairs(players) do
		local label = vgui.Create("DLabel", playersPanel)
		label:SetWide(MENU_HEIGHT - 48)
		label:SetPos(8, 8 + 40 * (k - 1))
		label:SetTextColor(Color(255, 255, 255))
		label:SetText(v:SteamID() .. " " .. v:Name())

		local buttonProfile = vgui.Create("DButton", playersPanel)
		buttonProfile:SetSize(64, 32)
		buttonProfile:SetPos(playersPanel:GetWide() - 144, 8 + 40 * (k - 1))
		buttonProfile:SetTextColor(Color(255, 255, 255))
		buttonProfile:SetText("Profile")
		buttonProfile.DoClick = function()
			v:ShowProfile()
		end

		function buttonProfile:Paint(w, h)
			surface.SetDrawColor(255, 255, 255)
			surface.DrawOutlinedRect(0, 0, w, h)
		end

		local buttonMute = vgui.Create("DButton", playersPanel)
		buttonMute:SetSize(64, 32)
		buttonMute:SetPos(playersPanel:GetWide() - 72, 8 + 40 * (k - 1))
		buttonMute:SetTextColor(Color(255, 255, 255))
		buttonMute:SetText((v:IsMuted() and "Unmute" or "Mute"))
		buttonMute.DoClick = function()
			v:SetMuted(not v:IsMuted())
			buttonMute:SetText((v:IsMuted() and "Unmute" or "Mute"))
		end

		function buttonMute:Paint(w, h)
			surface.SetDrawColor(255, 255, 255)
			surface.DrawOutlinedRect(0, 0, w, h)
		end
	end
end)