local XFG, G = unpack(select(2, ...))
local ObjectName = 'Zone'
local LogCategory = 'UZone'

Zone = {}

function Zone:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._IDs = nil
	self._Name = nil
    self._LocaleName = nil
    self._Continent = nil

    return Object
end

function Zone:Initialize()
	if(not self:IsInitialized()) then
		self._IDs = {}
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function Zone:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function Zone:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. ' Object')
    XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
    XFG:Debug(LogCategory, '  _Name (' ..type(self._Name) .. '): ' .. tostring(self._Name))
    XFG:Debug(LogCategory, '  _LocaleName (' .. type(self._LocaleName) .. '): ' .. tostring(self._LocaleName))
    XFG:Debug(LogCategory, '  IDs: ')
    XFG:DataDumper(LogCategory, self._IDs)
    if(self:HasContinent()) then self._Continent:Print() end
end

function Zone:GetKey()
    return self._Key
end

function Zone:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Zone:HasID()
    return #self._IDs > 0
end

function Zone:GetID()
    if(self:HasID()) then
        return self._IDs[1]
    end
end

function Zone:AddID(inID)
    assert(type(inID) == 'number')
    table.insert(self._IDs, inID)
    return self:GetID()
end

function Zone:GetName()
    return self._Name
end

function Zone:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Zone:GetLocaleName()
    return self._LocaleName or self:GetName()
end

function Zone:SetLocaleName(inName)
    assert(type(inName) == 'string')
    self._LocaleName = inName
    return self:GetLocaleName()
end

function Zone:Equals(inSpec)
    if(inSpec == nil) then return false end
    if(type(inSpec) ~= 'table' or inSpec.__name == nil or inSpec.__name ~= 'Spec') then return false end
    if(self:GetKey() ~= inSpec:GetKey()) then return false end
    return true
end

function Zone:HasContinent()
    return self._Continent ~= nil
end


function Zone:GetContinent()
    return self._Continent
end

function Zone:SetContinent(inContinent)
    assert(type(inContinent) == 'table' and inContinent.__name ~= nil and inContinent.__name == 'Continent', 'argument must be Continent object')
    self._Continent = inContinent
    return self:GetContinent()
end

function Zone:IDIterator()
	return next, self._IDs, nil
end