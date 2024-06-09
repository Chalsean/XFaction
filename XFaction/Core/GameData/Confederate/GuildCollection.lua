local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'GuildCollection'

XFC.GuildCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.GuildCollection:new()
    local object = XFC.GuildCollection.parent.new(self)
	object.__name = ObjectName
	object.names = nil
	object.info = nil
    return object
end

function XFC.GuildCollection:Initialize(inGuildID)
	assert(type(inGuildID) == 'number')
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self.names = {}
		self.info = XFF.GuildGetInfo(inGuildID)
		self:Deserialize()
		self:IsInitialized(true)
	end
end
--#endregion

--#region Methods
function XFC.GuildCollection:ContainsName(inGuildName)
	return self.names[inGuildName] ~= nil
end

function XFC.GuildCollection:Add(inGuild)
    assert(type(inGuild) == 'table' and inGuild.__name == 'Guild', 'argument must be Guild object')
	self.parent.Add(self, inGuild)
	self.names[inGuild:Name()] = inGuild
	inGuild:Realm():GuildCount(inGuild:Realm():GuildCount() + 1)
end

function XFC.GuildCollection:Get(inGuildName, inRealm)
	assert(type(inGuildName) == 'string')
	assert(type(inRealm) == 'table' and inRealm.__name == 'realm' or inRealm == nil, 'argument must be Realm object or nil')
	-- Search by guild name & realm
	if(inRealm ~= nil) then
		for _, guild in self:Iterator() do
			if(inRealm:Equals(guild:Realm()) and guild:Name() == inGuildName) then
				return guild
			end
		end
	elseif(self.names[inGuildName] ~= nil) then
		return self.names[inGuildName]
	end
	
	return self.parent.Get(self, inGuildName)
end

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
			local guild = XFC.Guild:new()
			guild:Deserialize(line)
			self:Add(guild)
		-- Local channel for same realm/faction communication
		elseif(string.find(line, 'XFc')) then
			XF.Cache.Channel.Name, XF.Cache.Channel.Password = line:match('XFc:(.-):(.*)')
		elseif(string.find(line, 'XFt')) then
			XFO.Teams:Deserialize(line)
		end
	end		
end

function XFC.GuildCollection:SetPlayerGuild()
	for _, guild in self:Iterator() do
		if(guild:Name() == self.info.name and XF.Player.Realm:Equals(guild:Realm())) then
			for _, stream in pairs (XFF.GuildGetStreams(guild:ID(self.info.clubId))) do
				if(stream.streamType == 1) then
					guild:StreamID(stream.streamId)
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