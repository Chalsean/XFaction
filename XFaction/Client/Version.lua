local XFG, G = unpack(select(2, ...))
local ObjectName = 'Version'
local Split = string.Split

Version = Object:newChildConstructor()

function Version:new()
    local object = Version.parent.new(self)
    object.__name = ObjectName
    object.major = nil
    object.minor = nil
    object.patch = nil
    return object
end

function Version:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  major (' .. type(self.major) .. '): ' .. tostring(self.major))
        XFG:Debug(ObjectName, '  minor (' .. type(self.minor) .. '): ' .. tostring(self.minor))
        XFG:Debug(ObjectName, '  patch (' .. type(self.patch) .. '): ' .. tostring(self.patch))
    end
end

function Version:SetKey(inKey)
    assert(type(inKey) == 'string')
    self.key = inKey

    local parts = Split(inKey, '.')
    self:SetMajor(tonumber(parts[1]))
    self:SetMinor(tonumber(parts[2]))
    self:SetPatch(tonumber(parts[3]))
end

function Version:GetMajor()
    return self.major
end

function Version:SetMajor(inMajor)
    assert(type(inMajor) == 'number')
    self.major = inMajor
end

function Version:GetMinor()
    return self.minor
end

function Version:SetMinor(inMinor)
    assert(type(inMinor) == 'number')
    self.minor = inMinor
end

function Version:GetPatch()
    return self.patch
end

function Version:SetPatch(inPatch)
    assert(type(inPatch) == 'number')
    self.patch = inPatch
end

function Version:IsNewer(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name == ObjectName, 'argument must be Version object')
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