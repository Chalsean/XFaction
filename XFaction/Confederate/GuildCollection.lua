local XFG, G = unpack(select(2, ...))
local ObjectName = 'GuildCollection'

GuildCollection = ObjectCollection:newChildConstructor()

--#region Constructors
function GuildCollection:new()
    local object = GuildCollection.parent.new(self)
	object.__name = ObjectName
	object.names = nil
	object.cached = false
	object.info = nil
    return object
end
--#endregion

--#region Initializers
function GuildCollection:Initialize(inGuildID)
	assert(type(inGuildID) == 'number')
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self.names = {}
		self.info = C_Club.GetClubInfo(inGuildID)
		self:SetFromGuildInfo()
		self:IsInitialized(true)
	end
end
--#endregion

--#region Hash
function GuildCollection:ContainsName(inGuildName)
	return self.names[inGuildName] ~= nil
end

function GuildCollection:Add(inGuild)
    assert(type(inGuild) == 'table' and inGuild.__name == 'Guild', 'argument must be Guild object')
	self.parent.Add(self, inGuild)
	self.names[inGuild:GetName()] = inGuild
	XFG:Info(ObjectName, 'Initialized guild [%s:%s]', inGuild:GetInitials(), inGuild:GetName())
end
--#endregion

--#region Accessors
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
--#endregion

--#region DataSet
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
	local xfData = ''
	local compressed = string.match(self.info.description, 'XF:(.-):XF')
	if (compressed ~= nil) then
		-- Decompress and deserialize XFaction data
		local decompressed = XFG.Lib.Deflate:DecompressDeflate(XFG.Lib.Deflate:DecodeForPrint(compressed))
		local _, deserialized = XFG.Lib.Serializer:Deserialize(decompressed)
		xfData = deserialized
	else
		xfData = self.info.description
	end

	if(not string.len(xfData)) then
		error('Failed to find setup in guild information')
	end

	for _, line in ipairs(string.Split(xfData, '\n')) do
		-- Confederate information
		if(string.find(line, 'XFn')) then                    
			local name, initials = line:match('XFn:(.-):(.+)')
			XFG.Cache.Confederate.Name = name
			XFG.Cache.Confederate.Key = initials
		-- Guild within the confederate
		elseif(string.find(line, 'XFg')) then
			self:SetObjectFromString(line)
		-- Local channel for same realm/faction communication
		elseif(string.find(line, 'XFc')) then
			XFG.Cache.Channel.Name, XFG.Cache.Channel.Password = line:match('XFc:(.-):(.*)')
		-- If you keep your alts at a certain rank, this will flag them as alts in comms/DTs
		elseif(string.find(line, 'XFa')) then
			local altRank = line:match('XFa:(.+)')
			XFG.Settings.Confederate.AltRank = altRank
			XFG:Info(ObjectName, 'Initialized alt rank [%s]', altRank)
		elseif(string.find(line, 'XFt')) then
			XFG.Teams:SetObjectFromString(line)
		end
	end		
end

function GuildCollection:SetPlayerGuild()
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
--#endregion