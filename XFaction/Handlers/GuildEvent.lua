local XFG, G = unpack(select(2, ...))
local ObjectName = 'GuildEvent'

local GetClubMembers = C_Club.GetClubMembers

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
        -- hooksecurefunc('GuildInvite', function(inInvitee) XFG.Invites[inInvitee] = true end)
        -- XFG:Info(ObjectName, 'Post-hooked GuildInvite API')
        -- XFG:RegisterEvent('CLUB_MEMBER_ADDED', XFG.Handlers.GuildEvent.CallbackMemberJoined)
        -- XFG:Info(ObjectName, 'Registered for CLUB_MEMBER_ADDED events')
		self:IsInitialized(true)
	end
end

-- The event doesn't tell you what has changed, only that something has changed
function GuildEvent:CallbackRosterUpdate()
    for _, _MemberID in pairs (GetClubMembers(XFG.Player.Guild:GetID(), XFG.Player.Guild:GetStreamID())) do
        try(function ()
            local _UnitData = XFG.Factories.Unit:CheckOut()
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
                        else
                            XFG.Factories.Unit:CheckIn(_UnitData)
                        end
                    end
                -- They went offline and we scanned them before doing so
                elseif(XFG.Confederate:Contains(_UnitData:GetKey())) then
                    local _CachedUnitData = XFG.Confederate:GetObject(_UnitData:GetKey())
                    XFG.Factories.Unit:CheckIn(_UnitData)
                    if(not _CachedUnitData:IsPlayer()) then
                        XFG.Frames.System:Display(XFG.Settings.Network.Message.Subject.LOGOUT, _CachedUnitData:GetName(), _CachedUnitData:GetUnitName(), _CachedUnitData:GetMainName(), _CachedUnitData:GetGuild(), _CachedUnitData:GetRealm())
                        XFG.Confederate:RemoveUnit(_CachedUnitData:GetKey())
                    end                    
                else
                    XFG.Factories.Unit:CheckIn(_UnitData)
                end

                if(XFG.Cache.FirstScan[_MemberID] == nil) then
                    XFG.Cache.FirstScan[_MemberID] = true
                end
            else
                XFG.Factories.Unit:CheckIn(_UnitData)
            end
        end).
        catch(function (inErrorMessage)
            XFG:Warn(ObjectName, inErrorMessage)
        end)
    end
end

function GuildEvent:CallbackMemberJoined(inGuildID, inMemberID)
    local _UnitData = nil
    try(function ()
        -- Technically probably dont need to check the guild id
        if(inGuildID == XFG.Player.Guild:GetID()) then
            _UnitData = XFG.Factories.Unit:CheckOut()
            _UnitData:Initialize(inMemberID)
            -- Member that player invited joined, broadcast the join
            if(XFG.Cache.Invites[_UnitData:GetName()]) then
                XFG.Outbox:BroadcastUnitData(_UnitData, XFG.Settings.Network.Message.Subject.JOIN)
                XFG.Cache.Invites[_UnitData:GetName()] = nil
            end
        end
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end).
    finally(function ()
        XFG.Factories.Unit:CheckIn(_UnitData)
    end)
end