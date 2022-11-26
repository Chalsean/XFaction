local XFG, G = unpack(select(2, ...))
local ObjectName = 'Confederate'
local GuildRosterEvent = C_GuildInfo.GuildRoster

Confederate = Factory:newChildConstructor()

--#region Constructors
function Confederate:new()
    local object = Confederate.parent.new(self)
	object.__name = ObjectName
	object.countByTarget = {}
	object.guildInfo = nil
    object.modifyGuildInfo = nil
    return object
end

function Confederate:NewObject()
    return Unit:new()
end
--#endregion

--#region Initializers
function Confederate:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        -- If this is a reload, restore non-local guild members
        try(function ()
            self:CanModifyGuildInfo(CanEditGuildInfo())
        end).
        catch(function (inErrorMessage)
            XFG:Warn(ObjectName, inErrorMessage)
        end)
        self:SetName(XFG.Cache.Confederate.Name)
        self:SetKey(XFG.Cache.Confederate.Key)
        XFG:Info(ObjectName, 'Initialized confederate %s <%s>', self:GetName(), self:GetKey())

        self:IsInitialized(true)
	end
	return self:IsInitialized()
end
--#endregion

--#region Hash
function Confederate:Add(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit', 'argument must be Unit object')
    
    if(self:Contains(inUnit:GetKey())) then
        local oldData = self:Get(inUnit:GetKey())
        self.objects[inUnit:GetKey()] = inUnit
        self:Push(oldData)
    else
        self.parent.Add(self, inUnit)
        XFG.DataText.Guild:RefreshBroker()    

        local target = XFG.Targets:GetByRealmFaction(inUnit:GetRealm(), inUnit:GetFaction())
        if(self.countByTarget[target:GetKey()] == nil) then
            self.countByTarget[target:GetKey()] = 0
        end
        self.countByTarget[target:GetKey()] = self.countByTarget[target:GetKey()] + 1
    end

    if(inUnit:IsPlayer()) then
        XFG.Player.Unit = inUnit
    end

    return true
end

function Confederate:Remove(inKey)
    assert(type(inKey) == 'string')
    if(self:Contains(inKey)) then
        local unit = self:Get(inKey)
        self.parent.Remove(self, inKey)
        XFG.DataText.Guild:RefreshBroker()
        if(XFG.Nodes:Contains(unit:GetName())) then
            XFG.Nodes:Remove(XFG.Nodes:Get(unit:GetName()))
        end
        local target = XFG.Targets:GetByRealmFaction(unit:GetRealm(), unit:GetFaction())
        self.countByTarget[target:GetKey()] = self.countByTarget[target:GetKey()] - 1
        self:Push(unit)
    end
end
--#endregion

--#region Stack
function Confederate:Push(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit', 'argument must be Unit object')
    if(inUnit:HasRaidIO()) then
        XFG.RaidIO:Push(inUnit:GetRaidIO())
    end
    self.parent.Push(self, inUnit)
end
--#endregion

--#region Accessors
function Confederate:GetUnitByName(inName)
    assert(type(inName) == 'string')
    for _, unit in self:Iterator() do
        if(unit:GetName() == inName) then
            return unit
        end
    end
end

function Confederate:GetCountByTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target', 'argument must be Target object')
    return self.countByTarget[inTarget:GetKey()] or 0
end

function Confederate:CanModifyGuildInfo(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self.modifyGuildInfo = inBoolean
    elseif(not self:IsInitialized()) then
        self:Initialize()
    end
    return self.modifyGuildInfo
end

function Confederate:GetInitials()
    return self:GetKey()
end
--#endregion

--#region Janitorial
function Confederate:Backup()
    try(function ()
        for unitKey, unit in self:Iterator() do
            if(unit:IsRunningAddon() and not unit:IsPlayer()) then
                XFG.Cache.Backup.Confederate[unitKey] = {}
                local serializedData = XFG:SerializeUnitData(unit)
                XFG.Cache.Backup.Confederate[unitKey] = serializedData
            end
        end
    end).
    catch(function (inErrorMessage)
        XFG.Cache.Errors[#XFG.Cache.Errors + 1] = 'Failed to create confederate backup before reload: ' .. inErrorMessage
    end)
end

function Confederate:Restore()
    XFG:Debug(ObjectName, 'Restoring confederate members')
    for _, data in pairs (XFG.Cache.Backup.Confederate) do
        try(function ()
            local unitData = XFG:DeserializeUnitData(data)
            if(self:Add(unitData)) then
                -- Although this is dynamically building a string, it only does this function on startup
                XFG:Info(ObjectName, '  Restored %s unit information from backup', unitData:GetUnitName())
            end
        end).
        catch(function (inErrorMessage)
            XFG:Warn(ObjectName, inErrorMessage)
        end)
    end
end

function Confederate:OfflineUnits(inEpochTime)
    assert(type(inEpochTime) == 'number')
    for _, unit in self:Iterator() do
        if(not unit:IsPlayer() and unit:GetTimeStamp() < inEpochTime) then
            self:Remove(unit:GetKey())
        end
    end
end
--#endregion