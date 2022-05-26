local EKX, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Faction'
local LogCategory = 'UFaction'

Faction = {}

function Faction:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or 
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil, string or " .. ObjectName .. " object")

    if(_typeof == 'table') then
        Object = inObject
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject) then
        self._Key = nil
        self._Name = nil
        self._IconID = nil
        self._Initialized = false
    end

    return Object
end

function Faction:Initialize()
    if(self:IsInitialized() == false) then        
        if(self._Name ~= nil) then
            if(self._Name == 'Horde') then
                self:SetIconID(463451)
            elseif(self._Name == 'Alliance') then
                self:SetIconID(2565243)
            else
                self:SetIconID(132311)
            end
        end
        self:IsInitialized(true)
    end
end

function Faction:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument needs to be nil or boolean")
    if(type(inBoolean) == 'boolean') then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function Faction:Print()
    EKX:SingleLine(LogCategory)
    EKX:Debug(LogCategory, ObjectName .. " Object")
    EKX:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    EKX:Debug(LogCategory, "  _Name (" .. type(self._Name) .. "): ".. tostring(self._Name))
    EKX:Debug(LogCategory, "  _IconID (" ..type(self._IconID) .. "): ".. tostring(self._IconID))
    EKX:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): " .. tostring(self._Initialized))
end

function Faction:GetKey()
    return self._Key
end

function Faction:SetKey(inKey)
    assert(type(inKey) == 'number')
    self._Key = inKey
    return self:GetKey()
end

function Faction:GetName()
    return self._Name
end

function Faction:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Faction:GetIconID()
    return self._IconID
end

function Faction:SetIconID(inIconID)
    assert(type(inIconID) == 'number')
    self._IconID = inIconID
    return self:GetIconID()
end

function Faction:Equals(inFaction)
    if(inFaction == nil) then return false end
    if(type(inFaction) ~= 'table' or inFaction.__name == nil or inFaction.__name ~= 'Faction') then return false end
    if(self:GetKey() ~= inFaction:GetKey()) then return false end
    return true
end