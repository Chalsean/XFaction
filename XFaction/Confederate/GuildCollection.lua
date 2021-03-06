local XFG, G = unpack(select(2, ...))
local ObjectName = 'GuildCollection'
local LogCategory = 'CCGuild'

GuildCollection = {}

function GuildCollection:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

	self._Key = nil
    self._Guilds = {}
	self._Initials = {}
	self._GuildCount = 0
	self._Initialized = false

    return Object
end

function GuildCollection:IsInitialized(inBoolean)
    assert(inInitialized == nil or type(inInitialized) == 'boolean', 'argument needs to be nil or boolean')
    if(inInitialized ~= nil) then
        self._Initialized = inInitialized
    end
	return self._Initialized
end

function GuildCollection:Initialize()
	if(self:IsInitialized() == false) then
        self:SetKey(math.GenerateUID())
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function GuildCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. ' Object')
	XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
	XFG:Debug(LogCategory, '  _GuildCount (' .. type(self._GuildCount) .. '): ' .. tostring(self._GuildCount))
	XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
	for _, _Guild in pairs (self._Guilds) do
		_Guild:Print()
	end
end

function GuildCollection:GetKey()
    return self._Key
end

function GuildCollection:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function GuildCollection:Contains(inKey)
	assert(type(inKey) == 'string')
	return self._Guilds[inKey] ~= nil
end

function GuildCollection:GetGuild(inKey)
	assert(type(inKey) == 'string')
	return self._Guilds[inKey]
end

function GuildCollection:GetGuildByRealmGuildName(inRealm, inGuildName)
	assert(type(inGuildName) == 'string' and type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', 'arguments must be a Realm object and a string')	
	for _, _Guild in self:Iterator() do
		if(inRealm:Equals(_Guild:GetRealm()) and _Guild:GetName() == inGuildName) then
			return _Guild
		end
	end
end

function GuildCollection:AddGuild(inGuild)
    assert(type(inGuild) == 'table' and inGuild.__name ~= nil and inGuild.__name == 'Guild', 'argument must be Guild object')
	if(self:Contains(inGuild:GetKey()) == false) then
		self._GuildCount = self._GuildCount + 1
	end
	self._Guilds[inGuild:GetKey()] = inGuild
	self._Initials[inGuild:GetInitials()] = true
	return self:Contains(inGuild:GetKey())
end

function GuildCollection:Iterator()
	return next, self._Guilds, nil
end

function GuildCollection:GetInitials()
	return self._Initials
end