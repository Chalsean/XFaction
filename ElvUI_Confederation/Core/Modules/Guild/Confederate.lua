local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Confederate'
local LogCategory = 'O' .. ObjectName

Confederate = {}

function Confederate:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or 
	      (typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(typeof == 'table') then
        Object = inObject
        newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject) then
        self._Key = nil
        self._Name = nil
        self._MainRealmName = nil
        self._MainGuildName = nil
        self._MOTD = nil
        self._Units = {}
        self._NumberOfUnits = 0
    end

    return Object
end

function Confederate:Print(inPrintOffline)    
    CON:DoubleLine(LogCategory)
    CON:Debug(LogCategory, "Confederate Object")
    CON:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    CON:Debug(LogCategory, "  _Name (" .. type(self._Name) .. "): ".. tostring(self._Name))
    CON:Debug(LogCategory, "  _MainRealmName (" .. type(self._MainRealmName) .. "): ".. tostring(self._MainRealmName))
    CON:Debug(LogCategory, "  _MainGuildName (" .. type(self._MainGuildName) .. "): ".. tostring(self._MainGuildName))
    CON:Debug(LogCategory, "  _MOTD (" .. type(self._MOTD) .. "): ".. tostring(self._MOTD))
    CON:Debug(LogCategory, "  _NumberOfUnits (" .. type(self._NumberOfUnits) .. "): ".. tostring(self._NumberOfUnits))
    CON:Debug(LogCategory, "  _Units (" .. type(self._Units) .. "): ")
    for _Key, _Unit in pairs (self._Units) do
        if(inPrintOffline == true or _Unit:IsOnline()) then    
            _Unit:Print()
        end
    end
end

function Confederate:ShallowPrint()
    CON:DoubleLine(LogCategory)
    CON:Debug(LogCategory, "Confederate Object")
    CON:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    CON:Debug(LogCategory, "  _Name (" .. type(self._Name) .. "): ".. tostring(self._Name))
    CON:Debug(LogCategory, "  _MainRealmName (" .. type(self._MainRealmName) .. "): ".. tostring(self._MainRealmName))
    CON:Debug(LogCategory, "  _MainGuildName (" .. type(self._MainGuildName) .. "): ".. tostring(self._MainGuildName))
    CON:Debug(LogCategory, "  _MOTD (" .. type(self._MOTD) .. "): ".. tostring(self._MOTD))
    CON:Debug(LogCategory, "  _NumberOfUnits (" .. type(self._NumberOfUnits) .. "): ".. tostring(self._NumberOfUnits))
    CON:Debug(LogCategory, "  _Teams (" .. type(self._Teams) .. ")")
    for _Key, _Team in pairs (self._Teams) do
        _Team:Print(true)
    end
end

function Confederate:GetKey()
    return self._Key
end

function Confederate:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Confederate:GetName()
    return self._Name
end

function Confederate:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Confederate:GetMainRealmName()
    return self._MainRealmName
end

function Confederate:SetMainRealmName(inMainRealmName)
    assert(type(inMainRealmName) == 'string')
    self._MainRealmName = inMainRealmName
    return self:GetMainRealmName()
end

function Confederate:GetMainGuildName()
    return self._MainGuildName
end

function Confederate:SetMainGuildName(inMainGuildName)
    assert(type(inMainGuildName) == 'string')
    self._MainGuildName = inMainGuildName
    return self:GetMainGuildName()
end

function Confederate:GetMOTD()
    return self._MOTD
end

function Confederate:SetName(inMOTD)
    assert(type(inMOTD) == 'string')
    self._MOTD = inMOTD
    return self:GetMOTD()
end

function Confederate:Contains(inKey)
    assert(type(inKey) == 'string')
    return self._Units[inKey] ~= nil
end

function Confederate:GetUnit(inKey)
    assert(type(inKey) == 'string')
    return self._Units[inKey]
end

function Confederate:AddUnit(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name ~= nil and inUnit.__name == 'Unit', "argument must be Unit object")

    if(self:Contains(inUnit:GetKey())) then 
        -- Data might be coming from server in another timezone, make sure to compare apples to apples
        local _CachedUnitData = self:GetUnit(inUnit:GetKey())       
        if(inUnit:GetTimeStamp() < _CachedUnitData:GetTimeStamp()) then
            return false
        end
    else
        self._NumberOfUnits = self._NumberOfUnits + 1
    end

    self._Units[inUnit:GetKey()] = inUnit
    if(inUnit:IsPlayer()) then
        CON.Player.Unit = inUnit
    end

    CON.Realms:AddUnit(inUnit)

    return true
end