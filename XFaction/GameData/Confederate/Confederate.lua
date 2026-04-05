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
            name = 'Guild',
            event = 'PLAYER_GUILD_UPDATE',
            callback = XFO.Confederate.CallbackGuildChanged
        })

        XFO.Timers:Add({
            name = 'Heartbeat',
            delta = 60 * 2,
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
                if(not unit:IsPlayer()) then
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
            self:Add(unit)
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

    XF:Info(self:ObjectName(), 'Guild member login: %s', inUnit:UnitName())
    self:Add(inUnit)

    if(inUnit:IsPlayer()) then
        XF.Player.Unit = inUnit
    end

    XFO.DTGuild:RefreshBroker()
    XFO.DTLinks:RefreshBroker()
end

function XFC.Confederate:Logout(inGUID)
    assert(type(inGUID) == 'string')
    if (self:Contains(inGUID)) then

        local unit = self:Get(inGUID)
        XF:Info(self:ObjectName(), 'Guild member logout: %s', unit:UnitName())
        self:Remove(unit:Key())

        XFO.DTGuild:RefreshBroker()
        XFO.DTLinks:RefreshBroker()
    end
end

function XFC.Confederate:RefreshUnit(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')
    self:Add(inUnit)
end

function XFC.Confederate:CallbackHeartbeat() 
    local self = XFO.Confederate

    try(function ()
        local unit = XFC.Unit:new()
        unit:Initialize()
        self:Add(unit)
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
        if(IsInGuild()) then
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
                        ttl = 60 * 5,
                        start = true
                    })
                end
            end
        -- Player just left a guild
        elseif(not IsInGuild()) then
            XF:Warn(self:ObjectName(), 'Player is not in a guild')            
            XF:Stop()
            LeaveChannelByName(XF.Cache.Channel.Name)
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
    return self:Count()
end
--#endregion