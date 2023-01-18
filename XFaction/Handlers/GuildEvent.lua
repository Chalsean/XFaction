local XFG, G = unpack(select(2, ...))
local ObjectName = 'GuildEvent'
local GetClubMembers = C_Club.GetClubMembers
local GuildRosterEvent = C_GuildInfo.GuildRoster
local GetGuildClubId = C_Club.GetGuildClubId
local GetPermissions = C_GuildInfo.GuildControlGetRankFlags
local ServerTime = GetServerTime

GuildEvent = Object:newChildConstructor()

--#region Constructors
function GuildEvent:new()
    local object = GuildEvent.parent.new(self)
    object.__name = ObjectName
    object.lastScan = 0
    object.eventFired = false
    return object
end
--#endregion

--#region Initializers
function GuildEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        -- This is the local guild roster scan for those not running the addon
        XFG.Events:Add('Roster', 'GUILD_ROSTER_UPDATE', XFG.Handlers.GuildEvent.CallbackRosterUpdate, true)
        -- On initial login, the roster returned is incomplete, you have to force Blizz to do a guild roster refresh
        self:EventFired(true)
        GuildRosterEvent()
		self:IsInitialized(true)
	end
end
--#endregion

--#region Accessors
function GuildEvent:GetLastScan()
    return self.lastScan
end

function GuildEvent:SetLastScan(inEpochTime)
    assert(type(inEpochTime) == 'number')
    self.lastScan = inEpochTime
end

function GuildEvent:EventFired(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self.eventFired = inBoolean
    end
    return self.eventFired
end

function GuildEvent:ShouldScan()
    return self:EventFired() and self:GetLastScan() + XFG.Settings.LocalGuild.ScanTimer <= ServerTime()
end
--#endregion

--#region Callbacks
-- The event doesn't tell you what has changed, only that something has changed. So you have to scan the whole roster
function GuildEvent:CallbackRosterUpdate()
    local self = XFG.Handlers.GuildEvent
    self:EventFired(true)
    if(not self:ShouldScan()) then return end

    XFG:Trace(ObjectName, 'Scanning local guild roster')
    for _, memberID in pairs (GetClubMembers(XFG.Player.Guild:GetID(), XFG.Player.Guild:GetStreamID())) do
        local unitData = XFG.Confederate:Pop()
        try(function ()
            unitData:Initialize(memberID)
            if(unitData:IsInitialized()) then
                if(XFG.Confederate:Contains(unitData:GetKey())) then
                    local oldData = XFG.Confederate:Get(unitData:GetKey())
                    if(oldData:IsOffline() and unitData:IsOnline()) then
                        XFG:Info(ObjectName, 'Guild member login via scan: %s', unitData:GetUnitName())
                        XFG.Frames.System:Display(XFG.Settings.Network.Message.Subject.LOGIN, unitData:GetName(), unitData:GetUnitName(), unitData:GetMainName(), unitData:GetGuild(), unitData:GetRealm())
                        XFG.Confederate:Add(unitData)
                    elseif(oldData:IsOnline() and unitData:IsOffline()) then
                        XFG:Info(ObjectName, 'Guild member logout via scan: %s', unitData:GetUnitName())
                        XFG.Frames.System:Display(XFG.Settings.Network.Message.Subject.LOGOUT, oldData:GetName(), oldData:GetUnitName(), oldData:GetMainName(), oldData:GetGuild(), oldData:GetRealm())
                        XFG.Confederate:Add(unitData)
                    elseif(not oldData:IsRunningAddon()) then
                        XFG.Confederate:Add(unitData)
                    end
                -- First time scan (i.e. login) do not notify
                else
                    XFG.Confederate:Add(unitData)
                end
            -- If it didnt initialize properly then we dont really know their status, so do nothing
            else
                XFG.Confederate:Push(unitData)
            end
        end).
        catch(function (inErrorMessage)
            XFG:Warn(ObjectName, inErrorMessage)
        end)
    end
    XFG.DataText.Guild:RefreshBroker()
    self:SetLastScan(ServerTime())
    self:EventFired(false)
end

function GuildEvent:CallbackGuildRole(inClubID, inRoleID)
    try(function ()
        -- Possible that guild chat ability has been revoked
        if(GetGuildClubId() == inClubID) then
            local permissions = GetPermissions(inRoleID)
            if(permissions ~= nil) then
                XFG.Player.Unit:CanGuildListen(permissions[1])
                XFG.Player.Unit:CanGuildSpeak(permissions[2])
            end
        end
    end).
    catch(function (inErrorMessage)
        XFG:Error(ObjectName, inErrorMessage)
        XFG:Stop()
        XFG.Timers:Get('Login'):Start()
    end)
end

-- function GuildEvent:CallbackGuildLeave()
--     try(function ()
--         if(GetGuildClubId() == nil) then
--             print(format(XFG.Lib.Locale['LEAVE_GUILD'], XFG.Title))
--             XFG:Stop()
--             XFG.Confederate:RemoveAll()
--             XFG.Nodes:RemoveAll()
--             XFG.Timers:Get('Login'):Start()    
--         end
--     end).
--     catch(function (inErrorMessage)
--         XFG:Error(ObjectName, inErrorMessage)
--     end)
-- end

-- function GuildEvent:CallbackGuildJoin()
--     try(function ()
--         XFG.Timers:Remove('GuildJoin')
--         XFG.Timers:Get('Login'):Start()
--     end).
--     catch(function (inErrorMessage)
--         XFG:Error(ObjectName, inErrorMessage)
--     end)
-- end
--#endregion