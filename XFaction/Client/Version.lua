local XFG, G = unpack(select(2, ...))
local LogDebug = XFG.Debug
local ObjectName = 'Version'

Version = Object:newChildConstructor()

function Version:new()
    local _Object = Version.parent.new(self)
    _Object.__name = ObjectName
    _Object._Major = nil
    _Object._Minor = nil
    _Object._Patch = nil
    return _Object
end

function Version:Print()
    self:ParentPrint()
    LogDebug(ObjectName, '  _Major (' .. type(self._Major) .. '): ' .. tostring(self._Major))
    LogDebug(ObjectName, '  _Minor (' .. type(self._Minor) .. '): ' .. tostring(self._Minor))
    LogDebug(ObjectName, '  _Patch (' .. type(self._Patch) .. '): ' .. tostring(self._Patch))
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
    assert(type(inVersion) == 'table' and inVersion.__name ~= nil and inVersion.__name == ObjectName, 'Wrong object type')
    -- Do not consider alpha/beta builds as newer
    if(inVersion:GetPatch() == 0 or inVersion:GetPatch() % 2 == 1) then
        return false
    end
    if(self:GetMajor() < inVersion:GetMajor() or 
      (self:GetMajor() == inVersion:GetMajor() and self:GetMinor() < inVersion:GetMinor()) or
      (self:GetMajor() == inVersion:GetMajor() and self:GetMinor() == inVersion:GetMinor() and self:GetPatch() < inVersion:GetPatch())) then
        return true
    end
    return false
end
