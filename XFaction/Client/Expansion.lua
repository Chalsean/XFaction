local XFG, G = unpack(select(2, ...))
local ObjectName = 'Expansion'
local LogCategory = 'CExpansion'

Expansion = {}

function Expansion:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._ID = nil
    self._Name = nil
    self._IconID = nil
    self._Version = nil
    
    return Object
end

function Expansion:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. ' Object')
    XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
    XFG:Debug(LogCategory, '  _ID (' .. type(self._ID) .. '): ' .. tostring(self._ID))
    XFG:Debug(LogCategory, '  _Name (' .. type(self._Name) .. '): ' .. tostring(self._Name))
    XFG:Debug(LogCategory, '  _IconID (' .. type(self._IconID) .. '): ' .. tostring(self._IconID))
    if(self:HasVersion()) then self:GetVersion():Print() end
end

function Expansion:GetKey()
    return self._Key
end

function Expansion:SetKey(inKey)
    assert(type(inKey) == 'number')
    self._Key = inKey
    return self:GetKey()
end

function Expansion:GetID()
    return self._ID
end

function Expansion:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
    return self:GetID()
end

function Expansion:GetName()
    return self._Name
end

function Expansion:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Expansion:GetIconID()
    return self._IconID
end

function Expansion:SetIconID(inIconID)
    assert(type(inIconID) == 'number')
    self._IconID = inIconID
    return self:GetIconID()
end

function Expansion:IsRetail()
    return WOW_PROJECT_MAINLINE == self:GetID()
end

function Expansion:HasVersion()
	return self._Version ~= nil
end

function Expansion:SetVersion(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name ~= nil and inVersion.__name == 'Version', 'argument must be Version object')
	self._Version = inVersion
	return self:GetVersion()
end

function Expansion:GetVersion()
	return self._Version
end