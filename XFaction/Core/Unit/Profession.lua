local XFG, G = unpack(select(2, ...))
local ObjectName = 'Profession'
local LogCategory = 'UProfession'

Profession = {}

function Profession:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._ID = 0
    self._Name = nil
    self._IconID = nil
    self._Initialized = false

    return Object
end

function Profession:Initialize()
    if(self:IsInitialized() == false) then
        local _Name = C_TradeSkillUI.GetTradeSkillLineInfoByID(self._ID)
        self._Key = self._ID
        self._Name = _Name
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Profession:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(type(inBoolean) == 'boolean') then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function Profession:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. ' Object')
    XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
    XFG:Debug(LogCategory, '  _ID (' .. type(self._ID) .. '): ' .. tostring(self._ID))
    XFG:Debug(LogCategory, '  _Name (' ..type(self._Name) .. '): ' .. tostring(self._Name))
    XFG:Debug(LogCategory, '  _IconID (' .. type(self._IconID) .. '): ' .. tostring(self._IconID))
    XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
end

function Profession:GetKey()
    return self._Key
end

function Profession:SetKey(inKey)
    assert(type(inKey) == 'number')
    self._Key = inKey
    return self:GetKey()
end

function Profession:GetName()
    return self._Name
end

function Profession:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Profession:GetID()
    return self._ID
end

function Profession:SetID(inProfessionID)
    assert(type(inProfessionID) == 'number')
    self._ID = inProfessionID
    return self:GetID()
end

function Profession:GetIconID()
    return self._IconID
end

function Profession:SetIconID(inIconID)
    assert(type(inIconID) == 'number')
    self._IconID = inIconID
    return self:GetIconID()
end

function Profession:Equals(inProfession)
    if(inProfession == nil) then return false end
    if(type(inProfession) ~= 'table' or inProfession.__name == nil or inProfession.__name ~= 'Profession') then return false end
    if(self:GetKey() ~= inProfession:GetKey()) then return false end
    return true
end