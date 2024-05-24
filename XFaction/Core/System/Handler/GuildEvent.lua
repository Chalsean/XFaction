local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'GuildEvent'
local GetClubMembers = C_Club.GetClubMembers
local GetGuildRoster = C_GuildInfo.GuildRoster
local GetGuildClubId = C_Club.GetGuildClubId
local GetPermissions = C_GuildInfo.GuildControlGetRankFlags
local ServerTime = GetServerTime

GuildEvent = XFC.Object:newChildConstructor()

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
    for _, memberID in pairs (GetClubMembers(XF.Player.Guild:ID(), XF.Player.Guild:StreamID())) do
        local unitData = XFO.Confederate:Pop()
        try(function ()
            unitData:Initialize(memberID)
            if(unitData:IsInitialized()) then
                if(XFO.Confederate:Contains(unitData:Key())) then
                    local oldData = XFO.Confederate:Get(unitData:Key())
                    if(oldData:IsOnline() and unitData:IsOffline()) then
                        XF:Info(ObjectName, 'Guild member logout via scan: %s', unitData:GetUnitName())
                        if(XF.Config.Chat.Login.Enable) then
                            XF.Frames.System:Display(XF.Enum.Message.LOGOUT, oldData:Name(), oldData:GetUnitName(), oldData:GetMainName(), oldData:GetGuild(), nil, oldData:GetFaction())
                        end
                        XFO.Confederate:Add(unitData)
                    elseif(unitData:IsOnline()) then
                        if(oldData:IsOffline()) then
                            XF:Info(ObjectName, 'Guild member login via scan: %s', unitData:GetUnitName())
                            if(XF.Config.Chat.Login.Enable) then
                                XF.Frames.System:Display(XF.Enum.Message.LOGIN, unitData:Name(), unitData:GetUnitName(), unitData:GetMainName(), unitData:GetGuild(), nil, unitData:GetFaction())
                            end
                            XFO.Confederate:Add(unitData)
                        elseif(not oldData:IsRunningAddon()) then
                            XFO.Confederate:Add(unitData)
                        else
                            -- Every logic branch should either add, remove or push, otherwise there will be a memory leak
                            XFO.Confederate:Push(unitData)
                        end
                    else
                        XFO.Confederate:Push(unitData)
                    end
                -- First time scan (i.e. login) do not notify
                else
                    XFO.Confederate:Add(unitData)
                end
            -- If it didnt initialize properly then we dont really know their status, so do nothing
            else
                XFO.Confederate:Push(unitData)
            end
        end).
        catch(function (inErrorMessage)
            XF:Warn(ObjectName, inErrorMessage)
        end)
    end
    XF.DataText.Guild:RefreshBroker()
end