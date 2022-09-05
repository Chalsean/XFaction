local XFG, G = unpack(select(2, ...))
local ObjectName = 'GuildEvent'
local GetClubMembers = C_Club.GetClubMembers
local GuildRosterEvent = C_GuildInfo.GuildRoster

GuildEvent = Object:newChildConstructor()

function GuildEvent:new()
    local object = GuildEvent.parent.new(self)
    object.__name = ObjectName
    return object
end

function GuildEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        -- This is the local guild roster scan for those not running the addon
        XFG.Events:Add('Roster', 'GUILD_ROSTER_UPDATE', XFG.Handlers.GuildEvent.CallbackRosterUpdate, true, false)
        -- On initial login, the roster returned is incomplete, you have to force Blizz to do a guild roster refresh
        GuildRosterEvent()
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
    XFG:Info(ObjectName, 'Scanning local guild roster')
    for _, memberID in pairs (GetClubMembers(XFG.Player.Guild:GetID(), XFG.Player.Guild:GetStreamID())) do
        local unitData = XFG.Confederate:Pop()
        try(function ()            
            unitData:Initialize(memberID)
            if(unitData:IsInitialized()) then
                if(unitData:IsOnline()) then
                    -- If cache doesn't have unit, process
                    if(not XFG.Confederate:Contains(unitData:GetKey())) then
                        XFG.Confederate:Add(unitData)
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
                    XFG.Confederate:Push(unitData)
                end

                if(XFG.Cache.FirstScan[memberID] == nil) then
                    XFG.Cache.FirstScan[memberID] = true
                end
            else
                XFG.Confederate:Push(unitData)
            end
        end).
        catch(function (inErrorMessage)
            XFG:Warn(ObjectName, inErrorMessage)
        end).
    	finally(function ()
    		if(unitData and unitData:IsPlayer()) then
    			unitData:Print()          
    		end
    	end)
    end
end

function GuildEvent:CallbackMemberJoined(inGuildID, inMemberID)
    local unitData = nil
    try(function ()
        -- Technically probably dont need to check the guild id
        if(inGuildID == XFG.Player.Guild:GetID()) then
            unitData = XFG.Confederate:Pop()
            unitData:Initialize(inMemberID)
            -- Member that player invited joined, broadcast the join
            if(XFG.Cache.Invites[unitData:GetName()]) then
                XFG.Outbox:BroadcastUnitData(unitData, XFG.Settings.Network.Message.Subject.JOIN)
                XFG.Cache.Invites[unitData:GetName()] = nil
            end
        end
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end).
    finally(function ()
        XFG.Confederate:Push(unitData)
    end)
end