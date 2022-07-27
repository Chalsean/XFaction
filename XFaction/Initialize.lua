local XFG, G = unpack(select(2, ...))
local LogCategory = 'Initialize'

function XFG:Init()
	XFG.Expansions = ExpansionCollection:new(); XFG.Expansions:Initialize()
	XFG.WoW = XFG.Expansions:GetCurrent()
	XFG.Versions = VersionCollection:new(); XFG.Versions:Initialize()
	XFG.Version = XFG.Versions:GetCurrent()
	XFG.Metrics = MetricCollection:new(); XFG.Metrics:Initialize()
	XFG.Factions = FactionCollection:new(); XFG.Factions:Initialize()
	XFG.Realms = RealmCollection:new(); XFG.Realms:Initialize()
	XFG.Guilds = GuildCollection:new(); XFG.Guilds:Initialize()
	XFG.Teams = TeamCollection:new()

	XFG.Events = EventCollection:new(); XFG.Events:Initialize()
	XFG.Timers = TimerCollection:new(); XFG.Timers:Initialize()

	-- A significant portion of start up is delayed due to guild information not being available yet
	XFG.Handlers.TimerEvent = TimerEvent:new(); XFG.Handlers.TimerEvent:Initialize()	

	XFG.Frames.Chat = ChatFrame:new(); XFG.Frames.Chat:Initialize()
	XFG.Frames.System = SystemFrame:new(); XFG.Frames.System:Initialize()

	-- Initialize DTs
	XFG.DataText.Guild = DTGuild:new(); XFG.DataText.Guild:Initialize()
	XFG.DataText.Links = DTLinks:new(); XFG.DataText.Links:Initialize()
	XFG.DataText.Soulbind = DTSoulbind:new(); XFG.DataText.Soulbind:Initialize()
	XFG.DataText.Token = DTToken:new(); XFG.DataText.Token:Initialize()
	XFG.DataText.Metrics = DTMetrics:new(); XFG.DataText.Metrics:Initialize()
end

do
	XFG.Init()
end