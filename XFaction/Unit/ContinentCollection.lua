local XFG, G = unpack(select(2, ...))
local ObjectName = 'ContinentCollection'
local LogCategory = 'UCContinent'

ContinentCollection = {}

function ContinentCollection:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

	self._Key = nil
    self._Continents = {}
	self._ContinentCount = 0
	self._Initialized = false

    return Object
end

function ContinentCollection:Initialize()
	if(not self:IsInitialized()) then
		self:SetKey(math.GenerateUID())
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function ContinentCollection:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function ContinentCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. ' Object')
	XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
	XFG:Debug(LogCategory, '  _ContinentCount (' .. type(self._ContinentCount) .. '): ' .. tostring(self._ContinentCount))
	XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
	for _, _Continent in self:Iterator() do
		_Continent:Print()
	end
end

function ContinentCollection:GetKey()
    return self._Key
end

function ContinentCollection:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function ContinentCollection:Contains(inKey)
	assert(type(inKey) == 'string')
    return self._Continents[inKey] ~= nil
end

function ContinentCollection:GetContinent(inKey)
	assert(type(inKey) == 'string')
    return self._Continents[inKey]
end

function ContinentCollection:GetContinentByID(inID)
	assert(type(inID) == 'number')
	for _, _Continent in self:Iterator() do
		if(_Continent:HasID(inID)) then
			return _Continent
		end
	end
end

function ContinentCollection:AddContinent(inContinent)
    assert(type(inContinent) == 'table' and inContinent.__name ~= nil and inContinent.__name == 'Continent', 'argument must be Continent object')
	if(not self:Contains(inContinent:GetKey())) then
		self._ContinentCount = self._ContinentCount + 1
	end		
	self._Continents[inContinent:GetKey()] = inContinent
	return self:Contains(inContinent:GetKey())
end

function ContinentCollection:Iterator()
	return next, self._Continents, nil
end