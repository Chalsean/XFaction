local XF, G = unpack(select(2, ...))
local ObjectName = 'GuildEvent'
local GetGuildMembers = C_Club.GetClubMembers
local QueryServer = C_GuildInfo.GuildRoster

XFC.GuildEvent = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.GuildEvent:new()
    local object = XFC.GuildEvent.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function XFC.GuildEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        -- This is the local guild roster scan for those not running the addon
        XFO.Events:Add({name = 'Roster', 
                        event = 'GUILD_ROSTER_UPDATE', 
                        callback = XFO.GuildEvent.CallbackRosterUpdate, 
                        instance = true,
                        groupDelta = XF.Settings.LocalGuild.ScanTimer})
        -- On initial login, the roster returned is incomplete, you have to force Blizz to do a guild roster refresh
        QueryServer()
		self:IsInitialized(true)
	end
end
--#endregion

--#region Callbacks
-- The event doesn't tell you what has changed, only that something has changed. So you have to scan the whole roster
function XFC.GuildEvent:CallbackRosterUpdate()
    local self = XFO.GuildEvent
    XF:Trace(self:GetObjectName(), 'Scanning local guild roster')
    for _, memberID in pairs (GetGuildMembers(XF.Player.Guild:GetID(), XF.Player.Guild:GetStreamID())) do
        local unit = nil
        try(function ()
            unit = XFO.Confederate:Pop()
            unit:Initialize(memberID)
            if(unit:IsInitialized()) then
                if(XFO.Confederate:Contains(unit:GetKey())) then
                    local old = XFO.Confederate:Get(unit:GetKey())
                    if(old:IsOnline() and unit:IsOffline()) then
                        XF:Info(self:GetObjectName(), 'Guild member logout via scan: %s', unit:GetUnitName())
                        if(XF.Config.Chat.Login.Enable) then
                            XFO.SystemFrame:Display(XF.Enum.Message.LOGOUT, old:GetName(), old:GetUnitName(), old:GetMainName(), old:GetGuild())
                        end
                        XFO.Confederate:Add(unit)
                    elseif(unit:IsOnline()) then
                        if(old:IsOffline()) then
                            XF:Info(self:GetObjectName(), 'Guild member login via scan: %s', unit:GetUnitName())
                            if(XF.Config.Chat.Login.Enable) then
                                XFO.SystemFrame:Display(XF.Enum.Message.LOGIN, unit:GetName(), unit:GetUnitName(), unit:GetMainName(), unit:GetGuild())
                            end
                            XFO.Confederate:Add(unit)
                        elseif(not old:IsRunningAddon()) then
                            XFO.Confederate:Add(unit)
                        else
                            -- Every logic branch should either add, remove or push, otherwise there will be a memory leak
                            XFO.Confederate:Push(unit)
                        end
                    else
                        XFO.Confederate:Push(unit)
                    end
                -- First time scan (i.e. login) do not notify
                else
                    XFO.Confederate:Add(unit)
                end
            -- If it didnt initialize properly then we dont really know their status, so do nothing
            else
                XFO.Confederate:Push(unit)
            end
        end).
        catch(function (err)
            XF:Warn(self:GetObjectName(), err)
            XFO.Confederate:Push(unit)
        end)
    end
    XFO.DTGuild:RefreshBroker()
end