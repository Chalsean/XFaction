local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'CoreInit'

-- Initialize anything not dependent upon guild information
function XF:CoreInit()
	-- Get cache/configs asap	
	XFO.Events = XFC.EventCollection:new(); XFO.Events:Initialize()
	XFO.Timers = XFC.TimerCollection:new(); XFO.Timers:Initialize()
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
	XFO.Hooks = XFC.HookCollection:new(); XFO.Hooks:Initialize()
	XFO.Metrics = XFC.MetricCollection:new(); XFO.Metrics:Initialize()	
	
    -- WoW Lua does not have a sleep function, so leverage timers for retry mechanics
    -- Have to wait for guild data to become available, theres no event to key off of
    XFO.Timers:Add({
        name = 'LoginGuild', 
        delta = 1, 
        callback = XF.CallbackLoginGuild, 
        repeater = true, 
        instance = true,
        ttl = XF.Settings.LocalGuild.LoginTTL,
        start = true
    })

	-- These will execute "in-parallel" with remainder of setup as they are not time critical nor is anything dependent upon them
	try(function ()		
		XF.Player.InInstance = XFF.PlayerIsInInstance()
		
		XF.DataText.Guild:Initialize()
		XF.DataText.Links:Initialize()
		XF.DataText.Metrics:Initialize()

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
		if(XFF.PlayerIsInGuild()) then
			-- Even though it says were in guild, theres a brief time where the following calls fails, hence the sanity check
			local guildID = XFF.GuildGetID()
			if(guildID ~= nil) then
				-- Now that guild info is available we can finish setup
				XF:Debug(ObjectName, 'Guild info is loaded, proceeding with setup')
				XFO.Timers:Remove('LoginGuild')

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

                -- Have to wait for player data to become available
				XFO.Timers:Add({
                    name = 'LoginPlayer', 
                    delta = 1, 
                    callback = XF.CallbackLoginPlayer, 
                    repeater = true, 
                    instance = true,
                    maxAttempts = XF.Settings.Player.Retry
                })
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

function XF:CallbackLoginPlayer()
	try(function ()
		-- Far as can tell does not fire event, so call and pray it loads before we query for the data
		XFF.ClientRequestMaps()

		-- Need the player data to continue setup
		local unitData = XFO.Confederate:Pop()
		unitData:Initialize()
		if(unitData:IsInitialized()) then
			XF:Debug(ObjectName, 'Player info is loaded, proceeding with setup')
			XFO.Timers:Remove('LoginPlayer')

			XFO.Confederate:Add(unitData)
			XF.Player.Unit:Print()

			-- By this point all the channels should have been joined
			if(not XFO.Channels:UseGuild()) then
				XFO.Channels:CallbackSync()
				if(XFO.Channels:HasLocalChannel()) then
					XFO.Channels:SetLast(XFO.Channels:LocalChannel():Key())
				end
			end
			
			-- If reload, restore backup information
			if(XF.Cache.UIReload) then
				XFO.Friends:Restore()
				XFO.Links:Restore()
				XFO.Orders:Restore()
				XF.Cache.UIReload = false
				XFO.Chat:SendDataMessage(XF.Player.Unit)
			-- Otherwise send login message
			else
				XFO.Chat:SendLoginMessage(XF.Player.Unit)
			end			

			-- Start all hooks, timers and events
			XF.Handlers.SystemEvent:Initialize()
			XFO.Hooks:Start()
			XFO.Timers:Start()
			XFO.Events:Start()				
			XF.Initialized = true

			-- Finish DT init
			XF.DataText.Guild:PostInitialize()
			XF.DataText.Links:PostInitialize()
			XF.DataText.Metrics:PostInitialize()

			-- For support reasons, it helps to know what addons are being used
			for i = 1, XFF.ClientGetAddonCount() do
				local name, _, _, enabled = XFF.ClientGetAddonInfo(i)
				XF:Debug(ObjectName, 'Addon is loaded [%s] enabled [%s]', name, tostring(enabled))
			end

            XFO.Timers:Add({
                name = 'Heartbeat', 
                delta = XF.Settings.Player.Heartbeat, 
                callback = XFO.Confederate.CallbackHeartbeat, 
                repeater = true, 
                instance = true,
                start = true
            })

			XFO.Timers:Add({
				name = 'LoginChannelSync',
				delta = XF.Settings.Network.Channel.LoginChannelSyncTimer, 
				callback = XFO.Channels.CallbackSync,
				repeater = true,
				maxAttempts = XF.Settings.Network.Channel.LoginChannelSyncAttempts,
				instance = true,
				start = true
			})
		else
			XFO.Confederate:Push(unitData)
		end
	end).
	catch(function (err)
		XF:Error(ObjectName, err)
	end)
end

function XF:Stop()
	if(XFO.Events) then XFO.Events:Stop() end
	if(XFO.Hooks) then XFO.Hooks:Stop() end
	if(XFO.Timers) then XFO.Timers:Stop() end
end