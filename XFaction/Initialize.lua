local XFG, G = unpack(select(2, ...))
local LogCategory = 'Initialize'

function XFG:Init()
	XFG.Player.GUID = UnitGUID('player')
	XFG.Realms = RealmCollection:new(); XFG.Realms:Initialize()
	XFG.Teams = TeamCollection:new(); XFG.Teams:Initialize()
	XFG.Factions = FactionCollection:new(); XFG.Factions:Initialize()
	XFG.Player.Faction = XFG.Factions:GetFactionByName(UnitFactionGroup('player'))
	XFG.Guilds = GuildCollection:new(); XFG.Guilds:Initialize()

	-- Make sure we have all the realm/guild combinations accounted for
	for _RealmName, _FactionGuilds in pairs(XFG.Settings.Guilds) do
		XFG:Debug(LogCategory, 'Initializing realm [%s]', _RealmName)
		local _NewRealm = Realm:new()
		_NewRealm:SetKey(_RealmName)
		_NewRealm:SetName(_RealmName)
		_NewRealm:SetAPIName(string.gsub(_RealmName, '%s+', ''))
		_NewRealm:Initialize()
		XFG.Realms:AddRealm(_NewRealm)
		for _FactionName, _Guilds in pairs(_FactionGuilds) do
			local _Faction = XFG.Factions:GetFactionByName(_FactionName)
			for _GuildInitials, _GuildName in pairs (_Guilds) do
				XFG:Debug(LogCategory, 'Initializing guild [%s]', _GuildName)
				local _NewGuild = Guild:new()
				_NewGuild:Initialize()
				_NewGuild:SetName(_GuildName)
				_NewGuild:SetFaction(_Faction)
				_NewGuild:SetRealm(_NewRealm)
				_NewGuild:SetInitials(_GuildInitials)
				XFG.Guilds:AddGuild(_NewGuild)
			end
		end
	end

	local _RealmName = GetRealmName()
	XFG.Player.Realm = XFG.Realms:GetRealm(_RealmName)
	if(XFG.Player.Realm == nil) then
		XFG:Error(LogCategory, 'Player is not on a supported realm [%s]', _RealmName)
		return
	end

	XFG.Mailbox = Mailbox:new(); XFG.Mailbox:Initialize()	
	XFG.Targets = TargetCollection:new(); XFG.Targets:Initialize()

	-- A significant portion of start up is delayed due to guild information not being available yet
	XFG.Handlers.TimerEvent = TimerEvent:new(); XFG.Handlers.TimerEvent:Initialize()

	XFG.Frames.Chat = ChatFrame:new(); XFG.Frames.Chat:Initialize()
	XFG.Frames.System = SystemFrame:new(); XFG.Frames.System:Initialize()
	--XFG.Frames.XFaction = XFactionFrame:new(); XFG.Frames.XFaction:Initialize()

	-- Initialize DTs
	XFG.DataText.Guild = DTGuild:new(); XFG.DataText.Guild:Initialize()
	XFG.DataText.Links = DTLinks:new(); XFG.DataText.Links:Initialize()
	XFG.DataText.Soulbind = DTSoulbind:new(); XFG.DataText.Soulbind:Initialize()
	XFG.DataText.Token = DTToken:new(); XFG.DataText.Token:Initialize()
end

do
	XFG.Init()
end