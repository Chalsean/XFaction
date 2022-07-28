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
    self._UnitCount = 0
    self._CountByTarget = {}
    
    return Object
end

function Confederate:Print()    
    XFG:DoubleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _Name (" .. type(self._Name) .. "): ".. tostring(self._Name))
    XFG:Debug(LogCategory, "  _UnitCount (" .. type(self._UnitCount) .. "): ".. tostring(self._UnitCount))
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
    XFG:Debug(LogCategory, "  _UnitCount (" .. type(self._UnitCount) .. "): ".. tostring(self._UnitCount))
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
        local _OldObject = self._Units[inUnit:GetKey()]
        self._Units[inUnit:GetKey()] = inUnit
        XFG.Factories.Unit:CheckIn(_OldObject)
    else
        self._UnitCount = self._UnitCount + 1
        self._Units[inUnit:GetKey()] = inUnit
        XFG.DataText.Guild:RefreshBroker()
    end
    
    if(inUnit:IsPlayer()) then
        XFG.Player.Unit = inUnit
    end

    local _Target = XFG.Targets:GetTarget(inUnit:GetRealm(), inUnit:GetFaction())
    if(self._CountByTarget[_Target:GetKey()] == nil) then
        self._CountByTarget[_Target:GetKey()] = 0
    end
    self._CountByTarget[_Target:GetKey()] = self._CountByTarget[_Target:GetKey()] + 1

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
        local _Unit = self:GetUnit(inKey)
        try(function ()
            self._Units[inKey] = nil
            self._UnitCount = self._UnitCount - 1
            XFG.DataText.Guild:RefreshBroker()
            if(XFG.Nodes:Contains(_Unit:GetName())) then
                XFG.Nodes:RemoveNode(XFG.Nodes:GetNode(_Unit:GetName()))
                XFG.DataText.Links:RefreshBroker()
            end
        end).
        finally(function ()
            XFG.Factories.Unit:CheckIn(_Unit)
        end)
        local _Target = XFG.Targets:GetTarget(_Unit:GetRealm(), _Unit:GetFaction())
        self._CountByTarget[_Target:GetKey()] = self._CountByTarget[_Target:GetKey()] - 1
    end
end

function Confederate:Iterator()
	return next, self._Units, nil
end

function Confederate:GetCount()
    return self._UnitCount
end

function Confederate:CreateBackup()
    try(function ()
        XFG.DB.Backup = {}
        XFG.DB.Backup.Confederate = {}
        for _UnitKey, _Unit in self:Iterator() do
            if(_Unit:IsRunningAddon() and _Unit:IsPlayer() == false) then
                XFG.DB.Backup.Confederate[_UnitKey] = {}
                local _SerializedData = XFG:SerializeUnitData(_Unit)
                XFG.DB.Backup.Confederate[_UnitKey] = _SerializedData
            end
        end
    end).
    catch(function (inErrorMessage)
        table.insert(XFG.DB.Errors, 'Failed to create confederate backup before reload: ' .. inErrorMessage)
    end)
end

function Confederate:RestoreBackup()
    if(XFG.DB.Backup == nil or XFG.DB.Backup.Confederate == nil) then return end
    for _, _Data in pairs (XFG.DB.Backup.Confederate) do
        try(function ()
            local _UnitData = XFG:DeserializeUnitData(_Data)
            if(self:AddUnit(_UnitData)) then
                XFG:Info(LogCategory, '  Restored %s unit information from backup', _UnitData:GetUnitName())
            end
        end).
        catch(function (inErrorMessage)
            XFG:Warn(LogCategory, 'Failed to restore confederate unit: ' .. inErrorMessage)
        end)
    end    
end

function Confederate:GetCountByTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name ~= nil and inTarget.__name == 'Target', 'argument must be Target object')
    return self._CountByTarget[inTarget:GetKey()] or 0
end