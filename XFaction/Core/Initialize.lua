local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'CoreInit'

-- Initialize anything not dependent upon guild information
function XF:CoreInit()
	-- Get cache/configs asap	
	XF.Events = EventCollection:new(); XF.Events:Initialize()
	XF.Timers = TimerCollection:new(); XF.Timers:Initialize()
	XF.Media = MediaCollection:new(); XF.Media:Initialize()

	-- External addon handling
	XF.Addons.ElvUI = XFElvUI:new()
	XF.Addons.RaiderIO = RaiderIOCollection:new()
	XF.Addons.WIM = XFWIM:new()
	XF.Handlers.AddonEvent = AddonEvent:new(); XF.Handlers.AddonEvent:Initialize()

	-- Log XFaction version
	XFO.Versions = XFC.VersionCollection:new(); XFO.Versions:Initialize()
	XF.Version = XFO.Versions:Current()
	XF:Info(ObjectName, 'XFaction version [%s]', XF.Version:Key())
	
	-- Confederate
	XFO.Regions = XFC.RegionCollection:new(); XFO.Regions:Initialize()
	XFO.Confederate = XFC.Confederate:new()
	XFO.Factions = XFC.FactionCollection:new(); XFO.Factions:Initialize()
	XFO.Guilds = XFC.GuildCollection:new()
	XFO.Realms = XFC.RealmCollection:new(); XFO.Realms:Initialize()
	XFO.Targets = XFC.TargetCollection:new()
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
	XF.Handlers.OrderEvent = XFC.OrderEvent:new(); XF.Handlers.OrderEvent:Initialize()
	XF.Handlers.SystemEvent = SystemEvent:new()
	XF.Handlers.TimerEvent = TimerEvent:new()

	-- Network
	XFO.Channels = XFC.ChannelCollection:new()
	XFO.Friends = XFC.FriendCollection:new()
	XFO.Links = XFC.LinkCollection:new(); XFO.Links:Initialize()
	XFO.BNet = XFC.BNet:new()
	XFO.Chat = XFC.Chat:new()
	
	-- Unit
	XFO.Races = XFC.RaceCollection:new(); XFO.Races:Initialize()
	XFO.Classes = XFC.ClassCollection:new(); XFO.Classes:Initialize()
	XFO.Specs = XFC.SpecCollection:new(); XFO.Specs:Initialize()
	XFO.Continents = XFC.ContinentCollection:new(); XFO.Continents:Initialize()
	XFO.Professions = XFC.ProfessionCollection:new(); XFO.Professions:Initialize()	
	XFO.Zones = XFC.ZoneCollection:new(); XFO.Zones:Initialize()	
	XFO.Dungeons = XFC.DungeonCollection:new(); XFO.Dungeons:Initialize()
	XFO.Keys = XFC.MythicKeyCollection:new(); XFO.Keys:Initialize()
	XF.Player.GUID = XFF.PlayerGetGUID('player')
	XF.Player.Faction = XFO.Factions:Get(XFF.PlayerGetFaction('player'))
	
	-- Wrappers	
	XF.Hooks = HookCollection:new(); XF.Hooks:Initialize()
	XFO.Metrics = XFC.MetricCollection:new(); XFO.Metrics:Initialize()	
	XF.Handlers.TimerEvent:Initialize()

	-- These will execute "in-parallel" with remainder of setup as they are not time critical nor is anything dependent upon them
	try(function ()		
		XF.Player.InInstance = XFF.PlayerIsInInstance()
		
		XF.DataText.Guild:Initialize()
		XF.DataText.Links:Initialize()
		XF.DataText.Metrics:Initialize()
		--XF.DataText.Orders:Initialize()

		XFO.Expansions = XFC.ExpansionCollection:new(); XFO.Expansions:Initialize()
		XF.WoW = XFO.Expansions:Current()
		XF:Info(ObjectName, 'WoW client version [%s:%s]', XF.WoW:Name(), XF.WoW:Version():Key())

		XF.DeprecatedVersion = XFC.Version:new()
		XF.DeprecatedVersion:Key('4.13.0')

	end).
	catch(function (err)
		XF:Warn(ObjectName, err)
	end)
end

function XF:CallbackLoginGuild()
	try(function ()
		-- For a time Blizz API says player is not in guild, even if they are
		-- Its not clear what event fires (if any) when this data is available, hence the poller
		if(InGuild()) then
			-- Even though it says were in guild, theres a brief time where the following calls fails, hence the sanity check
			local guildID = GetGuildClubId()
			if(guildID ~= nil) then
				-- Now that guild info is available we can finish setup
				XF:Debug(ObjectName, 'Guild info is loaded, proceeding with setup')
				XF.Timers:Remove('LoginGuild')

				-- Confederate setup via guild info
				XFO.Guilds:Initialize(guildID)
				XFO.Confederate:Initialize()
				XFO.Guilds:SetPlayerGuild()
				XFO.Targets:Initialize()	

				-- Frame inits were waiting on Confederate init
				XF.Frames.Chat:Initialize()
				XF.Frames.System:Initialize()

				-- Start network
				XFO.Channels:Initialize()
				XFO.Chat:Initialize()
				XFO.Friends:Initialize()				
				XFO.BNet:Initialize()

				if(XF.Cache.UIReload) then
					XFO.Confederate:Restore()					
				end

				XF.Timers:Get('LoginPlayer'):Start()
			end
		end
	end).
	catch(function (err)
		XF:Error(ObjectName, err)
	end).
	finally(function ()			
		XF:SetupMenus()
	end)
end

function XF:Stop()
	if(XF.Events) then XF.Events:Stop() end
	if(XF.Hooks) then XF.Hooks:Stop() end
	if(XF.Timers) then XF.Timers:Stop() end
end