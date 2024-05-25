local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'CoreInit'

-- Initialize anything not dependent upon guild information
function XF:CoreInit()
	-- Get cache/configs asap	
	XF.Events = EventCollection:new(); XF.Events:Initialize()
	XF.Media = MediaCollection:new(); XF.Media:Initialize()

	-- External addon handling
	XF.Addons.ElvUI = XFElvUI:new()
	XF.Addons.RaiderIO = RaiderIOCollection:new()
	XF.Addons.WIM = XFWIM:new()
	XF.Handlers.AddonEvent = AddonEvent:new(); XF.Handlers.AddonEvent:Initialize()

	-- Log XFaction version
	XF.Versions = VersionCollection:new(); XF.Versions:Initialize()
	XF.Version = XF.Versions:GetCurrent()
	XF:Info(ObjectName, 'XFaction version [%s]', XF.Version:Key())
	
	-- Confederate
	XFO.Regions = XFC.RegionCollection:new(); XFO.Regions:Initialize()
	XFO.Confederate = XFC.Confederate:new()
	XFO.Factions = XFC.FactionCollection:new(); XFO.Factions:Initialize()
	XFO.Guilds = XFC.GuildCollection:new()
	XFO.Realms = XFC.RealmCollection:new(); XFO.Realms:Initialize()
	XF.Targets = TargetCollection:new()
	XFO.Teams = XFC.TeamCollection:new(); XFO.Teams:Initialize()
	XFO.Orders = XFC.OrderCollection:new(); XFO.Orders:Initialize()

	-- DataText
	XF.DataText.Guild = DTGuild:new()
	XF.DataText.Links = DTLinks:new()
	XF.DataText.Metrics = DTMetrics:new()

	-- Frames
	XF.Frames.Chat = ChatFrame:new()
	XF.Frames.System = SystemFrame:new()

	-- Declare handlers but not listening yet
	XF.Handlers.AchievementEvent = AchievementEvent:new(); XF.Handlers.AchievementEvent:Initialize()
	XF.Handlers.BNetEvent = BNetEvent:new(); XF.Handlers.BNetEvent:Initialize()
	XF.Handlers.ChatEvent = ChatEvent:new(); XF.Handlers.ChatEvent:Initialize()
	XF.Handlers.OrderEvent = XFC.OrderEvent:new(); XF.Handlers.OrderEvent:Initialize()
	XF.Handlers.PlayerEvent = PlayerEvent:new(); XF.Handlers.PlayerEvent:Initialize()
	XF.Handlers.SystemEvent = SystemEvent:new()
	XF.Handlers.TimerEvent = TimerEvent:new()

	-- Network
	XFO.Channels = XFC.ChannelCollection:new()
	XF.Friends = FriendCollection:new()
	XF.Links = LinkCollection:new()
	XF.Nodes = NodeCollection:new()
	XF.Mailbox.BNet = BNet:new()
	XF.Mailbox.Chat = Chat:new()
	
	-- Unit
	XFO.Races = XFC.RaceCollection:new(); XFO.Races:Initialize()
	XFO.Classes = XFC.ClassCollection:new(); XFO.Classes:Initialize()
	XFO.Specs = XFC.SpecCollection:new(); XFO.Specs:Initialize()
	XF.Continents = ContinentCollection:new(); XF.Continents:Initialize()
	XFO.Professions = XFC.ProfessionCollection:new(); XFO.Professions:Initialize()	
	XF.Zones = ZoneCollection:new(); XF.Zones:Initialize()	
	XFO.Dungeons = XFC.DungeonCollection:new(); XFO.Dungeons:Initialize()
	XF.Player.GUID = XFF.PlayerGetGUID('player')
	XF.Player.Faction = XFO.Factions:Get(XFF.PlayerGetFaction('player'))
	
	-- Wrappers	
	XF.Hooks = HookCollection:new(); XF.Hooks:Initialize()
	XF.Metrics = MetricCollection:new(); XF.Metrics:Initialize()	
	XF.Timers = TimerCollection:new(); XF.Timers:Initialize()
	XF.Handlers.TimerEvent:Initialize()

	-- These will execute "in-parallel" with remainder of setup as they are not time critical nor is anything dependent upon them
	try(function ()		
		XF.Player.InInstance = IsInInstance()
		
		XF.DataText.Guild:Initialize()
		XF.DataText.Links:Initialize()
		XF.DataText.Metrics:Initialize()
		--XF.DataText.Orders:Initialize()

		XF.Expansions = ExpansionCollection:new(); XF.Expansions:Initialize()
		XF.WoW = XF.Expansions:GetCurrent()
		XF:Info(ObjectName, 'WoW client version [%s:%s]', XF.WoW:Name(), XF.WoW:GetVersion():Key())
	end).
	catch(function (inErrorMessage)
		XF:Warn(ObjectName, inErrorMessage)
	end)
end

function XF:Stop()
	if(XF.Events) then XF.Events:Stop() end
	if(XF.Hooks) then XF.Hooks:Stop() end
	if(XF.Timers) then XF.Timers:Stop() end
end