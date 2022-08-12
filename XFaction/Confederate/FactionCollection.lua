local XFG, G = unpack(select(2, ...))
local ObjectName = 'FactionCollection'
local LogCategory = 'CCFaction'

FactionCollection = {}

function FactionCollection:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

	self._Key = nil
    self._Factions = {}
	self._FactionCount = 0
	self._Initialized = false
    
    return Object
end

function FactionCollection:Initialize()
	if(self:IsInitialized() == false) then
		self:SetKey(math.GenerateUID())
		local _Factions = {'Alliance', 'Horde', 'Neutral'}
		for i, _FactionName in pairs (_Factions) do
			XFG:Debug(LogCategory, 'Initializing faction [%s]', _FactionName)
			local _NewFaction = Faction:new()
			_NewFaction:SetKey(i)
			_NewFaction:SetName(_FactionName)
			_NewFaction:Initialize()
			self:AddFaction(_NewFaction)
		end
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function FactionCollection:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(type(inBoolean) == 'boolean') then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function FactionCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. ' Object')
	XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
	XFG:Debug(LogCategory, '  _FactionCount (' .. type(self._FactionCount) .. '): ' .. tostring(self._FactionCount))
	XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
	XFG:Debug(LogCategory, '  _Factions (' .. type(self._Factions) .. '): ')
	for _, _Faction in pairs (self._Factions) do
		_Faction:Print()
	end
end

function FactionCollection:GetKey()
    return self._Key
end

function FactionCollection:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function FactionCollection:Contains(inKey)
	assert(type(inKey) == 'number')
    return self._Factions[inKey] ~= nil
end

function FactionCollection:GetFaction(inKey)
	assert(type(inKey) == 'number')
    return self._Factions[inKey]
end

function FactionCollection:GetFactionByName(inName)
	assert(type(inName) == 'string')
	for _, _Faction in self:Iterator() do
		if(_Faction:GetName() == inName) then
			return _Faction
		end
	end
end

function FactionCollection:GetFactionByID(inID)
	assert(type(inID) == 'string')
	for _, _Faction in self:Iterator() do
		if(_Faction:GetID() == inID) then
			return _Faction
		end
	end
end

function FactionCollection:AddFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name ~= nil and inFaction.__name == 'Faction', 'argument must be Faction object')
	if(self:Contains(inFaction:GetKey()) == false) then
		self._FactionCount = self._FactionCount + 1
	end		
	self._Factions[inFaction:GetKey()] = inFaction
	return self:Contains(inFaction:GetKey())
end

function FactionCollection:Iterator()
	return next, self._Factions, nil
end