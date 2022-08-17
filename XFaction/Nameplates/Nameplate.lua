local XFG, G = unpack(select(2, ...))
local ObjectName = 'Nameplate'
local LogCategory = 'NPNameplate'

Nameplate = {}

function Nameplate:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName
    
    self._Key = nil
    self._Initialized = false

    return _Object
end

function Nameplate:newChildConstructor()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName
    self.parent = self
    
    self._Key = nil
    self._Initialized = false

    return _Object
end

function Nameplate:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function Nameplate:Initialize()
    if(not self:IsInitialized()) then
        self:SetKey(math.GenerateUID())
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Nameplate:Print()
    XFG:SingleLine(LogCategory)
    XFG.DebugFlag(LogCategory, ObjectName .. " Object")
    XFG.DebugFlag(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG.DebugFlag(LogCategory, "  _Initialized (" ..type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function Nameplate:GetKey()
    return self._Key
end

function Nameplate:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end