local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'CoreInit'

-- Initialize anything not dependent upon guild information
function XF:CoreInit()
	-- Get cache/configs asap	
	XFO.Events = XFC.EventCollection:new(); XFO.Events:Initialize()
	XFO.Media = XFC.MediaCollection:new(); XFO.Media:Initialize()

	-- Wrappers	
	XFO.Hooks = XFC.HookCollection:new(); XFO.Hooks:Initialize()
	XFO.Metrics = XFC.MetricCollection:new(); XFO.Metrics:Initialize()	
	XFO.Timers = XFC.TimerCollection:new(); XFO.Timers:Initialize()
	XFO.InitTimers = XFC.TimerCollection:new(); XFO.InitTimers:Initialize()

	-- External addon handling
	XFO.ElvUI = XFC.ElvUI:new()
	XFO.RaiderIO = XFC.RaiderIOCollection:new()
	XFO.WIM = XFC.WIM:new()
	XFO.AddonEvent = XFC.AddonEvent:new(); XFO.AddonEvent:Initialize()

	-- Log XFaction version
	XFO.Versions = XFC.VersionCollection:new(); XFO.Versions:Initialize()
	XFO.Version = XFO.Versions:Current()
	XF:Info(ObjectName, 'XFaction version [%s]', XFO.Version:Key())
	
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
	XFO.ChatFrame = XFC.ChatFrame:new()
	XFO.SystemFrame = XFC.SystemFrame:new()

	-- Event Handlers
	XFO.PlayerEvent = XFC.PlayerEvent:new(); XFO.PlayerEvent:Initialize()

	-- Network
	XFO.Channels = XFC.ChannelCollection:new()
	XFO.Friends = XFC.FriendCollection:new()
	XFO.BNet = XFC.BNet:new()
	XFO.Chat = XFC.Chat:new()
	
	-- Unit
	XFO.Classes = XFC.ClassCollection:new(); XFO.Classes:Initialize()
	XFO.Professions = XFC.ProfessionCollection:new(); XFO.Professions:Initialize()
	XFO.Orders = XFC.OrderCollection:new(); XFO.Orders:Initialize()
	XFO.Races = XFC.RaceCollection:new(); XFO.Races:Initialize()
	XFO.Specs = XFC.SpecCollection:new(); XFO.Specs:Initialize()

	-- Location
	XFO.Continents = XFC.ContinentCollection:new(); XFO.Continents:Initialize()
	XFO.Zones = XFC.ZoneCollection:new(); XFO.Zones:Initialize()	
	XFO.Dungeons = XFC.DungeonCollection:new(); XFO.Dungeons:Initialize()
	XFO.Keys = XFC.MythicKeyCollection:new(); XFO.Keys:Initialize()

	-- Player
	XF.Player.GUID = XFF.PlayerGetGUID('player')
	XF.Player.Faction = XFO.Factions:Get(XFF.PlayerGetFaction('player'))
	XF.Player.InInstance = XFF.PlayerIsInGuild()
	
	-- DataText
	XFO.DTGuild:Initialize()
	XFO.DTLinks:Initialize()
	XFO.DTMetrics:Initialize()

	-- Client
	XFO.Expansions = XFC.ExpansionCollection:new(); XFO.Expansions:Initialize()
	XFO.WoW = XFO.Expansions:Current()
	XF:Info(ObjectName, 'WoW client version [%s:%s]', XFO.WoW:Name(), XFO.WoW:Version():Key())

	-- WoW Lua does not have a sleep function, so leverage timers for retry mechanics
	XFO.InitTimers:Add({
		name = 'LoginGuild', 
		delta = 1, 
		callback = XF.LoginGuild, 
		repeater = true, 
		instance = true,
		ttl = XF.Settings.LocalGuild.LoginTTL,
		start = true
	})

	XFO.InitTimers:Start()
end

function XF:LoginGuild()
	try(function ()
		-- For a time Blizz API says player is not in guild, even if they are
		-- Its not clear what event fires (if any) when this data is available, hence the poller
		if(XFF.PlayerIsInGuild()) then
			-- Even though it says were in guild, theres a brief time where the following calls fails, hence the sanity check
			local guildID = XFF.GuildGetID()
			if(guildID ~= nil) then
				-- Now that guild info is available we can finish setup
				XF:Debug(ObjectName, 'Guild info is loaded, proceeding with setup')
				XFO.InitTimers:Get('LoginGuild'):Stop()

				XF:InitializeCache()
                XF:InitializeConfig()
				
				-- Confederate setup via guild info
				XFO.Guilds:Initialize(guildID)
				XFO.Confederate:Initialize()
				XFO.Guilds:SetPlayerGuild()
				XFO.Targets:Initialize()	

				-- Frame inits were waiting on Confederate init
				XFO.ChatFrame:Initialize()
				XFO.SystemFrame:Initialize()

				-- Start network
				XFO.Channels:Initialize()
				XFO.Chat:Initialize()
				--XFO.Links:Initialize()
				XFO.Friends:Initialize()				
				XFO.BNet:Initialize()

				if(XF.Cache.UIReload) then
					XFO.Confederate:Restore()					
				end

				XFO.InitTimers:Add({
					name = 'LoginPlayer', 
					delta = 1, 
					callback = XF.LoginPlayer, 
					repeater = true, 
					instance = true,
					maxAttempts = XF.Settings.Player.Retry,
					start = true
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

function XF:LoginPlayer()
	try(function ()
		-- Need the player data to continue setup
		local unit = XFO.Confederate:Pop()
		unit:Initialize()
		if(unit:IsInitialized()) then
			XF:Debug(ObjectName, 'Player info is loaded, proceeding with setup')
			XFO.InitTimers:Get('LoginPlayer'):Stop()

			XFO.Confederate:Add(unit)
			XFO.Keys = XFC.MythicKeyCollection:new(); XFO.Keys:Initialize()
			XF.Player.Unit:Print()

			if(XFO.Channels:UseGuild()) then
				XFO.InitTimers:Stop()
			else
				-- The whole channel thing is a mess, the channel #s are given out in whatever order addons/client ask for them
				-- So we have to repeatedly move the channel to last for a period of time
				XFO.InitTimers:Add({
					name = 'LoginChannelSync',
					delta = XF.Settings.Network.Channel.LoginChannelSyncTimer, 
					callback = XF.LoginChannel,
					instance = true,
					start = true,
					repeater = true,
					maxAttempts = XF.Settings.Network.Channel.LoginChannelSyncAttempts
				})
			end

			XFO.Timers:Add({
            	name = 'Heartbeat', 
            	delta = XF.Settings.Player.Heartbeat, 
            	callback = XF.Player.Unit.Broadcast, 
            	repeater = true, 
            	instance = true
        	})
			
			-- If reload, restore backup information
			if(XF.Cache.UIReload) then
				XFO.Friends:Restore()
				--XFO.Links:Restore()
				XFO.Orders:Restore()
				XF.Player.Unit:Broadcast()
				XF.Cache.UIReload = false
			-- Otherwise send login message
			else
				XF.Player.Unit:Broadcast(XF.Enum.Message.LOGIN)
			end			
			
			XFO.Hooks:Add({
				name = 'ReloadUI', 
				original = 'ReloadUI', 
				callback = XF.Reload,
				pre = true
			})        	

			-- Setup is done, turn everything on
			XFO.Hooks:EnableAll()
			XFO.Hooks:Start()
			XFO.Events:EnableAll()
			XFO.Events:Start()
			XFO.Timers:EnableAll()
			XFO.Timers:Start()
			XF.Initialized = true

			-- Finish DT init
			XFO.DTGuild:PostInitialize()
			XFO.DTLinks:PostInitialize()
			XFO.DTMetrics:PostInitialize()

			-- For support reasons, it helps to know what addons are being used
			for i = 1, XFF.ClientGetAddonCount() do
				local name, _, _, enabled = XFF.ClientGetAddonInfo(i)
				XF:Debug(ObjectName, 'Addon is loaded [%s] enabled [%s]', name, tostring(enabled))
			end
		else
			XFO.Confederate:Push(unit)
		end
	end).
	catch(function (err)
		XF:Error(ObjectName, err)
	end)
end

function XF:LoginChannel()
	try(function()
		XFO.Channels:Sync()
		if(XFO.Channels:HasLocalChannel()) then
			XFO.Channels:MoveLast(XFO.Channels:LocalChannel():Key())
			XFO.InitTimers:Stop()
		end
	end).
	catch(function(err)
		XF:Warn(ObjectName, err)
	end)
end

function XF:Reload()
	try(function ()
		XF:Stop()
        XFO.Confederate:Backup()
        XFO.Friends:Backup()
        --XFO.Links:Backup()
        XFO.Orders:Backup()
    end).
    catch(function (err)
        XF:Error(ObjectName(), err)
        XF.Config.Errors[#XF.Config.Errors + 1] = 'Failed to perform backups: ' .. err
    end).
    finally(function ()
        XF.Cache.UIReload = true
        _G.XFCacheDB = XF.Cache
    end)
end

function XF:Stop()
	if(XFO.Timers) then XFO.Timers:Stop() end
	if(XFO.Events) then XFO.Events:Stop() end
	if(XFO.Hooks) then XFO.Hooks:Stop() end
end