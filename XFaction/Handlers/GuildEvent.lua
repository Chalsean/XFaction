local XFG, G = unpack(select(2, ...))
local ObjectName = 'GuildEvent'
local GetClubMembers = C_Club.GetClubMembers
local GuildRosterEvent = C_GuildInfo.GuildRoster
local GetGuildClubId = C_Club.GetGuildClubId
local GetPermissions = C_GuildInfo.GuildControlGetRankFlags

GuildEvent = Object:newChildConstructor()

--#region Constructors
function GuildEvent:new()
    local object = GuildEvent.parent.new(self)
    object.__name = ObjectName
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
        self:CallbackRosterUpdate()
        GuildRosterEvent()
        --XFG.Events:Add('GuildRole', 'CLUB_SELF_MEMBER_ROLE_UPDATED', XFG.Handlers.GuildEvent.CallbackGuildRole, true)
        --XFG.Events:Add('GuildLeave', 'CLUB_MEMBER_REMOVED', XFG.Handlers.GuildEvent.CallbackGuildLeave, true)
		self:IsInitialized(true)
	end
end
--#endregion

--#region Callbacks
-- The event doesn't tell you what has changed, only that something has changed
function GuildEvent:CallbackRosterUpdate()
    XFG:Trace(ObjectName, 'Scanning local guild roster')
    for _, memberID in pairs (GetClubMembers(XFG.Player.Guild:GetID(), XFG.Player.Guild:GetStreamID())) do
        local unitData = XFG.Confederate:Pop()
        try(function ()
            unitData:Initialize(memberID)
            if(unitData:IsInitialized()) then
                if(unitData:IsOnline()) then
                    -- If cache doesn't have unit, process
                    if(not XFG.Confederate:Contains(unitData:GetKey())) then
                        XFG.Confederate:Add(unitData)
                        XFG:Info(ObjectName, 'Added guild member via scan: %s', unitData:GetUnitName())
                        -- Don't notify if first scan seeing unit
                        if(XFG.Cache.FirstScan[memberID]) then
                            XFG.Frames.System:Display(XFG.Settings.Network.Message.Subject.LOGIN, unitData:GetName(), unitData:GetUnitName(), unitData:GetMainName(), unitData:GetGuild(), unitData:GetRealm())
                        end
                    else
                        local oldData = XFG.Confederate:Get(unitData:GetKey())
                        -- If the player is running addon, do not process
                        if(not oldData:IsRunningAddon() and not oldData:Equals(unitData)) then         
                            XFG.Confederate:Add(unitData)
                        else
                            XFG.Confederate:Push(unitData)
                        end
                    end
                -- They went offline and we scanned them before doing so
                elseif(XFG.Confederate:Contains(unitData:GetKey())) then
                    local oldData = XFG.Confederate:Get(unitData:GetKey())
                    XFG.Confederate:Push(unitData)
                    if(not oldData:IsPlayer()) then
                        XFG.Frames.System:Display(XFG.Settings.Network.Message.Subject.LOGOUT, oldData:GetName(), oldData:GetUnitName(), oldData:GetMainName(), oldData:GetGuild(), oldData:GetRealm())
                        XFG.Confederate:Remove(oldData:GetKey())
                    end                    
                else
                    if(unitData:HasRaiderIO()) then
                        XFG.Addons.RaiderIO:Remove(unitData:GetRaiderIO())
                    end
                    XFG.Confederate:Push(unitData)
                end

                if(XFG.Cache.FirstScan[memberID] == nil) then
                    XFG.Cache.FirstScan[memberID] = true
                end
            else
                if(unitData:HasRaiderIO()) then
                    XFG.Addons.RaiderIO:Remove(unitData:GetRaiderIO())
                end
                XFG.Confederate:Push(unitData)
            end
        end).
        catch(function (inErrorMessage)
            XFG:Warn(ObjectName, inErrorMessage)
        end)
    end
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