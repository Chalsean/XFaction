local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'CoreInit'

-- Initialize anything not dependent upon guild information
function XF:CoreInit()
	-- Get cache/configs asap	
	XFO.Events = XFC.EventCollection:new(); XFO.Events:Initialize()
	XFO.Media = XFC.MediaCollection:new(); XFO.Media:Initialize()

	-- External addon handling
	XFO.ElvUI = XFC.ElvUI:new()
	XFO.RaiderIO = XFC.RaiderIOCollection:new()
	XFO.WIM = XFC.WIM:new()
	XFO.AddonEvent = XFC.AddonEvent:new(); XFO.AddonEvent:Initialize()

	-- Log XFaction version
	XFO.Versions = XFC.VersionCollection:new(); XFO.Versions:Initialize()
	XFO.Version = XFO.Versions:GetCurrent()
	XF:Info(ObjectName, 'XFaction version [%s]', XFO.Version:GetKey())
	
	-- Confederate
	XFO.Regions = XFC.RegionCollection:new(); XFO.Regions:Initialize()
	XFO.Confederate = XFC.Confederate:new()
	XFO.Factions = XFC.FactionCollection:new(); XFO.Factions:Initialize()
	XFO.Guilds = XFC.GuildCollection:new()
	XFO.Realms = XFC.RealmCollection:new(); XFO.Realms:Initialize()
	XFO.Targets = XFC.TargetCollection:new()
	XFO.Teams = XFC.TeamCollection:new(); XFO.Teams:Initialize()

	-- DataText
	XFO.DTGuild = XFC.DTGuild:new()
	XFO.DTLinks = XFC.DTLinks:new()
	XFO.DTMetrics = XFC.DTMetrics:new()

	-- Frames
	-- XF.Frames.Chat = ChatFrame:new()
	-- XF.Frames.System = SystemFrame:new()

	-- Declare handlers but not listening yet
	-- XF.Handlers.AchievementEvent = AchievementEvent:new(); XF.Handlers.AchievementEvent:Initialize()
	-- XF.Handlers.BNetEvent = BNetEvent:new(); XF.Handlers.BNetEvent:Initialize()
	-- XF.Handlers.ChannelEvent = ChannelEvent:new()
	-- XF.Handlers.ChatEvent = ChatEvent:new(); XF.Handlers.ChatEvent:Initialize()
	-- XF.Handlers.GuildEvent = GuildEvent:new(); XF.Handlers.GuildEvent:Initialize()
	-- XF.Handlers.PlayerEvent = PlayerEvent:new(); XF.Handlers.PlayerEvent:Initialize()
	-- XF.Handlers.SystemEvent = SystemEvent:new()
	-- XF.Handlers.TimerEvent = TimerEvent:new()

	-- Network
	XFO.Channels = XFC.ChannelCollection:new()
	XFO.Friends = XFC.FriendCollection:new()
	XFO.Links = XFC.LinkCollection:new()
	XFO.Nodes = XFC.NodeCollection:new()
	-- XF.Mailbox.BNet = BNet:new()
	-- XF.Mailbox.Chat = Chat:new()
	
	-- Unit
	XFO.Classes = XFC.ClassCollection:new(); XFO.Classes:Initialize()
	XFO.Professions = XFC.ProfessionCollection:new(); XFO.Professions:Initialize()
	XFO.Races = XFC.RaceCollection:new(); XFO.Races:Initialize()
	XFO.Specs = XFC.SpecCollection:new(); XFO.Specs:Initialize()
	XFO.Zones = XFC.ZoneCollection:new(); XFO.Zones:Initialize()	
	XFO.Dungeons = XFC.DungeonCollection:new(); XFO.Dungeons:Initialize()
	XF.Player.GUID = UnitGUID('player')
	XF.Player.Faction = XFO.Factions:GetByName(UnitFactionGroup('player'))
	
	-- Wrappers	
	XFO.Hooks = XFC.HookCollection:new(); XFO.Hooks:Initialize()
	XFO.Metrics = XFC.MetricCollection:new(); XFO.Metrics:Initialize()	
	XFO.Timers = XFC.TimerCollection:new(); XFO.Timers:Initialize()

	XF.Player.InInstance = IsInInstance()
	
	XFO.DTGuild:Initialize()
	XFO.DTLinks:Initialize()
	XFO.DTMetrics:Initialize()

	XFO.Expansions = XFC.ExpansionCollection:new(); XFO.Expansions:Initialize()
	XFO.WoW = XFO.Expansions:GetCurrent()
	XF:Info(ObjectName, 'WoW client version [%s:%s]', XFO.WoW:GetName(), XFO.WoW:GetVersion():GetKey())
end

function XF:Stop()
	if(XFO.Events) then XFO.Events:Stop() end
	if(XFO.Hooks) then XFO.Hooks:Stop() end
	if(XFO.Timers) then XFO.Timers:Stop() end
end