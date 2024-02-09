local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Version'
local Split = string.Split

XFC.Version = Object:newChildConstructor()

--#region Constructors
function XFC.Version:new()
    local object = XFC.Version.parent.new(self)
    object.__name = ObjectName
    object.major = nil
    object.minor = nil
    object.patch = nil
    object.changeLog = false
    return object
end
--#endregion

--#region Print
function XFC.Version:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  major (' .. type(self.major) .. '): ' .. tostring(self.major))
    XF:Debug(ObjectName, '  minor (' .. type(self.minor) .. '): ' .. tostring(self.minor))
    XF:Debug(ObjectName, '  patch (' .. type(self.patch) .. '): ' .. tostring(self.patch))
    XF:Debug(ObjectName, '  changeLog (' .. type(self.changeLog) .. '): ' .. tostring(self.changeLog))
end
--#endregion

--#region Accessors
function XFC.Version:SetKey(inKey)
    assert(type(inKey) == 'string')
    self.key = inKey

    local parts = Split(inKey, '.')
    self:SetMajor(tonumber(parts[1]))
    self:SetMinor(tonumber(parts[2]))
    if(#parts == 3) then
        self:SetPatch(tonumber(parts[3]))
    else
        self:SetPatch(0)
    end
end

function XFC.Version:GetMajor()
    return self.major
end

function XFC.Version:SetMajor(inMajor)
    assert(type(inMajor) == 'number')
    self.major = inMajor
end

function XFC.Version:GetMinor()
    return self.minor
end

function XFC.Version:SetMinor(inMinor)
    assert(type(inMinor) == 'number')
    self.minor = inMinor
end

function XFC.Version:GetPatch()
    return self.patch
end

function XFC.Version:SetPatch(inPatch)
    assert(type(inPatch) == 'number')
    self.patch = inPatch
end

function XFC.Version:IsAlpha()
    return self:GetPatch() == 0
end

function XFC.Version:IsBeta()
    return self:GetPatch() % 2 == 1
end

function XFC.Version:IsProduction()
    return not self:IsAlpha() and not self:IsBeta()
end

function XFC.Version:IsNewer(inVersion, inIncludeAllBuilds)
    assert(type(inVersion) == 'table' and inVersion.__name == ObjectName, 'argument must be Version object')
    if(not inIncludeAllBuilds and (inVersion:IsAlpha() or inVersion:IsBeta())) then
        return false
    end
    if(self:GetMajor() < inVersion:GetMajor() or 
      (self:GetMajor() == inVersion:GetMajor() and self:GetMinor() < inVersion:GetMinor()) or
      (self:GetMajor() == inVersion:GetMajor() and self:GetMinor() == inVersion:GetMinor() and self:GetPatch() < inVersion:GetPatch())) then
        return true
    end
    return false
end

function XFC.Version:IsInChangeLog(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self.changeLog = inBoolean
    end
    return self.changeLog
end
--#endregion

--#region Operators
function XFC.Version:Copy(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name == ObjectName, 'argument must be Version object')
    self:SetMajor(inVersion:GetMajor())
    self:SetMinor(inVersion:GetMinor())
    self:SetPatch(inVersion:GetPatch())
end
--#endregion