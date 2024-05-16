local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'GuildCollection'

GuildCollection = XFC.ObjectCollection:newChildConstructor()

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
	self.names[inGuild:Name()] = inGuild
	XF:Info(ObjectName, 'Initialized guild [%s:%s]', inGuild:GetInitials(), inGuild:Name())
end
--#endregion

--#region Accessors
function GuildCollection:GetByRealmGuildName(inRealm, inGuildName)
	assert(type(inRealm) == 'table' and inRealm.__name == 'Realm', 'argument must be a Realm object')	
	assert(type(inGuildName) == 'string')
	for _, guild in self:Iterator() do
		if(inRealm:Equals(guild:GetRealm()) and guild:Name() == inGuildName) then
			return guild
		end
	end
end

function GuildCollection:GetByName(inGuildName)
	return self.names[inGuildName]
end

function GuildCollection:GetInfo()
	return self.info.description
end
--#endregion

--#region DataSet
function GuildCollection:SetObjectFromString(inString)
	assert(type(inString) == 'string')

	local realmNumber, factionID, guildName, guildInitials = inString:match('XFg:(.-):(.-):(.-):(.+)')
	local realm = XF.Realms:GetByID(tonumber(realmNumber))
	local faction = XFO.Factions:Get(factionID)

	local guild = Guild:new()
	guild:Initialize()
	guild:Key(guildInitials)
	guild:Name(guildName)
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
		xfData = XF.Lib.Deflate:DecompressDeflate(XF.Lib.Deflate:DecodeForPrint(compressed))
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
			XF.Cache.Confederate.Name = name
			XF.Cache.Confederate.Key = initials
		-- Guild within the confederate
		elseif(string.find(line, 'XFg')) then
			self:SetObjectFromString(line)
		-- Local channel for same realm/faction communication
		elseif(string.find(line, 'XFc')) then
			XF.Cache.Channel.Name, XF.Cache.Channel.Password = line:match('XFc:(.-):(.*)')
		elseif(string.find(line, 'XFt')) then
			XF.Teams:SetObjectFromString(line)
		end
	end		
end

function GuildCollection:SetPlayerGuild()
	for _, guild in self:Iterator() do
		if(guild:Name() == self.info.name and XF.Player.Realm:Equals(guild:GetRealm())) then
			guild:ID(self.info.clubId)
			for _, stream in pairs (C_Club.GetStreams(guild:ID())) do
				if(stream.streamType == 1) then
					guild:SetStreamID(stream.streamId)
					break
				end
			end
			XF.Player.Guild = guild
			break
		end
	end
	if(XF.Player.Guild == nil) then		
		error('Player is not on a supported guild or realm')
	end
end
--#endregion