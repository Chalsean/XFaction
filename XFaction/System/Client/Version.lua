local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Version'
local Split = string.Split

XFC.Version = XFC.Object:newChildConstructor()

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
    XF:Debug(self:ObjectName(), '  major (' .. type(self.major) .. '): ' .. tostring(self.major))
    XF:Debug(self:ObjectName(), '  minor (' .. type(self.minor) .. '): ' .. tostring(self.minor))
    XF:Debug(self:ObjectName(), '  patch (' .. type(self.patch) .. '): ' .. tostring(self.patch))
    XF:Debug(self:ObjectName(), '  changeLog (' .. type(self.changeLog) .. '): ' .. tostring(self.changeLog))
end
--#endregion

--#region Properties
function XFC.Version:Key(inKey)
    assert(type(inKey) == 'string' or inKey == nil)
    if(inKey ~= nil) then
        self.key = inKey

        local parts = Split(inKey, '.')
        self:Major(tonumber(parts[1]))
        self:Minor(tonumber(parts[2]))
        if(#parts == 3) then
            self:Patch(tonumber(parts[3]))
        else
            self:Patch(0)
        end
    end
    return self.key
end

function XFC.Version:Major(inMajor)
    assert(type(inMajor) == 'number' or inMajor == nil)
    if(inMajor ~= nil) then
        self.major = inMajor
    end
    return self.major
end

function XFC.Version:Minor(inMinor)
    assert(type(inMinor) == 'number' or inMinor == nil)
    if(inMinor ~= nil) then
        self.minor = inMinor
    end
    return self.minor
end

function XFC.Version:Patch(inPatch)
    assert(type(inPatch) == 'number' or inPatch == nil)
    if(inPatch ~= nil) then
        self.patch = inPatch
    end
    return self.patch
end

function XFC.Version:IsAlpha()
    return self:Patch() == 0
end

function XFC.Version:IsBeta()
    return self:Patch() % 2 == 1
end

function XFC.Version:IsProduction()
    return not self:IsAlpha() and not self:IsBeta()
end

function XFC.Version:IsNewer(inVersion, inIncludeAllBuilds)
    assert(type(inVersion) == 'table' and inVersion.__name == self:ObjectName())
    if(not inIncludeAllBuilds and (inVersion:IsAlpha() or inVersion:IsBeta())) then
        return false
    end
    if(self:Major() < inVersion:Major() or 
      (self:Major() == inVersion:Major() and self:Minor() < inVersion:Minor()) or
      (self:Major() == inVersion:Major() and self:Minor() == inVersion:Minor() and self:Patch() < inVersion:Patch())) then
        return true
    end
    return false
end

function XFC.Version:IsInChangeLog(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean')
    if(inBoolean ~= nil) then
        self.changeLog = inBoolean
    end
    return self.changeLog
end
--#endregion

--#region Methods
function XFC.Version:Copy(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name == self:ObjectName())
    self:Major(inVersion:Major())
    self:Minor(inVersion:Minor())
    self:Patch(inVersion:Patch())
end
--#endregion