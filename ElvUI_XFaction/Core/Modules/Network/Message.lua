local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Message'
local LogCategory = 'NMessage'

Message = {}

function Message:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName
    
    self._Key = nil
    self._To = nil
    self._From = nil
    self._Type = nil
    self._GuildID = nil
    self._Subject = nil
    self._EpochTime = nil
    self._Targets = {}
    self._TargetCount = 0
    self._Data = nil
    self._Initialized = false

    return _Object
end

function Message:newChildConstructor()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName
    self.parent = self
    
    self._Key = nil
    self._To = nil
    self._From = nil    
    self._Type = nil
    self._GuildID = nil
    self._Subject = nil
    self._EpochTime = nil
    self._Targets = {}
    self._TargetCount = 0
    self._Data = nil
    self._Initialized = false

    return _Object
end

function Message:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function Message:Initialize()
    if(self:IsInitialized() == false) then
        self:SetKey(math.GenerateUID())
        self:SetFrom(XFG.Player.Unit:GetKey())
        self:SetGuildID(XFG.Player.Guild:GetID())
        self:SetTimeStamp(GetServerTime())
        self:SetAllTargets()
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Message:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _To (" .. type(self._To) .. "): ".. tostring(self._To))
    XFG:Debug(LogCategory, "  _From (" ..type(self._From) .. "): ".. tostring(self._From))
    XFG:Debug(LogCategory, "  _GuildID (" ..type(self._GuildID) .. "): ".. tostring(self._GuildID))
    XFG:Debug(LogCategory, "  _Type (" ..type(self._Type) .. "): ".. tostring(self._Type))
    XFG:Debug(LogCategory, "  _Subject (" ..type(self._Subject) .. "): ".. tostring(self._Subject))
    XFG:Debug(LogCategory, "  _EpochTime (" ..type(self._EpochTime) .. "): ".. tostring(self._EpochTime))
    XFG:Debug(LogCategory, "  _Data (" ..type(self._Data) .. ")")
    XFG:Debug(LogCategory, "  _Initialized (" ..type(self._Initialized) .. "): ".. tostring(self._Initialized))
    XFG:Debug(LogCategory, "  _TargetCount (" ..type(self._TargetCount) .. "): ".. tostring(self._TargetCount))
    for _, _Target in self:TargetIterator() do
        _Target:Print()
    end
end

function Message:ShallowPrint()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _To (" .. type(self._To) .. "): ".. tostring(self._To))
    XFG:Debug(LogCategory, "  _From (" ..type(self._From) .. "): ".. tostring(self._From))
    XFG:Debug(LogCategory, "  _GuildID (" ..type(self._GuildID) .. "): ".. tostring(self._GuildID))
    XFG:Debug(LogCategory, "  _Type (" ..type(self._Type) .. "): ".. tostring(self._Type))
    XFG:Debug(LogCategory, "  _Subject (" ..type(self._Subject) .. "): ".. tostring(self._Subject))
    XFG:Debug(LogCategory, "  _EpochTime (" ..type(self._EpochTime) .. "): ".. tostring(self._EpochTime))
    XFG:Debug(LogCategory, "  _Data (" ..type(self._Data) .. ")")
    XFG:Debug(LogCategory, "  _Initialized (" ..type(self._Initialized) .. "): ".. tostring(self._Initialized))
    XFG:Debug(LogCategory, "  _TargetCount (" ..type(self._TargetCount) .. "): ".. tostring(self._TargetCount))
end

function Message:GetKey()
    return self._Key
end

function Message:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Message:GetTo()
    return self._To
end

function Message:SetTo(inTo)
    assert(type(inTo) == 'string')
    self._To = inTo
    return self:GetTo()
end

function Message:GetFrom()
    return self._From
end

function Message:SetFrom(inFrom)
    assert(type(inFrom) == 'string')
    self._From = inFrom
    return self:GetFrom()
end

function Message:GetGuildID()
    return self._GuildID
end

function Message:SetGuildID(inGuildID)
    assert(type(inGuildID) == 'number')
    self._GuildID = inGuildID
    return self:GetGuildID()
end

function Message:GetType()
    return self._Type
end

function Message:SetType(inType)
    assert(type(inType) == 'string')
    self._Type = inType
    return self:GetType()
end

function Message:GetSubject()
    return self._Subject
end

function Message:SetSubject(inSubject)
    assert(type(inSubject) == 'string')
    self._Subject = inSubject
    return self:GetSubject()
end

function Message:GetTimeStamp()
    return self._EpochTime
end

function Message:SetTimeStamp(inEpochTime)
    assert(type(inEpochTime) == 'number')
    self._EpochTime = inEpochTime
    return self:GetTimeStamp()
end

function Message:GetData()
    return self._Data
end

function Message:SetData(inData)
    self._Data = inData
    return self:GetData()
end

function Message:ContainsTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name ~= nil and inTarget.__name == 'Target', "argument must be Target object")
    return self._Targets[inTarget:GetKey()] ~= nil
end

function Message:AddTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name ~= nil and inTarget.__name == 'Target', "argument must be Target object")
    if(self:ContainsTarget(inTarget) == false) then
        self._TargetCount = self._TargetCount + 1
    end
    self._Targets[inTarget:GetKey()] = inTarget
    return self:ContainsTarget(inTarget)
end

function Message:RemoveTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name ~= nil and inTarget.__name == 'Target', "argument must be Target object")
    if(self:ContainsTarget(inTarget)) then
        table.RemoveKey(self._Targets, inTarget:GetKey())
        self._TargetCount = self._TargetCount - 1
    end
    return self:ContainsTarget(inTarget) == false
end

function Message:SetAllTargets()
    for _, _Target in XFG.Network.BNet.Targets:Iterator() do
        self:AddTarget(_Target)
    end
end

function Message:HasTargets()
    return self._TargetCount > 0
end

function Message:TargetIterator()
    return next, self._Targets, nil
end

function Message:GetRemainingTargets()
    local _TargetsString = ''
    for _, _Target in self:TargetIterator() do
        _TargetsString = _TargetsString .. '|' .. _Target:GetKey()
    end
    return _TargetsString
end

function Message:SetRemainingTargets(inTargetString)
    wipe(self._Targets)
    self._TargetCount = 0
    local _Targets = string.Split(inTargetString, '|')
    for _, _TargetKey in pairs (_Targets) do
        if(_TargetKey ~= nil and XFG.Network.BNet.Targets:ContainsByKey(_TargetKey)) then
            self:AddTarget(XFG.Network.BNet.Targets:GetTargetByKey(_TargetKey))
        end
    end
end