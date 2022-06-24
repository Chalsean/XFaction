local XFG, G = unpack(select(2, ...))
local ObjectName = 'Confederate'
local LogCategory = 'CConfederate'

Confederate = {}

function Confederate:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Name = nil
    self._Units = {}
    self._NumberOfUnits = 0
    
    return Object
end

function Confederate:Print()    
    XFG:DoubleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _Name (" .. type(self._Name) .. "): ".. tostring(self._Name))
    XFG:Debug(LogCategory, "  _NumberOfUnits (" .. type(self._NumberOfUnits) .. "): ".. tostring(self._NumberOfUnits))
    XFG:Debug(LogCategory, "  _Units (" .. type(self._Units) .. "): ")
    for _Key, _Unit in pairs (self._Units) do
        _Unit:Print()
    end
end

function Confederate:ShallowPrint()
    XFG:DoubleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _Name (" .. type(self._Name) .. "): ".. tostring(self._Name))
    XFG:Debug(LogCategory, "  _NumberOfUnits (" .. type(self._NumberOfUnits) .. "): ".. tostring(self._NumberOfUnits))
    XFG:Debug(LogCategory, "  _Units (" .. type(self._Units) .. ")")
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

function Confederate:Contains(inKey)
    assert(type(inKey) == 'string')
    return self._Units[inKey] ~= nil
end

function Confederate:GetUnit(inKey)
    assert(type(inKey) == 'string')
    return self._Units[inKey]
end

function Confederate:AddUnit(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name ~= nil and inUnit.__name == 'Unit', 'argument must be Unit object')

    if(self:Contains(inUnit:GetKey())) then 
        local _CachedUnitData = self:GetUnit(inUnit:GetKey())       
        if(inUnit:GetTimeStamp() < _CachedUnitData:GetTimeStamp()) then
            return false
        end
    else
        self._NumberOfUnits = self._NumberOfUnits + 1
        XFG.DataText.Guild:RefreshBroker()
    end

    self._Units[inUnit:GetKey()] = inUnit
    if(inUnit:IsPlayer()) then
        XFG.Player.Unit = inUnit
    end

    return true
end

function Confederate:OfflineUnits(inEpochTime)
    assert(type(inEpochTime) == 'number')
    for _, _Unit in self:Iterator() do
        if(_Unit:IsPlayer() == false and _Unit:GetTimeStamp() < inEpochTime) then
            self:RemoveUnit(_Unit:GetKey())
        end
    end
end

function Confederate:RemoveUnit(inKey)
    assert(type(inKey) == 'string')
    if(self:Contains(inKey)) then
        table.RemoveKey(self._Units, inKey)
        self._NumberOfUnits = self._NumberOfUnits - 1
        XFG.DataText.Guild:RefreshBroker()
    end
end

function Confederate:Iterator()
	return next, self._Units, nil
end

function Confederate:GetNumberOfUnits()
    return self._NumberOfUnits
end

function Confederate:CreateBackup()
    XFG.DB.Backup = {}
    XFG.DB.Backup.Confederate = {}
    for _UnitKey, _Unit in self:Iterator() do
        if(_Unit:IsRunningAddon() and _Unit:IsPlayer() == false) then
            XFG.DB.Backup.Confederate[_UnitKey] = {}
            local _SerializedData = XFG:SerializeUnitData(_Unit)
            XFG.DB.Backup.Confederate[_UnitKey] = _SerializedData
        end
    end
end

function Confederate:RestoreBackup()
    if(XFG.DB.Backup == nil or XFG.DB.Backup.Confederate == nil) then return end
    for _, _Data in pairs (XFG.DB.Backup.Confederate) do
        local _UnitData = XFG:DeserializeUnitData(_Data)
        if(self:AddUnit(_UnitData)) then
            XFG:Info(LogCategory, '  Restored %s unit information from backup', _UnitData:GetUnitName())
        end
    end
end