local XFG, G = unpack(select(2, ...))
local ObjectName = 'Covenant'
local LogCategory = 'UCovenant'

Covenant = {}

function Covenant:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._ID = 0
    self._Name = nil
    self._SoulbindIDs = {}
    self._IconID = nil
    self._Initialized = false

    return Object
end

function Covenant:Initialize()
    if(self:IsInitialized() == false) then
        local _CovenantInfo = C_Covenants.GetCovenantData(self._ID)
        self:SetKey(_CovenantInfo.ID)
        self:SetID(_CovenantInfo.ID)
        self:SetName(_CovenantInfo.name)
        self._SoulbindIDs = _CovenantInfo.soulbindIDs
        self:SetIconID(XFG.Icons[self:GetName()])
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Covenant:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function Covenant:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. ' Object')
    XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
    XFG:Debug(LogCategory, '  _ID (' .. type(self._ID) .. '): ' .. tostring(self._ID))
    XFG:Debug(LogCategory, '  _Name (' .. type(self._Name) .. '): ' .. tostring(self._Name))
    XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
    for _Index, _SoulbindID in PairsByKeys (self._SoulbindIDs) do
        XFG:Debug(LogCategory, '  _SoulbindID[' .. tostring(_Index) .. '] (' .. type(_SoulbindID) .. '): ' .. tostring(_SoulbindID))
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