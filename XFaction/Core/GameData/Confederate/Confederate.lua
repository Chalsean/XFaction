local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Confederate'

XFC.Confederate = XFC.Factory:newChildConstructor()

--#region Constructors
function XFC.Confederate:new()
    local object = XFC.Confederate.parent.new(self)
	object.__name = ObjectName
    object.onlineCount = 0
	object.countByTarget = {}
	object.guildInfo = nil
    object.modifyGuildInfo = nil
    return object
end

function XFC.Confederate:NewObject()
    return XFC.Unit:new()
end

function XFC.Confederate:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        -- If this is a reload, restore non-local guild members
        try(function ()
            self:CanModifyGuildInfo(XFF.GuildEditPermission())
        end).
        catch(function (inErrorMessage)
            XF:Warn(ObjectName, inErrorMessage)
        end)
        self:Name(XF.Cache.Confederate.Name)
        self:Key(XF.Cache.Confederate.Key)
        XF:Info(ObjectName, 'Initialized confederate %s <%s>', self:Name(), self:Key())

        self:IsInitialized(true)
	end
	return self:IsInitialized()
end
--#endregion

--#region Properties
function XFC.Confederate:CanModifyGuildInfo(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil)
    if(inBoolean ~= nil) then
        self.modifyGuildInfo = inBoolean
--    elseif(not self:IsInitialized()) then
--        self:Initialize()
    end
    return self.modifyGuildInfo
end

function XFC.Confederate:OnlineCount()
    return self.onlineCount
end
--#endregion

--#region Methods
function XFC.Confederate:Add(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')
    
    if(self:Contains(inUnit:Key())) then
        local oldData = self:Get(inUnit:Key())
        self.objects[inUnit:Key()] = inUnit
        if(oldData:IsOffline() and inUnit:IsOnline()) then
            self.onlineCount = self.onlineCount + 1
        elseif(oldData:IsOnline() and inUnit:IsOffline()) then
            self.onlineCount = self.onlineCount - 1
        end
        self:Push(oldData)
    else
        self.parent.Add(self, inUnit)
        local target = XF.Targets:GetByGuild(inUnit:GetGuild())
        if(self.countByTarget[target:Key()] == nil) then
            self.countByTarget[target:Key()] = 0
        end
        self.countByTarget[target:Key()] = self.countByTarget[target:Key()] + 1
        if(inUnit:IsOnline()) then
            self.onlineCount = self.onlineCount + 1
        end
    end
    
    if(inUnit:IsPlayer()) then
        XF.Player.Unit = inUnit
    end
end

function XFC.Confederate:Remove(inKey)
    assert(type(inKey) == 'string')
    if(self:Contains(inKey)) then
        local unit = self:Get(inKey)
        self.parent.Remove(self, inKey)
        if(XF.Nodes:Contains(unit:Name())) then
            XF.Nodes:Remove(XF.Nodes:Get(unit:Name()))
        end
        local target = XF.Targets:GetByGuild(unit:GetGuild())
        self.countByTarget[target:Key()] = self.countByTarget[target:Key()] - 1
        if(unit:IsOnline()) then
            self.onlineCount = self.onlineCount - 1
        end
        if(unit:HasRaiderIO()) then
            XF.Addons.RaiderIO:Remove(unit:GetRaiderIO())
        end
        self:Push(unit)
    end
end

function XFC.Confederate:RemoveAll()
    try(function ()
        if(self:IsInitialized()) then
            for _, unit in self:Iterator() do
                self:Remove(unit:Key())
            end
        end
    end).
    catch(function (err)
        XF:Error(ObjectName, err)
    end)
end

function XFC.Confederate:GetUnitByName(inName)
    assert(type(inName) == 'string')
    for _, unit in self:Iterator() do
        if(unit:Name() == inName) then
            return unit
        end
    end
end

function XFC.Confederate:CountByTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target')
    return self.countByTarget[inTarget:Key()] or 0
end



function XFC.Confederate:GetInitials()
    return self:Key()
end

function XFC.Confederate:Backup()
    try(function ()
        if(self:IsInitialized()) then
            for unitKey, unit in self:Iterator() do
                if(unit:IsRunningAddon() and not unit:IsPlayer()) then
                    XF.Cache.Backup.Confederate[unitKey] = {}
                    XF.Cache.Backup.Confederate[unitKey] = unit:Serialize()
                end
            end
        end
    end).
    catch(function (err)
        XF.Cache.Errors[#XF.Cache.Errors + 1] = 'Failed to create confederate backup before reload: ' .. err
    end)
end

function XFC.Confederate:Restore()
    if(XF.Cache.Backup.Confederate == nil) then XF.Cache.Backup.Confederate = {} end
    for _, data in pairs (XF.Cache.Backup.Confederate) do
        try(function ()
            local unitData = XF:DeserializeUnitData(data)
            self:Add(unitData)
            XF:Info(ObjectName, '  Restored %s unit information from backup', unitData:GetUnitName())
        end).
        catch(function (err)
            XF:Warn(ObjectName, err)
        end)
    end
    XF.Cache.Backup.Confederate = {}
end

function XFC.Confederate:OfflineUnit(inKey)
    assert(type(inKey) == 'string')
    if(self:Contains(inKey)) then
        self:Get(inKey):SetPresence(Enum.ClubMemberPresence.Offline)
        self.onlineCount = self.onlineCount - 1
    end
end

function XFC.Confederate:OfflineUnits(inEpochTime)
    assert(type(inEpochTime) == 'number')
    for _, unit in self:Iterator() do
        if(not unit:IsPlayer() and unit:IsOnline() and unit:TimeStamp() < inEpochTime) then
            if(XF.Player.Guild:Equals(unit:GetGuild())) then
                self:OfflineUnit(unit:Key())
            else
                self:Remove(unit:Key())
            end
        end
    end
end
--#endregion