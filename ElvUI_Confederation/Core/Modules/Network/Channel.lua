local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Channel'
local LogCategory = 'NChannel'

Channel = {}

function Channel:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(typeof == 'table') then
        Object = inObject
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject == true) then
        self._Key = nil
        self._ID = nil
        self._Name = nil
        self._ShortName = nil
        self._Type = nil
    end

    return Object
end

function Channel:Print()
    CON:SingleLine(LogCategory)
    CON:Debug(LogCategory, ObjectName .. " Object")
    CON:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    CON:Debug(LogCategory, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
    CON:Debug(LogCategory, "  _Name (" ..type(self._Name) .. "): ".. tostring(self._Name))
    CON:Debug(LogCategory, "  _ShortName (" ..type(self._ShortName) .. "): ".. tostring(self._ShortName))
    CON:Debug(LogCategory, "  _Type (" ..type(self._Type) .. "): ".. tostring(self._Type))
end

function Channel:GetKey()
    return self._Key
end

function Channel:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Channel:GetName()
    return self._Name
end

function Channel:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Channel:GetShortName()
    return self._Name
end

function Channel:SetShortName(inShortName)
    assert(type(inShortName) == 'string')
    self._ShortName = inShortName
    return self:GetShortName()
end

function Channel:GetID()
    return self._ID
end

function Channel:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
    return self:GetID()
end

function Channel:SetType(inType)
    assert(type(inType) == 'number')
    self._Type = inType
    return true
end

function Channel:IsSystem()
    return self._Type == 1
end

function Channel:IsCommunity()
    return self._Type == 2
end

function Channel:IsCustom()
    return self._Type == 3
end

function Channel:IsAddonChannel(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._IsAddonChannel = inBoolean
    end
    return self._IsAddonChannel
end