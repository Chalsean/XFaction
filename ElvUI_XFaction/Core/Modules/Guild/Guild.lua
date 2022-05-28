local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Guild'
local LogCategory = 'GGuild'

Guild = {}

function Guild:new(inObject)
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

function Guild:Print(inPrintOffline)    
    XFG:DoubleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _Name (" .. type(self._Name) .. "): ".. tostring(self._Name))
    XFG:Debug(LogCategory, "  _MainRealmName (" .. type(self._MainRealmName) .. "): ".. tostring(self._MainRealmName))
    XFG:Debug(LogCategory, "  _MainGuildName (" .. type(self._MainGuildName) .. "): ".. tostring(self._MainGuildName))
    XFG:Debug(LogCategory, "  _MOTD (" .. type(self._MOTD) .. "): ".. tostring(self._MOTD))
    XFG:Debug(LogCategory, "  _NumberOfUnits (" .. type(self._NumberOfUnits) .. "): ".. tostring(self._NumberOfUnits))
    XFG:Debug(LogCategory, "  _Units (" .. type(self._Units) .. "): ")
    for _Key, _Unit in pairs (self._Units) do
        if(inPrintOffline == true or _Unit:IsOnline()) then    
            _Unit:Print()
        end
    end
end

function Guild:ShallowPrint()
    XFG:DoubleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _Name (" .. type(self._Name) .. "): ".. tostring(self._Name))
    XFG:Debug(LogCategory, "  _MainRealmName (" .. type(self._MainRealmName) .. "): ".. tostring(self._MainRealmName))
    XFG:Debug(LogCategory, "  _MainGuildName (" .. type(self._MainGuildName) .. "): ".. tostring(self._MainGuildName))
    XFG:Debug(LogCategory, "  _MOTD (" .. type(self._MOTD) .. "): ".. tostring(self._MOTD))
    XFG:Debug(LogCategory, "  _NumberOfUnits (" .. type(self._NumberOfUnits) .. "): ".. tostring(self._NumberOfUnits))
    XFG:Debug(LogCategory, "  _Units (" .. type(self._Units) .. ")")
end

function Guild:GetKey()
    return self._Key
end

function Guild:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Guild:GetName()
    return self._Name
end

function Guild:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Guild:GetMainRealmName()
    return self._MainRealmName
end

function Guild:SetMainRealmName(inMainRealmName)
    assert(type(inMainRealmName) == 'string')
    self._MainRealmName = inMainRealmName
    return self:GetMainRealmName()
end

function Guild:GetMainGuildName()
    return self._MainGuildName
end

function Guild:SetMainGuildName(inMainGuildName)
    assert(type(inMainGuildName) == 'string')
    self._MainGuildName = inMainGuildName
    return self:GetMainGuildName()
end

function Guild:GetMOTD()
    return self._MOTD
end

function Guild:SetMOTD(inMOTD)
    assert(type(inMOTD) == 'string')
    self._MOTD = inMOTD
    return self:GetMOTD()
end

function Guild:Contains(inKey)
    assert(type(inKey) == 'string')
    return self._Units[inKey] ~= nil
end

function Guild:GetUnit(inKey)
    assert(type(inKey) == 'string')
    return self._Units[inKey]
end

function Guild:AddUnit(inUnit)
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
        XFG.Player.Unit = inUnit
    end

    XFG.Realms:AddUnit(inUnit)

    return true
end

function Guild:OfflineUnits(inDelta)
    assert(type(inDelta) == 'number')
    local _ServerEpochTime = GetServerTime()
    for _, _Unit in pairs (self._Units) do
        if(_Unit:IsPlayer() == false) then
            if(_Unit:GetTimeStamp() + inDelta < _ServerEpochTime) then
                self:RemoveUnit(_Unit:GetKey())
            end
        end
    end
end

function Guild:RemoveUnit(inKey)
    if(Guild:Contains(inKey)) then
        table.RemoveKey(self._Units, inKey)
        self._NumberOfUnits = self._NumberOfUnits - 1
    end
end

function Guild:Iterator()
	return next, self._Units, nil
end

function Guild:GetNumberOfUnits()
    return self._NumberOfUnits
end