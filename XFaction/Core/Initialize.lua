local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'CoreInit'

local InGuild = IsInGuild
local GetGuildId = C_Club.GetGuildClubId
local GetNumAddOns = C_Addons.GetNumAddOns
local GetAddOnInfo = C_Addons.GetAddOnInfo

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
	XFO.ChatFrame = XFC.ChatFrame:new()
	XFO.SystemFrame = XFC.SystemFrame:new()

	-- Declare handlers but not listening yet
	XFO.AchievementEvent = XFC.AchievementEvent:new(); XFO.AchievementEvent:Initialize()
	XFO.BNetEvent = XFC.BNetEvent:new(); XFO.BNetEvent:Initialize()
	XFO.ChannelEvent = XFC.ChannelEvent:new()
	XFO.ChatEvent = XFC.ChatEvent:new(); XFO.ChatEvent:Initialize()
	XFO.GuildEvent = XFC.GuildEvent:new(); XFO.GuildEvent:Initialize()
	XFO.PlayerEvent = XFC.PlayerEvent:new(); XFO.PlayerEvent:Initialize()
	XFO.SystemEvent = XFC.SystemEvent:new()
	XFO.TimerEvent = XFC.TimerEvent:new()

	-- Network
	XFO.Channels = XFC.ChannelCollection:new()
	XFO.Friends = XFC.FriendCollection:new()
	XFO.Links = XFC.LinkCollection:new()
	XFO.Nodes = XFC.NodeCollection:new()
	XFO.BNet = XFC.BNet:new()
	XFO.Chat = XFC.Chat:new()
	
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

	-- WoW Lua does not have a sleep function, so leverage timers for retry mechanics
	XFO.Timers:Add
	({
		name = 'LoginGuild', 
		delta = 1, 
		callback = XF.LoginGuild, 
		repeater = true, 
		instance = true,
		ttl = XF.Settings.LocalGuild.LoginTTL,
		start = true
	})
end

function XF:LoginGuild()
	try(function ()
		-- For a time Blizz API says player is not in guild, even if they are
		-- Its not clear what event fires (if any) when this data is available, hence the poller
		if(InGuild()) then
			-- Even though it says were in guild, theres a brief time where the following calls fails, hence the sanity check
			local guildID = GetGuildId()
			if(guildID ~= nil) then
				-- Now that guild info is available we can finish setup
				XF:Debug(self:GetObjectName(), 'Guild info is loaded, proceeding with setup')
				XFO.Timers:Remove('LoginGuild')

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
				XFO.ChannelEvent:Initialize()
				XFO.Chat:Initialize()
				XFO.Nodes:Initialize()
				XFO.Links:Initialize()
				XFO.Friends:Initialize()				
				XFO.BNet:Initialize()

				if(XF.Cache.UIReload) then
					XFO.Confederate:Restore()					
				end

				XFO.Timers:Add
				({
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
		XF:Error(self:GetObjectName(), err)
	end).
	finally(function ()			
		XF:SetupMenus()
	end)
end

function XF:LoginPlayer()
	try(function ()
		-- Need the player data to continue setup
		local unit = XFO.Confederate:Pop()
		-- FIX: Dont have player id, this will throw or get wrong unit
		unit:Initialize()
		if(unit:IsInitialized()) then
			XF:Debug(self:GetObjectName(), 'Player info is loaded, proceeding with setup')
			XFO.Timers:Remove('LoginPlayer')

			XFO.Confederate:Add(unit)
			XF.Player.Unit:Print()

			-- By this point all the channels should have been joined
			if(not XFO.Channels:UseGuild()) then
				XFO.Channels:Sync()
				if(XFO.Channels:HasLocalChannel()) then
					XFO.Channels:SetLast(XFO.Channels:GetLocalChannel():GetKey())
				end
			end
			
			-- If reload, restore backup information
			if(XF.Cache.UIReload) then
				XFO.Friends:Restore()
				XFO.Links:Restore()
				-- FIX: Move to retail
				--XFO.Orders:Restore()
				XF.Cache.UIReload = false
				XF.Player.Unit:Broadcast()
			-- Otherwise send login message
			else
				XF.Player.Unit:Broadcast(XF.Enum.Message.LOGIN)
			end	
			
			XFO.Timers:Add
        	({
            	name = 'Heartbeat', 
            	delta = XF.Settings.Player.Heartbeat, 
            	callback = XF.Player.Unit.Broadcast, 
            	repeater = true, 
            	instance = true
        	})

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
			for i = 1, GetNumAddOns() do
				local name, _, _, enabled = GetAddOnInfo(i)
				XF:Debug(self:GetObjectName(), 'Addon is loaded [%s] enabled [%s]', name, tostring(enabled))
			end

			XFO.Timers:Get('LoginChannelSync'):Start()		
		else
			XFO.Confederate:Push(unit)
		end
	end).
	catch(function (err)
		XF:Error(self:GetObjectName(), err)
	end)
end

function XF:Stop()
	if(XFO.Events) then XFO.Events:Stop() end
	if(XFO.Hooks) then XFO.Hooks:Stop() end
	if(XFO.Timers) then XFO.Timers:Stop() end
end