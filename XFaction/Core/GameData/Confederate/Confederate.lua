local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Confederate'

XFC.Confederate = XFC.Factory:newChildConstructor()

--#region Constructors
function XFC.Confederate:new()
    local object = XFC.Confederate.parent.new(self)
	object.__name = ObjectName
    object.onlineCount = 0
    object.localGuildMember = nil
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
        self.localGuildMember = {}

        XFO.Events:Add({
            name = 'Roster', 
            event = 'CLUB_MEMBER_PRESENCE_UPDATED', 
            callback = XFO.Confederate.CallbackGuildMemberChanged, 
            instance = true
        })

        -- This here because there isnt a good place for it
        -- Will move somewhere else in the future
        XFO.Events:Add({
            name = 'Level', 
            event = 'PLAYER_LEVEL_CHANGED', 
            callback = XFO.Confederate.CallbackPlayerChanged
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

--#region Properties
function XFC.Confederate:OnlineCount()
    local count = 0
    for _, guild in XFO.Guilds:Iterator() do
        count = count + guild:Count()
    end
    return count
end
--#endregion

--#region Methods
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
        local unit = self:Pop()
        try(function ()
            unit:Deserialize(data)
            self:OnlineUnit(unit)
            XF:Info(self:ObjectName(), '  Restored %s unit information from backup', unit:UnitName())
        end).
        catch(function (err)
            XF:Warn(self:ObjectName(), err)
            self:Push(unit)
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
        self:Replace(inUnit)
    else
        inUnit:LoginEpoch(XFF.TimeCurrent())
        self:Add(inUnit)
    end

    if(inUnit:IsOnline()) then
        inUnit:Guild():Add(inUnit)
        XFO.DTGuild:RefreshBroker()
    end
    
    if(inUnit:IsSameGuild()) then
        self.localGuildMember[inUnit:ID()] = inUnit
    end

    if(inUnit:IsPlayer()) then
        XF.Player.Unit = inUnit
        return
    end
    
    -- This is messy af, need to find a better way of tracking/querying
    -- Target count == # of addon users outside the guild in the chat channel
    if(inUnit:CanChat() and not inUnit:IsSameGuild()) then
        inUnit:Target():Add(inUnit)
    end

    -- Guild channel count == # of addon users inside the guild
    -- Local channel count == # of addon users both in guild and in chat channel
    if(inUnit:IsOnline() and inUnit:IsRunningAddon() and inUnit:IsSameGuild()) then
        XFO.Channels:GuildChannel():Add(inUnit)
        if(inUnit:CanChat()) then
            XFO.Channels:LocalChannel():Add(inUnit)
        end            
    end

    XFO.DTLinks:RefreshBroker()   
end

function XFC.Confederate:OfflineUnit(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')

    inUnit:Guild():Remove(inUnit:Key())
    inUnit:Target():Remove(inUnit:Key())
    XFO.Channels:LocalChannel():Remove(inUnit:Key())
    XFO.Channels:GuildChannel():Remove(inUnit:Key())

    if(inUnit:IsSameGuild()) then
        self.localGuildMember[inUnit:ID()] = inUnit
    end

    self:Remove(inUnit:Key())
    self:Push(inUnit)

    XFO.DTLinks:RefreshBroker()
    XFO.DTGuild:RefreshBroker()
end

function XFC.Confederate:CallbackScan()
    local self = XFO.Confederate
    XF:Trace(self:ObjectName(), 'Scanning local guild roster')
    for _, memberID in pairs (XFF.GuildMembers(XF.Player.Guild:ID())) do

        if(self.localGuildMember[memberID] ~= nil) then

        end

        local unit = self:Pop()
        try(function ()
            if(self.localGuildMember[memberID] == nil or 
              (self.localGuildMember[memberID]:IsOnline() and
               not self.localGuildMember[memberID]:IsRunningAddon())) then
                unit:Initialize(memberID)
                if(unit:IsInitialized()) then
                    self.localGuildMember[unit:ID()] = unit
                    if(unit:IsOnline()) then
                        self:OnlineUnit(unit)
                    end
                else
                    self:Push(unit)
                end
            end
        end).
        catch(function (err)
            XF:Warn(self:ObjectName(), err)
            self:Push(unit)
        end)
    end
end

function XFC.Confederate:CallbackGuildMemberChanged(inGuildID, inMemberID, inPresence)
    local self = XFO.Confederate
    if(inGuildID ~= XF.Player.Guild:ID()) then return end
    if(inPresence == Enum.ClubMemberPresence.Unknown or inPresence == Enum.ClubMemberPresence.OnlineMobile) then return end

    local unit = self:Pop()
    try(function ()
        unit:Initialize(inMemberID)
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
                    else
                        self:Push(unit)
                    end
                else
                    self:Push(unit)
                end
            -- Guild member joined
            elseif(unit:IsOnline()) then
                self:OnlineUnit(unit)
            else
                self:Push(unit)
            end
        else
            self:Push(unit)
        end
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
        self:Push(unit)
    end)
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
        if(not unit:IsSameGuild()) then
            self:Logout(unit)
        end
    end
end

function XFC.Confederate:CallbackPlayerChanged(inEvent) 
    local self = XFO.Confederate
    try(function ()
        XF.Player.Unit:Initialize(XF.Player.Unit:ID())
        XFO.Mailbox:SendDataMessage()
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)
end

function XFC.Confederate:CallbackHeartbeat() 
    local self = XFO.Confederate
    try(function ()
        XFO.Mailbox:SendDataMessage()
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)
end

function XFC.Confederate:CallbackGuildChanged(inEvent, inUnitID) 
    local self = XFO.Confederate
    XF:Debug(self:ObjectName(), 'Guild update event fired [%s]', inUnitID)
    try(function ()
        -- Player just joined a guild
        if(XFF.PlayerIsInGuild()) then
            XF:Debug(self:ObjectName(), 'Player is in a guild')
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
            XF:Debug(self:ObjectName(), 'Player is not in a guild')
            XF:Stop()
            self:RemoveAll()
            XFO.Channels:LocalChannel():RemoveAll()
            XFO.Channels:GuildChannel():RemoveAll()

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
--#endregion