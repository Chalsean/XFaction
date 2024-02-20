local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'GuildCollection'
local GetClubInfo = C_Club.GetClubInfo
local GetStreams = C_Club.GetStreams

XFC.GuildCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.GuildCollection:new()
    local object = XFC.GuildCollection.parent.new(self)
	object.__name = ObjectName
	object.names = nil
	object.cached = false
	object.info = nil
    return object
end
--#endregion

--#region Initializers
function XFC.GuildCollection:Initialize(inGuildID)
	assert(type(inGuildID) == 'number')
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self.names = {}
		self.info = GetClubInfo(inGuildID)
		self:SetFromGuildInfo()
		self:IsInitialized(true)
	end
end
--#endregion

--#region Hash
function XFC.GuildCollection:ContainsName(inGuildName)
	return self.names[inGuildName] ~= nil
end

function XFC.GuildCollection:Add(inGuild)
    assert(type(inGuild) == 'table' and inGuild.__name == 'Guild', 'argument must be Guild object')
	self.parent.Add(self, inGuild)
	self.names[inGuild:GetName()] = inGuild
	XF:Info(self:GetObjectName(), 'Initialized guild [%s:%s]', inGuild:GetInitials(), inGuild:GetName())
end
--#endregion

--#region Accessors
function XFC.GuildCollection:GetByRealmGuildName(inRealm, inGuildName)
	assert(type(inRealm) == 'table' and inRealm.__name == 'Realm', 'argument must be a Realm object')	
	assert(type(inGuildName) == 'string')
	for _, guild in self:Iterator() do
		if(inRealm:Equals(guild:GetRealm()) and guild:GetName() == inGuildName) then
			return guild
		end
	end
end

function XFC.GuildCollection:GetByName(inGuildName)
	return self.names[inGuildName]
end

function XFC.GuildCollection:GetInfo()
	return self.info.description
end
--#endregion

--#region Serialize
function XFC.GuildCollection:Deserialize()
	-- Parse out configuration from guild information so GMs have control
	local xfData = ''
	local compressed = string.match(self.info.description, 'XF:(.-):XF')
	if (compressed ~= nil) then
		xfData = XF.Lib.Deflate:DecompressDeflate(XF.Lib.Deflate:DecodeForPrint(compressed))
	else
		xfData = self.info.description
	end

	if(not string.len(xfData)) then
		throw('Failed to find setup in guild information')
	end

	for _, line in ipairs(string.Split(xfData, '\n')) do
		-- Confederate information
		if(string.find(line, 'XFn')) then                    
			local name, initials = line:match('XFn:(.-):(.+)')
			XF.Cache.Confederate.Name = name
			XF.Cache.Confederate.Key = initials
		-- Guild within the confederate
		elseif(string.find(line, 'XFg')) then
			local guild = XFC.Guild:new()
			guild:Deserialize(line)
			self:Add(guild)
		-- Local channel for same realm/faction communication
		elseif(string.find(line, 'XFc')) then
			XF.Cache.Channel.Name, XF.Cache.Channel.Password = line:match('XFc:(.-):(.*)')
		elseif(string.find(line, 'XFt')) then
			local team = XFC.Team:new()
			team:Deserialize(line)
			XFO.Teams:Add(team)
		end
	end		
end

function XFC.GuildCollection:SetPlayerGuild()
	for _, guild in self:Iterator() do
		if(guild:GetName() == self.info.name and XF.Player.Realm:Equals(guild:GetRealm())) then
			guild:SetID(self.info.clubId)
			for _, stream in pairs (GetStreams(guild:GetID())) do
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
		throw('Player is not on a supported guild or realm')
	end
end
--#endregion