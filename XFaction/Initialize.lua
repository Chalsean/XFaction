local XFG, G = unpack(select(2, ...))
local ObjectName = 'Initialize'

function XFG:Init()
	XFG.RaidIO = RaidIOCollection:new(); XFG.RaidIO:Initialize()
	XFG.Events = EventCollection:new(); XFG.Events:Initialize()
	XFG.Handlers.AddonEvent = AddonEvent:new(); XFG.Handlers.AddonEvent:Initialize() 

	XFG.Confederate = Confederate:new()
	XFG.Expansions = ExpansionCollection:new(); XFG.Expansions:Initialize()
	XFG.WoW = XFG.Expansions:GetCurrent()
	XFG.Versions = VersionCollection:new(); XFG.Versions:Initialize()
	XFG.Version = XFG.Versions:GetCurrent()

	XFG:Info(ObjectName, 'WoW client version [%s:%s]', XFG.WoW:GetName(), XFG.WoW:GetVersion():GetKey())
	XFG:Info(ObjectName, 'XFaction version [%s]', XFG.Version:GetKey())

	XFG.Colors = ColorCollection:new(); XFG.Colors:Initialize()
	XFG.Metrics = MetricCollection:new(); XFG.Metrics:Initialize()

	XFG.Hooks = HookCollection:new(); XFG.Hooks:Initialize()
	XFG.Timers = TimerCollection:new(); XFG.Timers:Initialize()
	XFG.Frames.Chat = ChatFrame:new(); XFG.Frames.Chat:Initialize()
	XFG.Frames.System = SystemFrame:new(); XFG.Frames.System:Initialize()
	XFG.Media = MediaCollection:new(); XFG.Media:Initialize()

	XFG.Player.InInstance = IsInInstance()
	XFG.Factions = FactionCollection:new(); XFG.Factions:Initialize()
	XFG.Realms = RealmCollection:new(); XFG.Realms:Initialize()
	XFG.Continents = ContinentCollection:new(); XFG.Continents:Initialize()
	XFG.Zones = ZoneCollection:new(); XFG.Zones:Initialize()

	-- A significant portion of start up is delayed due to guild information not being available yet
	XFG.Handlers.TimerEvent = TimerEvent:new(); XFG.Handlers.TimerEvent:Initialize()

	-- Initialize DTs
	XFG.DataText.Guild = DTGuild:new(); XFG.DataText.Guild:Initialize()
	XFG.DataText.Links = DTLinks:new(); XFG.DataText.Links:Initialize()
	XFG.DataText.Token = DTToken:new(); XFG.DataText.Token:Initialize()
	XFG.DataText.Metrics = DTMetrics:new(); XFG.DataText.Metrics:Initialize()
end

do
	XFG.Init()
end