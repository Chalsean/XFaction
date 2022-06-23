local XFG, G = unpack(select(2, ...))
local LogCategory = 'Initialize'

function XFG:Init()
	XFG.Player.GUID = UnitGUID('player')	
	XFG.Factions = FactionCollection:new(); XFG.Factions:Initialize()
	XFG.Player.Faction = XFG.Factions:GetFactionByName(UnitFactionGroup('player'))
	XFG.Realms = RealmCollection:new(); XFG.Realms:Initialize()
	XFG.Guilds = GuildCollection:new(); XFG.Guilds:Initialize()
	XFG.Teams = TeamCollection:new(); XFG.Teams:Initialize()

	-- A significant portion of start up is delayed due to guild information not being available yet
	XFG.Handlers.TimerEvent = TimerEvent:new(); XFG.Handlers.TimerEvent:Initialize()

	XFG.Frames.Chat = ChatFrame:new(); XFG.Frames.Chat:Initialize()
	XFG.Frames.System = SystemFrame:new(); XFG.Frames.System:Initialize()
	--XFG.Frames.XFaction = XFactionFrame:new(); XFG.Frames.XFaction:Initialize()

	-- Initialize DTs
	XFG.DataText.Guild = DTGuild:new(); XFG.DataText.Guild:Initialize()
	XFG.DataText.Links = DTLinks:new(); XFG.DataText.Links:Initialize()
	XFG.DataText.Soulbind = DTSoulbind:new(); XFG.DataText.Soulbind:Initialize()
	XFG.DataText.Token = DTToken:new(); XFG.DataText.Token:Initialize()
end

do
	XFG.Init()
end