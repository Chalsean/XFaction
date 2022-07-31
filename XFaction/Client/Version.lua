local XFG, G = unpack(select(2, ...))
local ObjectName = 'Version'
local LogCategory = 'CVersion'

Version = {}

function Version:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Major = nil
    self._Minor = nil
    self._Patch = nil
    
    return Object
end

function Version:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. ' Object')
    XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
    XFG:Debug(LogCategory, '  _Major (' .. type(self._Major) .. '): ' .. tostring(self._Major))
    XFG:Debug(LogCategory, '  _Minor (' .. type(self._Minor) .. '): ' .. tostring(self._Minor))
    XFG:Debug(LogCategory, '  _Patch (' .. type(self._Patch) .. '): ' .. tostring(self._Patch))
end

function Version:GetKey()
    return self._Key
end

function Version:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey

    local _Parts = string.Split(inKey, '.')
    self:SetMajor(tonumber(_Parts[1]))
    self:SetMinor(tonumber(_Parts[2]))
    self:SetPatch(tonumber(_Parts[3]))

    return self:GetKey()
end

function Version:GetMajor()
    return self._Major
end

function Version:SetMajor(inMajor)
    assert(type(inMajor) == 'number')
    self._Major = inMajor
    return self:GetMajor()
end

function Version:GetMinor()
    return self._Minor
end

function Version:SetMinor(inMinor)
    assert(type(inMinor) == 'number')
    self._Minor = inMinor
    return self:GetMinor()
end

function Version:GetPatch()
    return self._Patch
end

function Version:SetPatch(inPatch)
    assert(type(inPatch) == 'number')
    self._Patch = inPatch
    return self:GetPatch()
end

function Version:IsNewer(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name ~= nil and inVersion.__name == 'Version', 'argument must be Version object')
    -- Do not consider alpha/beta builds as newer
    if(inVersion:GetPatch() == 0 or inVersion:GetPatch() % 2 == 1) then
        return false
    end
    if(self:GetMajor() < inVersion:GetMajor() or self:GetMinor() < inVersion:GetMinor()) then
        return true
    end
    return false
end