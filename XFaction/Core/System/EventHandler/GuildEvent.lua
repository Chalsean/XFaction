local XF, G = unpack(select(2, ...))
local ObjectName = 'GuildEvent'
local GetClubMembers = C_Club.GetClubMembers
local GetGuildRoster = C_GuildInfo.GuildRoster
local GetGuildClubId = C_Club.GetGuildClubId
local GetPermissions = C_GuildInfo.GuildControlGetRankFlags
local ServerTime = GetServerTime

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
        XF.Events:Add({name = 'Roster', 
                        event = 'GUILD_ROSTER_UPDATE', 
                        callback = XF.Handlers.GuildEvent.CallbackRosterUpdate, 
                        instance = true,
                        groupDelta = XF.Settings.LocalGuild.ScanTimer})
        -- On initial login, the roster returned is incomplete, you have to force Blizz to do a guild roster refresh
        GetGuildRoster()
		self:IsInitialized(true)
	end
end
--#endregion

--#region Callbacks
-- The event doesn't tell you what has changed, only that something has changed. So you have to scan the whole roster
function GuildEvent:CallbackRosterUpdate()
    local self = XF.Handlers.GuildEvent
    XF:Trace(ObjectName, 'Scanning local guild roster')
    for _, memberID in pairs (GetClubMembers(XF.Player.Guild:GetID(), XF.Player.Guild:GetStreamID())) do
        local unitData = XF.Confederate:Pop()
        try(function ()
            unitData:Initialize(memberID)
            if(unitData:IsInitialized()) then
                if(XF.Confederate:Contains(unitData:GetKey())) then
                    local oldData = XF.Confederate:Get(unitData:GetKey())
                    if(oldData:IsOnline() and unitData:IsOffline()) then
                        XF:Info(ObjectName, 'Guild member logout via scan: %s', unitData:GetUnitName())
                        if(XF.Config.Chat.Login.Enable) then
                            XF.Frames.System:Display(XF.Enum.Message.LOGOUT, oldData:GetName(), oldData:GetUnitName(), oldData:GetMainName(), oldData:GetGuild())
                        end
                        XF.Confederate:Add(unitData)
                    elseif(unitData:IsOnline()) then
                        if(oldData:IsOffline()) then
                            XF:Info(ObjectName, 'Guild member login via scan: %s', unitData:GetUnitName())
                            if(XF.Config.Chat.Login.Enable) then
                                XF.Frames.System:Display(XF.Enum.Message.LOGIN, unitData:GetName(), unitData:GetUnitName(), unitData:GetMainName(), unitData:GetGuild())
                            end
                            XF.Confederate:Add(unitData)
                        elseif(not oldData:IsRunningAddon()) then
                            XF.Confederate:Add(unitData)
                        else
                            -- Every logic branch should either add, remove or push, otherwise there will be a memory leak
                            XF.Confederate:Push(unitData)
                        end
                    else
                        XF.Confederate:Push(unitData)
                    end
                -- First time scan (i.e. login) do not notify
                else
                    XF.Confederate:Add(unitData)
                end
            -- If it didnt initialize properly then we dont really know their status, so do nothing
            else
                XF.Confederate:Push(unitData)
            end
        end).
        catch(function (inErrorMessage)
            XF:Warn(ObjectName, inErrorMessage)
        end)
    end
    XF.DataText.Guild:RefreshBroker()
end