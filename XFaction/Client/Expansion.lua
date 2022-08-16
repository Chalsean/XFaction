local XFG, G = unpack(select(2, ...))
local LogDebug = XFG.Debug
local ObjectName = 'Expansion'

Expansion = Object:newChildConstructor()

function Expansion:new()
    local _Object = Expansion.parent.new(self)
    _Object.__name = ObjectName
    _Object._ID = nil
    _Object._IconID = nil
    _Object._Version = nil
    return _Object
end

function Expansion:Print()
    self:ParentPrint()
    LogDebug(ObjectName, '  _ID (' .. type(self._ID) .. '): ' .. tostring(self._ID))
    LogDebug(ObjectName, '  _IconID (' .. type(self._IconID) .. '): ' .. tostring(self._IconID))
    if(self:HasVersion()) then self:GetVersion():Print() end
end

function Expansion:GetID()
    return self._ID
end

function Expansion:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
    return self:GetID()
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
