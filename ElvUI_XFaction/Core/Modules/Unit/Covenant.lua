local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Covenant'
local LogCategory = 'UCovenant'

Covenant = {}

function Covenant:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or 
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(typeof == 'table') then
        Object = inObject
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject == true) then
        self._Key = nil
        self._ID = 0
        self._Name = nil
        self._SoulbindIDs = {}
        self._IconID = nil
        self._Initialized = false
    end

    return Object
end

function Covenant:Initialize()
    if(self._Initialized == false) then
        local _CovenantInfo = C_Covenants.GetCovenantData(self._ID)
        self._Key = _CovenantInfo.ID
        self._ID = _CovenantInfo.ID
        self._Name = _CovenantInfo.name
        self._SoulbindIDs = _CovenantInfo.soulbindIDs
        if(self:GetName() == 'Kyrian') then
            self:SetIconID(3257748)
        elseif(self:GetName() == 'Venthyr') then
            self:SetIconID(3257751)
        elseif(self:GetName() == 'Night Fae') then
            self:SetIconID(3257750)
        elseif(self:GetName() == 'Necrolord') then
            self:SetIconID(3257749)
        end
        self._Initialized = true
    end
end

function Covenant:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
    XFG:Debug(LogCategory, "  _Name (" ..type(self._Name) .. "): ".. tostring(self._Name))
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): " .. tostring(self._Initialized))
    for _Index, _SoulbindID in PairsByKeys (self._SoulbindIDs) do
        XFG:Debug(LogCategory, "  _SoulbindID[" .. tostring(_Index) .. "] (" ..type(_SoulbindID) .. "): ".. tostring(_SoulbindID))
    end
end

function Covenant:GetKey()
    return self._Key
end

function Covenant:SetKey(inKey)
    assert(type(inKey) == 'number')
    self._Key = inKey
    return self:GetKey()
end

function Covenant:GetName()
    return self._Name
end

function Covenant:SetName(inName)
    assert(type(_Name) == 'string')
    self._Name = inName
    return self:GetName()
end

function Covenant:GetID()
    return self._ID
end

function Covenant:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
    return self:GetID()
end

function Covenant:GetIconID()
    return self._IconID
end

function Covenant:SetIconID(inIconID)
    assert(type(inIconID) == 'number')
    self._IconID = inIconID
    return self:GetIconID()
end

function Covenant:GetSoulbindIDs()
    return self._SoulbindIDs
end

function Covenant:Equals(inCovenant)
    if(inCovenant == nil) then return false end
    if(type(inCovenant) ~= 'table' or inCovenant.__name == nil or inCovenant.__name ~= 'Covenant') then return false end
    if(self:GetKey() ~= inCovenant:GetKey()) then return false end
    return true
end