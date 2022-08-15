local XFG, G = unpack(select(2, ...))
local ObjectName = 'GuildEvent'

GuildEvent = Object:newChildConstructor()

function GuildEvent:new()
    local _Object = GuildEvent.parent.new(self)
    _Object.__name = ObjectName
    return _Object
end

function GuildEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        -- This is the local guild roster scan for those not running the addon
        XFG:CreateEvent('Roster', 'GUILD_ROSTER_UPDATE', XFG.Handlers.GuildEvent.CallbackRosterUpdate, true, false)
        -- Hook player inviting someone, they will send broadcast if player joins
        hooksecurefunc('GuildInvite', function(inInvitee) XFG.Invites[inInvitee] = true end)
        XFG:Info(self:GetObjectName(), 'Post-hooked GuildInvite API')
        XFG:RegisterEvent('CLUB_MEMBER_ADDED', XFG.Handlers.GuildEvent.CallbackMemberJoined)
        XFG:Info(self:GetObjectName(), 'Registered for CLUB_MEMBER_ADDED events')
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

-- The event doesn't tell you what has changed, only that something has changed
function GuildEvent:CallbackRosterUpdate()
    for _, _MemberID in pairs (C_Club.GetClubMembers(XFG.Player.Guild:GetID(), XFG.Player.Guild:GetStreamID())) do
        try(function ()
            local _UnitData = Unit:new()
            _UnitData:Initialize(_MemberID)

            if(_UnitData:IsInitialized()) then
                if(_UnitData:IsOnline()) then
                    -- If cache doesn't have unit, process
                    if(not XFG.Confederate:Contains(_UnitData:GetKey())) then
                        XFG.Confederate:AddUnit(_UnitData)
                        -- Don't notify if first scan seeing unit
                        if(XFG.Cache.FirstScan[_MemberID]) then
                            XFG.Frames.System:Display(XFG.Settings.Network.Message.Subject.LOGIN, _UnitData:GetName(), _UnitData:GetUnitName(), _UnitData:GetMainName(), _UnitData:GetGuild(), _UnitData:GetRealm())
                        end
                    else
                        local _CachedUnitData = XFG.Confederate:GetObject(_UnitData:GetKey())
                        -- If the player is running addon, do not process
                        if(not _CachedUnitData:IsRunningAddon() and not _CachedUnitData:Equals(_UnitData)) then         
                            XFG.Confederate:AddUnit(_UnitData)
                        end
                    end
                -- They went offline and we scanned them before doing so
                elseif(XFG.Confederate:Contains(_UnitData:GetKey())) then
                    local _CachedUnitData = XFG.Confederate:GetObject(_UnitData:GetKey())
                    if(not _CachedUnitData:IsPlayer()) then
                        XFG.Confederate:RemoveUnit(_CachedUnitData:GetKey())
                        XFG.Frames.System:Display(XFG.Settings.Network.Message.Subject.LOGOUT, _CachedUnitData:GetName(), _CachedUnitData:GetUnitName(), _CachedUnitData:GetMainName(), _CachedUnitData:GetGuild(), _CachedUnitData:GetRealm())
                    end
                end

                if(XFG.Cache.FirstScan[_MemberID] == nil) then
                    XFG.Cache.FirstScan[_MemberID] = true
                end
            end
        end).
        catch(function (inErrorMessage)
            XFG:Warn(ObjectName, 'Failed to scan unit information [%d]: ' .. inErrorMessage, _MemberID)
        end)
    end
end

function GuildEvent:CallbackMemberJoined(inGuildID, inMemberID)
    try(function ()
        -- Technically probably dont need to check the guild id
        if(inGuildID == XFG.Player.Guild:GetID()) then
            local _UnitData = Unit:new()
            _UnitData:Initialize(inMemberID)
            -- Member that player invited joined, broadcast the join
            if(XFG.Cache.Invites[_UnitData:GetName()]) then
                XFG.Outbox:BroadcastUnitData(_UnitData, XFG.Settings.Network.Message.Subject.JOIN)
                XFG.Cache.Invites[_UnitData:GetName()] = nil
            end
        end
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, 'Failed to process new guild member: ' .. inErrorMessage)
    end)
end