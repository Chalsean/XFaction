local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Confederate'

XFC.Confederate = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.Confederate:new()
    local object = XFC.Confederate.parent.new(self)
	object.__name = ObjectName
    return object
end

function XFC.Confederate:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:Name(XF.Cache.Confederate.Name)
        self:Key(XF.Cache.Confederate.Key)

        XFO.Events:Add({
            name = 'Roster', 
            event = 'GUILD_ROSTER_UPDATE', 
            callback = XFO.Confederate.CallbackLocalGuild, 
            instance = false,
            groupDelta = XF.Settings.LocalGuild.ScanTimer
        })
        
        XFO.Events:Add({
            name = 'Guild',
            event = 'PLAYER_GUILD_UPDATE',
            callback = XFO.Confederate.CallbackGuildChanged
        })

        XFO.Timers:Add({
            name = 'Heartbeat',
            delta = XF.Settings.Player.Heartbeat,
            callback = XFO.Confederate.CallbackHeartbeat,
            repeater = true,
            instance = true
        })

        XF:Info(self:ObjectName(), 'Initialized confederate %s <%s>', self:Name(), self:Key())
        self:IsInitialized(true)
	end
	return self:IsInitialized()
end
--#endregion

--#region Methods
function XFC.Confederate:Print()
	if(XF.IsInitialized) then
		self.parent.Print()
	end
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
            local unit = XFC.Unit:new()
            unit:Deserialize(data)
            self:OnlineUnit(unit)
            XF:Info(self:ObjectName(), '  Restored %s unit information from backup', unit:UnitName())
        end).
        catch(function (err)
            XF:Warn(self:ObjectName(), err)
        end)
    end
    XF.Cache.Backup.Confederate = {}
end

function XFC.Confederate:Login(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')
    if(not self:Contains(inUnit:Key()) or self:Get(inUnit:Key()):IsOffline()) then
        XF:Info(self:ObjectName(), 'Guild member login: %s', inUnit:UnitName())
        XFO.SystemFrame:DisplayLogin(inUnit)
    end
    self:OnlineUnit(inUnit)
end

function XFC.Confederate:Logout(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')
    if(self:Contains(inUnit:Key()) and self:Get(inUnit:Key()):IsOnline()) then
        XF:Info(self:ObjectName(), 'Guild member logout: %s', inUnit:UnitName())
        if(not XFF.PlayerIsIgnored(inUnit:GUID())) then
            XFO.SystemFrame:DisplayLogout(inUnit:UnitName())
        end
    end
    self:OfflineUnit(inUnit)
end

function XFC.Confederate:OnlineUnit(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')

    if(self:Contains(inUnit:Key())) then
        local old = self:Get(inUnit:Key())
        inUnit:LoginEpoch(old:IsOnline() and old:LoginEpoch() or XFF.TimeCurrent())
    else
        inUnit:LoginEpoch(XFF.TimeCurrent())
    end
    self:Add(inUnit)

    if(inUnit:IsPlayer()) then
        XF.Player.Unit = inUnit
    end

    XFO.DTGuild:RefreshBroker()
    XFO.DTLinks:RefreshBroker()
end

function XFC.Confederate:OfflineUnit(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')

    if(inUnit:IsSameGuild()) then
        self:Add(inUnit)
    else
        self:Remove(inUnit:Key())
    end

    XFO.DTLinks:RefreshBroker()
    XFO.DTGuild:RefreshBroker()
end

-- The event doesn't tell you what has changed, only that something has changed. So you have to scan the whole roster
function XFC.Confederate:CallbackLocalGuild()
    local self = XFO.Confederate
    if(not XF.Config.DataText.Guild.NonXFaction) then return end
    if(XFF.PlayerIsInCombat()) then return end

    XF:Trace(self:ObjectName(), 'Scanning local guild roster')
    for _, memberID in pairs (XFF.GuildMembers(XF.Player.Guild:ID())) do        
        try(function ()
            local unit = XFC.Unit:new()
            unit:Initialize(memberID)
            if(unit:IsInitialized()) then
                if(self:Contains(unit:Key())) then
                    local oldData = self:Get(unit:Key())
                    if(oldData:IsOnline() and unit:IsOffline()) then
                        XF:Debug(self:ObjectName(), 'Detected guild logout: %s', oldData:UnitName())
                        self:Logout(unit)
                    elseif(unit:IsOnline()) then
                        if(oldData:IsOffline()) then
                            self:Login(unit)
                        elseif(not oldData:IsRunningAddon()) then
                            self:OnlineUnit(unit)
                        end
                    end
                -- First time scan (i.e. login) do not notify
                else
                    self:OnlineUnit(unit)
                end
            end
        end).
        catch(function (err)
            XF:Warn(self:ObjectName(), err)
        end)
    end
end

function XFC.Confederate:ProcessMessage(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')
    if(inMessage:IsLoginMessage()) then
        self:Login(inMessage:FromUnit())        
    else
        self:OnlineUnit(inMessage:FromUnit())
    end
end

function XFC.Confederate:ProcessLogout(inGUID)
    assert(type(inGUID) == 'string')
    if(self:Contains(inGUID)) then
        local unit = self:Get(inGUID)
        if(not unit:IsSameGuild() or not XF.Config.DataText.Guild.NonXFaction) then
            self:Logout(unit)
        end
    end
end

function XFC.Confederate:CallbackHeartbeat() 
    local self = XFO.Confederate

    try(function ()
        local unit = XFC.Unit:new()
        unit:Initialize()
        self:OnlineUnit(unit)
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
        return
    end)

    try(function()
        XFO.Mailbox:SendDataMessage()
    end).
    catch(function(err)
        XF:Warn(self:ObjectName(), err)
    end)
end

function XFC.Confederate:CallbackGuildChanged(inEvent, inUnitID) 
    local self = XFO.Confederate
    XF:Debug(self:ObjectName(), 'Guild update event fired [%s]', inUnitID)
    try(function ()
        -- Player just joined a guild
        if(XFF.PlayerIsInGuild()) then
            XF:Trace(self:ObjectName(), 'Player is in a guild')
            if(not XF.Initialized) then
                if(XFO.Timers:Contains('LoginGuild')) then
                    local timer = XFO.Timers:Get('LoginGuild')
                    timer:Attempt(1)
                    timer:Start()
                else    
                    XFO.Timers:Add({
                        name = 'LoginGuild', 
                        delta = 1, 
                        callback = XF.CallbackLoginGuild, 
                        repeater = true, 
                        instance = true,
                        ttl = XF.Settings.LocalGuild.LoginTTL,
                        start = true
                    })
                end
            end
        -- Player just left a guild
        elseif(not XFF.PlayerIsInGuild()) then
            XF:Warn(self:ObjectName(), 'Player is not in a guild')
            XF:Stop()
            self:RemoveAll()

            for _, guild in XFO.Guilds:Iterator() do
                guild:RemoveAll()
            end

            for _, target in XFO.Targets:Iterator() do
                target:RemoveAll()
            end

            XFO.DTLinks:RefreshBroker()
            XFO.DTGuild:RefreshBroker()
        end
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)
end

function XFC.Confederate:GetChatCount()
    local chat = 0
    for _, unit in self:Iterator() do
        if(not unit:IsPlayer() and unit:IsOnline() and unit:IsRunningAddon() and not unit:IsSameGuild() and unit:IsSameTarget()) then
            chat = chat + 1
        end
    end
    return chat
end
--#endregion