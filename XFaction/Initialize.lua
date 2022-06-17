local XFG, G = unpack(select(2, ...))
local LogCategory = 'Initialize'

function XFG:Init()	
	XFG.Player.GUID = UnitGUID('player')
	XFG.Realms = RealmCollection:new(); XFG.Realms:Initialize()
	XFG.Teams = TeamCollection:new(); XFG.Teams:Initialize()
	XFG.Factions = FactionCollection:new(); XFG.Factions:Initialize()
	XFG.Player.Faction = XFG.Factions:GetFactionByName(UnitFactionGroup('player'))

	XFG.Ranks = RankCollection:new(); XFG.Ranks:Initialize()
	XFG.Guilds = GuildCollection:new(); XFG.Guilds:Initialize()

	-- Make sure we have all the realm/guild combinations accounted for
	for _RealmName, _FactionGuilds in pairs(XFG.Cache.Guilds) do
		local _NewRealm = Realm:new()
		_NewRealm:SetKey(_RealmName)
		_NewRealm:SetName(_RealmName)
		_NewRealm:Initialize()
		XFG.Realms:AddRealm(_NewRealm)
		for _FactionName, _Guilds in pairs(_FactionGuilds) do
			local _Faction = XFG.Factions:GetFactionByName(_FactionName)
			for _GuildInitials, _GuildName in pairs (_Guilds) do
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

	XFG.Network.Mailbox = Mailbox:new(); XFG.Network.Mailbox:Initialize()	
	XFG.Network.BNet.Targets = TargetCollection:new(); XFG.Network.BNet.Targets:Initialize()	
	
	for _, _Target in XFG.Network.BNet.Targets:Iterator() do
		local _Realm = _Target:GetRealm()
		local _Faction = _Target:GetFaction()
		XFG:Info(LogCategory, "Established BNet target [%s:%s]", _Realm:GetName(), _Faction:GetName())
	end

	-- These handlers will register additional handlers
	XFG.Handlers.TimerEvent = TimerEvent:new(); XFG.Handlers.TimerEvent:Initialize()
	XFG.Handlers.SystemEvent = SystemEvent:new(); XFG.Handlers.SystemEvent:Initialize()

	--XFG.Frames.Channel = XChannelFrame:new(); XFG.Frames.Channel:Initialize()
	XFG.Frames.Chat = ChatFrame:new(); XFG.Frames.Chat:Initialize()
	XFG.Frames.System = SystemFrame:new(); XFG.Frames.System:Initialize()

	-- Initialize DTs
	XFG.DataText.Guild = DTGuild:new(); XFG.DataText.Guild:Initialize()
	XFG.DataText.Links = DTLinks:new(); XFG.DataText.Links:Initialize()
	XFG.DataText.Shard = DTShard:new(); XFG.DataText.Shard:Initialize()
	XFG.DataText.Soulbind = DTSoulbind:new(); XFG.DataText.Soulbind:Initialize()
	XFG.DataText.Token = DTToken:new(); XFG.DataText.Token:Initialize()
end

do
	XFG.Init()
end