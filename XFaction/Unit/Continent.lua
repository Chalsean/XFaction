local XFG, G = unpack(select(2, ...))
local ObjectName = 'Continent'
local LogCategory = 'UContinent'

Continent = {}

function Continent:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._IDs = nil
	self._Name = nil
    self._LocaleName = nil

    return Object
end

function Continent:Initialize()
	if(not self:IsInitialized()) then
		self._IDs = {}
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function Continent:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function Continent:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. ' Object')
    XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
    XFG:Debug(LogCategory, '  _Name (' ..type(self._Name) .. '): ' .. tostring(self._Name))
    XFG:Debug(LogCategory, '  _LocaleName (' .. type(self._LocaleName) .. '): ' .. tostring(self._LocaleName))
    XFG:Debug(LogCategory, '  IDs: ')
    XFG:DataDumper(LogCategory, self._IDs)
end

function Continent:GetKey()
    return self._Key
end

function Continent:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Continent:HasID(inID)
    assert(type(inID) == 'number')
    for _, _ID in ipairs(self._IDs) do
        if(_ID == inID) then
            return true
        end
    end
    return false
end

function Continent:GetID()
    if(#self._IDs > 0) then
        return self._IDs[1]
    end
    return nil
end

function Continent:AddID(inID)
    assert(type(inID) == 'number')
    table.insert(self._IDs, inID)
    return self:GetID()
end

function Continent:GetName()
    return self._Name
end

function Continent:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Continent:GetLocaleName()
    return self._LocaleName or self:GetName()
end

function Continent:SetLocaleName(inName)
    assert(type(inName) == 'string')
    self._LocaleName = inName
    return self:GetLocaleName()
end

function Continent:Equals(inContinent)
    if(inContinent == nil) then return false end
    if(type(inContinent) ~= 'table' or inContinent.__name == nil or inContinent.__name ~= 'Continent') then return false end
    if(self:GetKey() ~= inContinent:GetKey()) then return false end
    return true
end