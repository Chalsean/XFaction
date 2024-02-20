local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
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
--#endregion

--#region Initializers
function XFC.Confederate:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()

        try(function ()
            self:CanModifyGuildInfo(CanEditGuildInfo())
        end).
        catch(function (inErrorMessage)
            XF:Warn(self:GetObjectName(), inErrorMessage)
        end)
        self:SetName(XF.Cache.Confederate.Name)
        self:SetKey(XF.Cache.Confederate.Key)

        XF:Info(self:GetObjectName(), 'Initialized confederate %s <%s>', self:GetName(), self:GetKey())

        XFO.Timers:Add
        ({
            name = 'Offline', 
            delta = XF.Settings.Confederate.UnitScan, 
            callback = XFO.Confederate.Offline, 
            repeater = true, 
            instance = true
        })       

        self:IsInitialized(true)
	end
	return self:IsInitialized()
end
--#endregion

--#region Hash
function XFC.Confederate:Add(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit', 'argument must be Unit object')
    
    if(self:Contains(inUnit:GetKey())) then
        local oldData = self:Get(inUnit:GetKey())
        self.objects[inUnit:GetKey()] = inUnit
        if(oldData:IsOffline() and inUnit:IsOnline()) then
            self.onlineCount = self.onlineCount + 1
        elseif(oldData:IsOnline() and inUnit:IsOffline()) then
            self.onlineCount = self.onlineCount - 1
        end
        self:Push(oldData)
    else
        self.parent.Add(self, inUnit)
        local target = XFO.Targets:GetByGuild(inUnit:GetGuild())
        if(self.countByTarget[target:GetKey()] == nil) then
            self.countByTarget[target:GetKey()] = 0
        end
        self.countByTarget[target:GetKey()] = self.countByTarget[target:GetKey()] + 1
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
        if(XFO.Nodes:Contains(unit:GetName())) then
            XFO.Nodes:Remove(XFO.Nodes:Get(unit:GetName()))
        end
        local target = XFO.Targets:GetByGuild(unit:GetGuild())
        self.countByTarget[target:GetKey()] = self.countByTarget[target:GetKey()] - 1
        if(unit:IsOnline()) then
            self.onlineCount = self.onlineCount - 1
        end
        if(unit:HasRaiderIO()) then
            XF.Addons.RaiderIO:Remove(unit:GetRaiderIO())
        end
        self:Push(unit)
    end
end
--#endregion

--#region Accessors
function XFC.Confederate:GetCountByTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target', 'argument must be Target object')
    return self.countByTarget[inTarget:GetKey()] or 0
end

function XFC.Confederate:CanModifyGuildInfo(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self.modifyGuildInfo = inBoolean
    elseif(not self:IsInitialized()) then
        self:Initialize()
    end
    return self.modifyGuildInfo
end

function XFC.Confederate:GetInitials()
    return self:GetKey()
end

function XFC.Confederate:GetOnlineCount()
    return self.onlineCount
end
--#endregion

--#region Janitorial
function XFC.Confederate:Backup()
    try(function ()
        if(self:IsInitialized()) then
            for unitKey, unit in self:Iterator() do
                if(unit:IsRunningAddon() and not unit:IsPlayer()) then
                    XF.Cache.Backup.Confederate[unitKey] = unit:Serialize()
                end
            end
        end
    end).
    catch(function (inErrorMessage)
        XF.Cache.Errors[#XF.Cache.Errors + 1] = 'Failed to create confederate backup before reload: ' .. inErrorMessage
    end)
end

function XFC.Confederate:Restore()
    if(XF.Cache.Backup.Confederate == nil) then XF.Cache.Backup.Confederate = {} end
    for _, data in pairs (XF.Cache.Backup.Confederate) do
        local unit = nil
        try(function ()
            unit = self:Pop()
            unit:Deserialize(data)
            self:Add(unit)
            XF:Info(self:GetObjectName(), '  Restored %s unit information from backup', unit:GetUnitName())
        end).
        catch(function (err)
            XF:Warn(self:GetObjectName(), err)
            self:Push(unit)
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

function XFC.Confederate:Offline()
    local ttl = GetCurrentTime() - XF.Settings.Confederate.UnitStale
    for _, unit in self:Iterator() do
        if(not unit:IsPlayer() and unit:IsOnline() and unit:GetTimeStamp() < ttl) then
            if(XF.Player.Guild:Equals(unit:GetGuild())) then
                self:OfflineUnit(unit:GetKey())
            else
                self:Remove(unit:GetKey())
            end
        end
    end
end
--#endregion