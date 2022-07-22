local XFG, G = unpack(select(2, ...))
local ObjectName = 'Race'
local LogCategory = 'URace'

Race = {}

function Race:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Name = nil
	self._ID = nil
    self._Faction = nil

    return Object
end

function Race:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. ' Object')
    XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
    XFG:Debug(LogCategory, '  _ID (' .. type(self._ID) .. '): ' .. tostring(self._ID))
    XFG:Debug(LogCategory, '  _Name (' .. type(self._Name) .. '): ' .. tostring(self._Name))
    if(self:HasFaction()) then
        self._Faction:Print()
    end
end

function Race:GetKey()
    return self._Key
end

function Race:SetKey(inKey)
    assert(type(inKey) == 'number')
    self._Key = inKey
    return self:GetKey()
end

function Race:GetName()
    return self._Name
end

function Race:SetName(_Name)
    assert(type(_Name) == 'string')
    self._Name = _Name
    return self:GetName()
end

function Race:GetID()
    return self._ID
end

function Race:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
    return self:GetID()
end

function Race:HasFaction()
    return self._Faction ~= nil
end

function Race:GetFaction()
    return self._Faction
end

function Race:SetFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name ~= nil and inFaction.__name == 'Faction', 'argument must be Faction object')
    self._Faction = inFaction
    return self:GetFaction()
end

function Race:Equals(inRace)
    if(inRace == nil) then return false end
    if(type(inRace) ~= 'table' or inRace.__name == nil or inRace.__name ~= 'Race') then return false end
    if(self:GetKey() ~= inRace:GetKey()) then return false end
    return true
end