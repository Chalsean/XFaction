local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Confederate'

XFC.Confederate = XFC.Factory:newChildConstructor()

--#region Constructors
function XFC.Confederate:new()
    local object = XFC.Confederate.parent.new(self)
	object.__name = ObjectName
    object.onlineCount = 0
	object.guildInfo = nil
    return object
end

function XFC.Confederate:NewObject()
    return XFC.Unit:new()
end

function XFC.Confederate:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()

        self:Name(XF.Cache.Confederate.Name)
        self:Key(XF.Cache.Confederate.Key)

        XF:Info(self:ObjectName(), 'Initialized confederate %s <%s>', self:Name(), self:Key())

        -- This is the local guild roster scan for those not running the addon
        XF.Events:Add({
            name = 'Roster', 
            event = 'GUILD_ROSTER_UPDATE', 
            callback = XFO.Confederate.LocalRoster, 
            instance = true,
            groupDelta = XF.Settings.LocalGuild.ScanTimer
        })
        
        XF.Timers:Add({
            name = 'Offline',
            delta = XF.Settings.Confederate.UnitScan, 
            callback = XFO.Confederate.CallbackOffline, 
            repeater = true, 
            instance = true
        })    
        
        -- On initial login, the roster returned is incomplete, you have to force Blizz to do a guild roster refresh
        XFF.GuildQueryServer()

        self:IsInitialized(true)
	end
	return self:IsInitialized()
end
--#endregion

--#region Properties
function XFC.Confederate:Initials()
    return self:Key()
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
        if(oldData:IsOffline() and inUnit:IsOnline()) then
            self.onlineCount = self.onlineCount + 1
        end
        self.parent.Add(self, inUnit)
        self:Push(oldData)
    else
        self.parent.Add(self, inUnit)
        if(inUnit:IsOnline()) then
            self.onlineCount = self.onlineCount + 1
        end
    end
    
    if(inUnit:IsPlayer()) then
        XF.Player.Unit = inUnit
    end
end

function XFC.Confederate:Upsert(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')
    if(self:Contains(inUnit:Key()) and inUnit:TimeStamp() < self:Get(inUnit:Key()):TimeStamp()) then
        return false
    end
    self:Add(inUnit)
    return true
end

function XFC.Confederate:Get(inKey, inRealmID, inFactionID)
    assert(type(inKey) == 'string')
    assert(type(inRealmID) == 'number' or inRealmID == nil)
    assert(type(inFactionID) == 'number' or inFactionID == nil)

    if(inRealmID == nil) then
        return self.parent.Get(self, inKey)
    end

    local realm = XFO.Realms:Get(inRealmID)
    local faction = XFO.Factions:Get(inFactionID)

    for _, unit in self:Iterator() do
        if(XF:ObjectsEquals(realm, unit:Guild():Realm()) and XF:ObjectsEquals(faction, unit:Race():Faction()) and unit:Name() == inKey) then
            return unit
        end
    end
end

function XFC.Confederate:Backup()
    try(function ()
        if(self:IsInitialized()) then
            for unitKey, unit in self:Iterator() do
                if(unit:IsOnline() and unit:IsRunningAddon() and not unit:IsPlayer()) then
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
        local unit = self:Pop()
        unit:Deserialize(data)
        unit:IsRunningAddon(true)
        self:Add(unit)
        XF:Info(self:ObjectName(), '  Restored %s unit information from backup', unit:UnitName())
    end
    XF.Cache.Backup.Confederate = {}
end

function XFC.Confederate:CallbackOffline()
    local self = XFO.Confederate
    try(function()
        local ttl = XFF.TimeGetCurrent() - XF.Settings.Confederate.UnitStale
        for _, unit in self:Iterator() do
            if(not unit:IsPlayer() and unit:IsOnline() and unit:TimeStamp() < ttl) then
                self:OfflineUnit(unit:Key())
            end
        end
    end).
    catch(function(err)
        XF:Warn(self:ObjectName(), err)
    end).
    finally(function()
        XF.Timers:Get('Offline'):SetLastRan(XFF.TimeGetCurrent())
    end)
end

function XFC.Confederate:OfflineUnit(inKey)
    assert(type(inKey) == 'string')
    if(self:Contains(inKey)) then
        local unit = self:Get(inKey)

        XFO.Links:RemoveAll(unit)
        if(XF.Config.Chat.Login.Enable) then
            XF.Frames.System:Display(XF.Enum.Message.LOGOUT, unit:Name(), unit:UnitName(), unit:MainName(), unit:Guild(), nil, unit:Race():Faction())
        end

        if(unit:Guild():Equals(XF.Player.Guild)) then
            unit:Presence(Enum.ClubMemberPresence.Offline)
            self.onlineCount = self.onlineCount - 1
        else
            self:Remove(inKey)
            self:Push(unit)
        end
    end
end

-- The event doesn't tell you what has changed, only that something has changed. So you have to scan the whole roster
function XFC.Confederate:LocalRoster()
    local self = XFO.Confederate -- Callback
    XF:Trace(self:ObjectName(), 'Scanning local guild roster')
    for _, memberID in pairs (XFF.GuildGetMembers(XF.Player.Guild:ID(), XF.Player.Guild:StreamID())) do
        local unit = nil
        try(function ()
            -- Every logic branch should either add, remove or push, otherwise there will be a memory leak
            unit = self:Pop()
            unit:Initialize(memberID)
            if(unit:IsInitialized()) then
                if(self:Contains(unit:Key())) then
                    local old = self:Get(unit:Key())
                    if(old:IsOnline() and unit:IsOffline()) then
                        XF:Info(self:ObjectName(), 'Guild member logout via scan: %s', unit:UnitName())
                        self:OfflineUnit(old:Key())
                        self:Push(unit)
                    elseif(unit:IsOnline()) then
                        if(old:IsOffline()) then
                            XF:Info(self:ObjectName(), 'Guild member login via scan: %s', unit:UnitName())
                            if(XF.Config.Chat.Login.Enable) then
                                XF.Frames.System:DisplayLogin(unit)
                            end
                            self:Add(unit)
                        elseif(not old:IsRunningAddon()) then
                            self:Add(unit)
                        else
                            -- Other player is online and running addon, they will have more info than we get from a scan like spec                            
                            self:Push(unit)
                        end
                    else
                        self:Push(unit)
                    end
                -- First time scan (i.e. login) do not notify
                else
                    self:Add(unit)
                end
            -- If it didnt initialize properly then we dont really know their status, so do nothing
            else
                self:Push(unit)
            end
        end).
        catch(function (err)
            XF:Warn(self:ObjectName(), err)
            self:Push(unit)
        end)
    end
    XF.DataText.Guild:RefreshBroker()
end

function XFC.Confederate:ProcessMessage(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')
    if(inMessage:Subject() == XF.Enum.Message.LOGOUT) then
        -- Deprecated, remove after 4.13
        if(inMessage:Version():IsNewer(XF.DeprecatedVersion, true)) then
            if(not XF.Player.Guild:Equals(inMessage:Guild())) then
                if(XF.Config.Chat.Login.Enable) then
                    XF.Frames.System:DisplayLogout(inMessage:Name())
                end
                if(self:Contains(inMessage:From())) then
                    local unit = self:Get(inMessage:From())
                    XFO.Links:RemoveAll(unit)
                    self:Remove(unit:Key())
                    self:Push(unit)
                end
            end
        -- Guild scan will handle local guild logout notifications
        elseif(not inMessage:FromUnit():IsSameGuild()) then
            -- TODO move this check to frame
            if(XF.Config.Chat.Login.Enable) then
                XF.Frames.System:DisplayLogout(inMessage:FromUnit():Name())
            end
            XFO.Links:RemoveAll(inMessage:FromUnit())
            self:Remove(inMessage:FromUnit():Key())
            self:Push(inMessage:FromUnit())
        end
    -- else
    --     local unit = nil
    --     try(function()
    --         unit = self:Pop()
    --         unit:Deserialize(inMessage:Data())

    --         -- Process LOGIN message
    --         if(inMessage:Subject() == XF.Enum.Message.LOGIN and not XF.Player.Guild:Equals(inMessage:Guild())) then
    --             XF.Frames.System:DisplayLogin(unit)
    --         end

    --         -- Is the unit data newer?
    --         if(self:Contains(unit:Key())) then
    --             if(self:Get(unit:Key()):TimeStamp() < unit:TimeStamp()) then
    --                 XF:Info(self:ObjectName(), 'Updated unit [%s] information based on message received', unit:UnitName())
    --                 self:Add(unit)
    --             else
    --                 self:Push(unit)
    --             end
    --         else
    --             XF:Info(self:ObjectName(), 'Added unit [%s] information based on message received', unit:UnitName())
    --             self:Add(unit)
    --         end
    --     end).
    --     catch(function(err)
    --         XF:Warn(self:ObjectName(), err)
    --         if(unit ~= nil) then
    --             self:Push(unit)
    --         end
    --     end)        
    end
    XF.DataText.Guild:RefreshBroker()
end
--#endregion