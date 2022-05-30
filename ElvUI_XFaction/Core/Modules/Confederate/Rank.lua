local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Rank'
local LogCategory = 'CRank'

Rank = {}

function Rank:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or 
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil, string or " .. ObjectName .. " object")

    if(_typeof == 'table') then
        Object = inObject
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject) then
        self._Key = nil
        self._Name = nil
        self._AltName = nil
        self._ID = nil
    end

    return Object
end

function Rank:Print()
	XFG:SingleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
	XFG:Debug(LogCategory, "  _Name (" .. type(self._Name) .. "): ".. tostring(self._Name))
	XFG:Debug(LogCategory, "  _AltName (" .. type(self._AltName) .. "): ".. tostring(self._AltName))
    XFG:Debug(LogCategory, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
end

function Rank:GetKey()
    return self._Key
end

function Rank:SetKey(inKey)
    assert(type(inKey) == 'number')
    self._Key = inKey
    return self:GetKey()
end

function Rank:GetName()
    return self._Name
end

function Rank:SetName(_Name)
    assert(type(_Name) == 'string')
    self._Name = _Name
    return self:GetName()
end

function Rank:GetID()
    return self._ID
end

function Rank:SetID(_ID)
    assert(type(_ID) == 'number')
    self._ID = _ID
    return self:GetID()
end

function Rank:HasAltName()
    return self._AltName ~= nil
end

function Rank:GetAltName()
    return self._AltName
end

function Rank:SetAltName(_AltName)
    assert(type(_AltName) == 'string')
    self._AltName = _AltName
    return self:GetAltName()
end

function Rank:Equals(inRank)
    if(inRank == nil) then return false end
    if(type(inRank) ~= 'table' or inRank.__name == nil or inRank.__name ~= 'Rank') then return false end
    if(self:GetKey() ~= inRank:GetKey()) then return false end
    return true
end