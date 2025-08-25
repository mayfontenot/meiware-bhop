--cache commonly used methods, these are not precached by the lua engine
surface = surface
surface.GetTextSize = surface.GetTextSize
surface.SetTextPos = surface.SetTextPos
surface.DrawText = surface.DrawText
surface.SetTextColor = surface.SetTextColor
surface.SetFont = surface.SetFont
surface.SetDrawColor = surface.SetDrawColor
surface.DrawRect = surface.DrawRect

net.Receive("tempPlayerCacheUpdate", function(len, ply)
	tempPlayerCache = net.ReadTable()
end)

net.Receive("playerCacheUpdate", function(len, ply)
	playerCache = net.ReadTable()
end)

net.Receive("personalRecordsCacheUpdate", function(len, ply)
	personalRecordsCache = net.ReadTable()
end)

net.Receive("worldRecordsCacheUpdate", function(len, ply)
	worldRecordsCache = net.ReadTable()
end)

net.Receive("mapCacheUpdate", function(len, ply)
	mapCache = net.ReadTable()
end)

net.Receive("mapsCacheUpdate", function(len, ply)
	mapsCache = net.ReadTable()
end)