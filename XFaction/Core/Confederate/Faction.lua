local XFG, G = unpack(select(2, ...))
local ObjectName = 'Faction'
local LogCategory = 'CFaction'

Faction = {}

function Faction:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._ID = nil
    self._Name = nil
    self._IconID = nil
    self._Language = nil
    self._Initialized = false
    
    return Object
end

function Faction:Initialize()
    if(self:IsInitialized() == false) then        
        if(self._Name ~= nil) then
            if(self._Name == 'Horde') then
                self:SetIconID(463451)
                self:SetLanguage('Orcish')
            elseif(self._Name == 'Alliance') then
                self:SetIconID(2565243)
                self:SetLanguage('Common')
            else
                self:SetIconID(132311)
                self:SetLanguage('Common')
            end
        end
        self:SetID(self._Key)
        self:IsInitialized(true)
    end
end

function Faction:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(type(inBoolean) == 'boolean') then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function Faction:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. ' Object')
    XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
    XFG:Debug(LogCategory, '  _Name (' .. type(self._Name) .. '): ' .. tostring(self._Name))
    XFG:Debug(LogCategory, '  _IconID (' .. type(self._IconID) .. '): ' .. tostring(self._IconID))
    XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
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

function Faction:GetID()
    return self._ID
end

function Faction:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
    return self:GetID()
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

function Faction:GetLanguage()
    return self._Language
end

function Faction:SetLanguage(inLanguage)
    assert(type(inLanguage) == 'string')
    self._Language = inLanguage
    return self:GetLanguage()
end