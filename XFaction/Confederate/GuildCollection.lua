local XFG, G = unpack(select(2, ...))
local ObjectName = 'GuildCollection'

GuildCollection = ObjectCollection:newChildConstructor()

function GuildCollection:new()
    local object = GuildCollection.parent.new(self)
	object.__name = ObjectName
	object.names = nil
	object.cached = false
	object.info = nil
    return object
end

function GuildCollection:Initialize(inGuildID)
	assert(type(inGuildID) == 'number')
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self.names = {}

		--local _GuildInfo = C_Club.GetClubInfo(inGuildID)
		self.info = {}
		self.info.name = 'Eternal Kingdom'
		self.info.clubId = 1

		if(XFG.Cache.Guilds == nil) then
			XFG.Cache.Guilds = {}
			self:SetFromGuildInfo()
		else
			XFG:Debug(ObjectName, 'Guild information found in cache')
			self:IsCached(true)
			for _, data in ipairs (XFG.Cache.Guilds) do
				local guild = Guild:new()
				guild:Initialize()
				guild:SetKey(data.Initials)
				guild:SetName(data.Name)
				guild:SetFaction(XFG.Factions:Get(data.Faction))
				guild:SetRealm(XFG.Realms:Get(data.Realm))
				guild:SetInitials(data.Initials)
				if(data.ID ~= nil) then
					guild:SetID(data.ID)
					guild:SetStreamID(data.StreamID)
					XFG.Player.Guild = guild
				end
				self.parent.Add(self, guild)
				self.names[guild:GetName()] = guild
				XFG:Info(ObjectName, 'Initialized guild [%s:%s]', guild:GetInitials(), guild:GetName())
			end
		end
		self:IsInitialized(true)
	end
end

function GuildCollection:ContainsName(inGuildName)
	return self.names[inGuildName] ~= nil
end

function GuildCollection:GetByRealmGuildName(inRealm, inGuildName)
	assert(type(inRealm) == 'table' and inRealm.__name == 'Realm', 'argument must be a Realm object')	
	assert(type(inGuildName) == 'string')
	for _, guild in self:Iterator() do
		if(inRealm:Equals(guild:GetRealm()) and guild:GetName() == inGuildName) then
			return guild
		end
	end
end

function GuildCollection:GetByName(inGuildName)
	return self.names[inGuildName]
end

function GuildCollection:Add(inGuild)
    assert(type(inGuild) == 'table' and inGuild.__name == 'Guild', 'argument must be Guild object')

	XFG.Cache.Guilds[#XFG.Cache.Guilds + 1] = {
		Initials = inGuild:GetInitials(),
		Name = inGuild:GetName(),
		Faction = inGuild:GetFaction():GetKey(),
		Realm = inGuild:GetRealm():GetKey(),
	}

	if(inGuild:HasID()) then
		XFG.Cache.Guilds[#XFG.Cache.Guilds].ID = inGuild:GetID()
		XFG.Cache.Guilds[#XFG.Cache.Guilds].streamID = inGuild:GetStreamID()
		XFG.Player.Guild = inGuild
	end

	self.parent.Add(self, inGuild)
	self.names[inGuild:GetName()] = inGuild
	XFG:Info(ObjectName, 'Initialized guild [%s:%s]', inGuild:GetInitials(), inGuild:GetName())
end

function GuildCollection:SetObjectFromString(inString)
	assert(type(inString) == 'string')

	local realmNumber, factionID, guildName, guildInitials = inString:match('XFg:(.-):(.-):(.-):(.+)')
	local realm = XFG.Realms:GetByID(tonumber(realmNumber))
	local faction = XFG.Factions:GetByID(factionID)

	local guild = Guild:new()
	guild:Initialize()
	guild:SetKey(guildInitials)
	guild:SetName(guildName)
	guild:SetFaction(faction)
	guild:SetRealm(realm)
	guild:SetInitials(guildInitials)

	self:Add(guild)
end

function GuildCollection:SetFromGuildInfo()
	-- Parse out configuration from guild information so GMs have control
	local xfData
	-- local _DataIn = string.match(_GuildInfo.description, 'XF:(.-):XF')
	-- if (_DataIn ~= nil) then
	-- 	-- Decompress and deserialize XFaction data
	-- 	local _Decompressed = XFG.Lib.Deflate:DecompressDeflate(XFG.Lib.Deflate:DecodeForPrint(_DataIn))
	-- 	local _, _Deserialized = XFG:Deserialize(_Decompressed)
	-- 	XFG:Debug(ObjectName, 'Data from config %s', _Deserialized)
	-- 	_XFData = _Deserialized
	-- else
	-- 	_XFData = _GuildInfo.description
	-- end

	-- -- Parse out configuration from guild information so GMs have control
	-- local _XFData
	-- local _DataIn = string.match(_GuildInfo.description, 'XF:(.-):XF')
	-- if (_DataIn ~= nil) then
	-- 	-- Decompress and deserialize XFaction data
	-- 	local _Decompressed = XFG.Lib.Deflate:DecompressDeflate(XFG.Lib.Deflate:DecodeForPrint(_DataIn))
	-- 	local _, _Deserialized = XFG:Deserialize(_Decompressed)
	-- 	XFG:Debug(ObjectName, 'Data from config %s', _Deserialized)
	-- 	_XFData = _Deserialized
	-- else
	-- 	_XFData = _GuildInfo.description
	-- end

	xfData = "XFn:Eternal Kingdom:EK\n" ..
				"XFc:EKXFaction:pineapple\n" .. 
				"XFg:5:A:Eternal Kingdom:EKA\n" ..
				"XFg:5:H:Eternal Kingdom Horde:EKH\n" ..
				"XFg:5:A:Endless Kingdom:ENK\n" ..
				"XFg:5:A:Alternal Kingdom:AK\n" ..
				"XFg:5:A:Alternal Kingdom Two:AK2\n" ..
				"XFg:5:A:Alternal Kingdom Three:AK3\n" ..
				"XFg:5:H:Alternal Kingdom Four:AK4\n" ..
				"XFa:Grand Alt"

	for _, line in ipairs(string.Split(xfData, '\n')) do
		-- Confederate information
		if(string.find(line, 'XFn')) then                    
			local name, initials = line:match('XFn:(.-):(.+)')
			XFG:Info(ObjectName, 'Initializing confederate %s <%s>', name, initials)
			Confederate:SetName(name)
			Confederate:SetKey(initials)
			XFG.Settings.Network.Message.Tag.LOCAL = initials .. 'XF'
			XFG.Settings.Network.Message.Tag.BNET = initials .. 'BNET'
		-- Guild within the confederate
		elseif(string.find(line, 'XFg')) then
			self:SetObjectFromString(line)
		-- Local channel for same realm/faction communication
		elseif(string.find(line, 'XFc')) then
			XFG.Cache.Channel.Name, XFG.Cache.Channel.Password = line:match('XFc:(.-):(.*)')
		-- If you keep your alts at a certain rank, this will flag them as alts in comms/DTs
		elseif(string.find(line, 'XFa')) then
			local altRank = line:match('XFa:(.+)')
			XFG:Info(ObjectName, 'Initializing alt rank [%s]', altRank)
			XFG.Settings.Confederate.AltRank = altRank
		elseif(string.find(line, 'XFt')) then
			XFG.Teams:SetObjectFromString(line)
		end
	end		
end

function GuildCollection:SetPlayerGuild()
	if(not self:IsCached()) then
		for _, guild in self:Iterator() do
			if(guild:GetName() == self.info.name and XFG.Player.Realm:Equals(guild:GetRealm())) then
				guild:SetID(self.info.clubId)
				for _, stream in pairs (C_Club.GetStreams(guild:GetID())) do
					if(stream.streamType == 1) then
						guild:SetStreamID(stream.streamId)
						break
					end
				end
				XFG.Player.Guild = guild
				break
			end
		end
		if(XFG.Player.Guild == nil) then
			error('Player is not on a supported guild or realm')
		end
	end
end