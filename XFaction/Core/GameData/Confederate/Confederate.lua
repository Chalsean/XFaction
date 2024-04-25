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
        XFO.Events:Add({
            name = 'Roster', 
            event = 'GUILD_ROSTER_UPDATE', 
            callback = XFO.Confederate.LocalRoster, 
            instance = true,
            groupDelta = XF.Settings.LocalGuild.ScanTimer
        })
        
        XFO.Timers:Add({
            name = 'Offline',
            delta = XF.Settings.Confederate.UnitScan, 
            callback = XFO.Confederate.Offline, 
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
function XFC.Confederate:TargetCount(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target', 'argument must be Target object')
    return self.countByTarget[inTarget:Key()] or 0
end

function XFC.Confederate:Initials()
    return self:Key()
end

function XFC.Confederate:OnlineCount()
    return self.onlineCount
end
--#endregion

--#region Methods
function XFC.Confederate:Add(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit', 'argument must be Unit object')
    
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
        if(self.countByTarget[inUnit:Target():Key()] == nil) then
            self.countByTarget[inUnit:Target():Key()] = 0
        end
        self.countByTarget[inUnit:Target():Key()] = self.countByTarget[inUnit:Target():Key()] + 1
        if(inUnit:IsOnline()) then
            self.onlineCount = self.onlineCount + 1
        end
    end
    
    if(inUnit:IsPlayer()) then
        XF.Player.Unit = inUnit
    end
end

function XFC.Confederate:Get(inKey, inRealmID, inFactionID)
    assert(type(inKey) == 'string')
    assert(type(inRealmID) == 'number' or inRealmID == nil, 'argument must be number or nil')
    assert(type(inFactionID) == 'number' or inFactionID == nil, 'argument must be number or nil')

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
            XF:Info(self:ObjectName(), '  Restored %s unit information from backup', unit:UnitName())
        end).
        catch(function (err)
            XF:Warn(self:ObjectName(), err)
            self:Push(unit)
        end)
    end
    XF.Cache.Backup.Confederate = {}
end

function XFC.Confederate:Offline(inKey)
    --assert(type(inKey) == 'string' or inKey == nil, 'argument must be string or nil')
    local self = XFO.Confederate -- Callback
    if(inKey ~= nil) then
        if(self:Contains(inKey)) then
            self:Get(inKey):Presence(Enum.ClubMemberPresence.Offline)
            self.onlineCount = self.onlineCount - 1
        end
    else
        local ttl = XFF.TimeGetCurrent() - XF.Settings.Confederate.UnitStale
        for _, unit in self:Iterator() do
            if(not unit:IsPlayer() and unit:IsOnline() and unit:UpdatedTime() < ttl) then
                self:Get(inKey):Presence(Enum.ClubMemberPresence.Offline)
                self.onlineCount = self.onlineCount - 1
            end
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
                        if(XF.Config.Chat.Login.Enable) then
                            XFO.SystemFrame:Display(XF.Enum.Message.LOGOUT, old)
                        end
                        self:Add(unit)
                    elseif(unit:IsOnline()) then
                        if(old:IsOffline()) then
                            XF:Info(self:ObjectName(), 'Guild member login via scan: %s', unit:UnitName())
                            if(XF.Config.Chat.Login.Enable) then
                                XFO.SystemFrame:Display(XF.Enum.Message.LOGIN, unit)
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
    XFO.DTGuild:RefreshBroker()
end
--#endregion