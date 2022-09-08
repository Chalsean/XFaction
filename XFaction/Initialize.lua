local XFG, G = unpack(select(2, ...))
local ObjectName = 'Initialize'

-- Initialize anything not dependent upon guild information
function XFG:Init()
	-- Get cache/configs asap
	XFG.RaidIO = RaidIOCollection:new(); XFG.RaidIO:Initialize()
	XFG.Events = EventCollection:new(); XFG.Events:Initialize()
	XFG.Media = MediaCollection:new(); XFG.Media:Initialize()
	XFG.Handlers.AddonEvent = AddonEvent:new(); XFG.Handlers.AddonEvent:Initialize()

	-- Log XFaction version
	XFG.Versions = VersionCollection:new(); XFG.Versions:Initialize()
	XFG.Version = XFG.Versions:GetCurrent()
	XFG:Info(ObjectName, 'XFaction version [%s]', XFG.Version:GetKey())
	
	-- Confederate
	XFG.Confederate = Confederate:new()
	XFG.Factions = FactionCollection:new(); XFG.Factions:Initialize()
	XFG.Guilds = GuildCollection:new()
	XFG.Realms = RealmCollection:new(); XFG.Realms:Initialize()
	XFG.Targets = TargetCollection:new()
	XFG.Teams = TeamCollection:new()

	-- DataText
	XFG.DataText.Guild = DTGuild:new()
	XFG.DataText.Links = DTLinks:new()
	XFG.DataText.Metrics = DTMetrics:new()

	-- Frames
	XFG.Frames.Chat = ChatFrame:new(); XFG.Frames.Chat:Initialize()
	XFG.Frames.System = SystemFrame:new(); XFG.Frames.System:Initialize()

	-- Handlers
	XFG.Handlers.AchievementEvent = AchievementEvent:new()
	XFG.Handlers.BNetEvent = BNetEvent:new()
	XFG.Handlers.ChannelEvent = ChannelEvent:new()
	XFG.Handlers.ChatEvent = ChatEvent:new()
	XFG.Handlers.GuildEvent = GuildEvent:new()
	XFG.Handlers.PlayerEvent = PlayerEvent:new()
	XFG.Handlers.SystemEvent = SystemEvent:new(); 
	XFG.Handlers.TimerEvent = TimerEvent:new(); XFG.Handlers.TimerEvent:Initialize()

	-- Network
	XFG.Channels = ChannelCollection:new()
	XFG.Friends = FriendCollection:new()
	XFG.Links = LinkCollection:new()
	XFG.Nodes = NodeCollection:new()
	XFG.Mailbox.BNet = BNet:new()
	XFG.Mailbox.Chat = Chat:new()
	
	-- Unit
	XFG.Classes = ClassCollection:new()
	XFG.Continents = ContinentCollection:new(); XFG.Continents:Initialize()
	XFG.Professions = ProfessionCollection:new()
	XFG.Races = RaceCollection:new()
	XFG.Specs = SpecCollection:new()
	XFG.Zones = ZoneCollection:new(); XFG.Zones:Initialize()	
	XFG.Player.GUID = UnitGUID('player')
	XFG.Player.Faction = XFG.Factions:GetByName(UnitFactionGroup('player'))
	
	-- Wrappers	
	XFG.Hooks = HookCollection:new(); XFG.Hooks:Initialize()
	XFG.Metrics = MetricCollection:new(); XFG.Metrics:Initialize()	
	XFG.Timers = TimerCollection:new(); XFG.Timers:Initialize()
	XFG.Handlers.SystemEvent:Initialize()

	-- Start poller for guild information
	XFG.Timers:Get('Login'):Start()

	-- These will execute "in-parallel" with remainder of setup as they are not time critical nor is anything dependent upon them
	try(function ()		
		XFG.Player.InInstance = IsInInstance()
		
		XFG.DataText.Guild:Initialize()
		XFG.DataText.Links:Initialize()
		XFG.DataText.Metrics:Initialize()
		XFG.DataText.Token = DTToken:new(); XFG.DataText.Token:Initialize()

		XFG.Expansions = ExpansionCollection:new(); XFG.Expansions:Initialize()
		XFG.WoW = XFG.Expansions:GetCurrent()
		XFG:Info(ObjectName, 'WoW client version [%s:%s]', XFG.WoW:GetName(), XFG.WoW:GetVersion():GetKey())		
	end).
	catch(function (inErrorMessage)
		XFG:Warn(ObjectName, inErrorMessage)
	end)
end

function XFG:Stop()
	if(XFG.Events) then XFG.Events:Stop() end
	if(XFG.Hooks) then XFG.Hooks:Stop() end
	if(XFG.Timers) then XFG.Timers:Stop() end
end

do
	try(function ()
		XFG.Init()
	end).
	catch(function (inErrorMessage)
		XFG:Error(ObjectName, inErrorMessage)
		XFG:Stop()
	end)
end