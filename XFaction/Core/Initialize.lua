local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'CoreInit'

-- Initialize anything not dependent upon guild information
function XF:CoreInit()
	-- Get cache/configs asap	
	XFO.Events = XFC.EventCollection:new(); XFO.Events:Initialize()
	XFO.Timers = XFC.TimerCollection:new(); XFO.Timers:Initialize()
	XFO.Media = XFC.MediaCollection:new(); XFO.Media:Initialize()
	XFO.Janitor = XFC.Janitor:new()

	-- External addon handling
	XFO.Elephant = XFC.Elephant:new()
	XFO.ElvUI = XFC.ElvUI:new()
	XFO.RaiderIO = XFC.RaiderIOCollection:new()
	XFO.WIM = XFC.WIM:new()
	XFO.AddonEvent = XFC.AddonEvent:new(); XFO.AddonEvent:Initialize()

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
	XFO.DTGuild = XFC.DTGuild:new()
	XFO.DTLinks = XFC.DTLinks:new()
	XFO.DTMetrics = XFC.DTMetrics:new()

	-- Frames
	XFO.ChatFrame = XFC.ChatFrame:new()
	XFO.SystemFrame = XFC.SystemFrame:new()

	-- Declare handlers but not listening yet
	XFO.SystemEvent = XFC.SystemEvent:new()

	-- Network
	XFO.Channels = XFC.ChannelCollection:new()
	XFO.Friends = XFC.FriendCollection:new()
	XFO.Mailbox = XFC.Mailbox:new(); XFO.Mailbox:Initialize()
	XFO.PostOffice = XFC.PostOffice:new(); XFO.PostOffice:Initialize()
	XFO.BNet = XFC.BNet:new()
	XFO.Chat = XFC.Chat:new()
	XFO.Tags = XFC.TagCollection:new()
	
	-- Unit
	XFO.Races = XFC.RaceCollection:new(); XFO.Races:Initialize()
	XFO.Classes = XFC.ClassCollection:new(); XFO.Classes:Initialize()
	XFO.Specs = XFC.SpecCollection:new(); XFO.Specs:Initialize()
	XFO.Heros = XFC.HeroCollection:new(); XFO.Heros:Initialize()
	XFO.Professions = XFC.ProfessionCollection:new(); XFO.Professions:Initialize()
	
	XFO.Locations = XFC.LocationCollection:new(); XFO.Locations:Initialize()
	XFO.Dungeons = XFC.DungeonCollection:new(); XFO.Dungeons:Initialize()
	XFO.Keys = XFC.MythicKeyCollection:new(); XFO.Keys:Initialize()
	
	XF.Player.GUID = XFF.PlayerGUID('player')
	XF.Player.Faction = XFO.Factions:Get(XFF.PlayerFaction('player'))
	
	-- Wrappers	
	XFO.Hooks = XFC.HookCollection:new(); XFO.Hooks:Initialize()
	XFO.Metrics = XFC.MetricCollection:new(); XFO.Metrics:Initialize()

	-- WoW Lua does not have a sleep function, so leverage timers for retry mechanics
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
		
		XFO.DTGuild:Initialize()
		XFO.DTLinks:Initialize()
		XFO.DTMetrics:Initialize()

		XFO.Expansions = XFC.ExpansionCollection:new(); XFO.Expansions:Initialize()
		XF.WoW = XFO.Expansions:Current()
		XF:Info(ObjectName, 'WoW client version [%s:%s]', XF.WoW:Name(), XF.WoW:Version():Key())
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
			local guildID = XFF.GuildID()
			if(guildID ~= nil) then
				-- Now that guild info is available we can finish setup
				XF:Debug(ObjectName, 'Guild info is loaded, proceeding with setup')
				XFO.Timers:Remove('LoginGuild')

				-- Confederate setup via guild info
				XFO.Guilds:Initialize(guildID)
				XFO.Confederate:Initialize()
				XFO.Targets:Initialize()	

				-- Frame inits were waiting on Confederate init
				XFO.ChatFrame:Initialize()
				XFO.SystemFrame:Initialize()
				
				XFO.Timers:Add({
					name = 'LoginPlayer', 
					delta = 1, 
					callback = XF.CallbackLoginPlayer, 
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

function XF:CallbackLoginPlayer()

	try(function ()
		
		-- Need the player data to continue setup
		local unit = XFC.Unit:new()
		unit:Initialize()
		if(unit:IsInitialized()) then
			XF:Debug(ObjectName, 'Player info is loaded, proceeding with setup')
			XFO.Timers:Remove('LoginPlayer')

			XFO.Confederate:OnlineUnit(unit)
			XF.Player.Unit:Print()

			-- Start network
			XFO.Tags:Initialize()
			XFO.Channels:Initialize()
			XFO.Chat:Initialize()							
			XFO.BNet:Initialize()
			XFO.Friends:Initialize()
			XFO.Janitor:Initialize()

			-- If reload, restore backup information
			if(XF.Cache.UIReload) then
				XF.Cache.UIReload = false
				XFO.Confederate:Restore()
                XFO.Mailbox:SendDataMessage()
			-- Otherwise send login message
			else
                XFO.Mailbox:SendLoginMessage()
			end

			-- On initial login, the roster returned is incomplete, you have to force Blizz to do a guild roster refresh
			XFF.GuildQueryServer()
			
			-- Start all hooks, timers and events
			XFO.SystemEvent:Initialize()
			XFO.Hooks:Start()
			XFO.Timers:Start()
			XFO.Events:Start()				
			XF.Initialized = true

			-- Finish DT init
			XFO.DTGuild:PostInitialize()
			XFO.DTLinks:PostInitialize()
			XFO.DTMetrics:PostInitialize()

			-- For support reasons, it helps to know what addons are being used
			for i = 1, XFF.ClientAddonCount() do
				local name, _, _, enabled = XFF.ClientAddonInfo(i)
				XF:Debug(ObjectName, 'Addon is loaded [%s] enabled [%s]', name, tostring(enabled))
			end			

			XFO.Timers:Add({
				name = 'LoginChannelSync',
				delta = XF.Settings.Network.Channel.LoginChannelSyncTimer, 
				callback = XFO.Channels.CallbackSync,
				repeater = true,
				maxAttempts = XF.Settings.Network.Channel.LoginChannelSyncAttempts,
				instance = true,
				start = true
			})
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