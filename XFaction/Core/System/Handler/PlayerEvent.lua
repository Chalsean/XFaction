local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'PlayerEvent'
local GetMemberInfo = C_Club.GetMemberInfo

PlayerEvent = XFC.Object:newChildConstructor()

--#region Constructors
function PlayerEvent:new()
    local object = PlayerEvent.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function PlayerEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()

        XF.Events:Add({name = 'Mythic', 
                        event = 'CHALLENGE_MODE_COMPLETED', 
                        callback = XF.Handlers.PlayerEvent.CallbackPlayerChanged, 
                        instance = true})
        XF.Events:Add({name = 'Spec', 
                        event = 'ACTIVE_TALENT_GROUP_CHANGED', 
                        callback = XF.Handlers.PlayerEvent.CallbackPlayerChanged, 
                        instance = true})        
        XF.Events:Add({name = 'Instance', 
                        event = 'PLAYER_ENTERING_WORLD', 
                        callback = XF.Handlers.PlayerEvent.CallbackInstance, 
                        instance = true})
        XF.Events:Add({name = 'Level', 
                        event = 'PLAYER_LEVEL_CHANGED', 
                        callback = XF.Handlers.PlayerEvent.CallbackPlayerChanged})
        XF.Events:Add({name = 'Profession', 
                        event = 'SKILL_LINES_CHANGED', 
                        callback = XF.Handlers.PlayerEvent.CallbackSkillChanged})
        XF.Events:Add({name = 'Zone', 
                        event = 'ZONE_CHANGED_NEW_AREA', 
                        callback = XF.Handlers.PlayerEvent.CallbackZoneChanged})

		self:IsInitialized(true)
	end
end
--#endregion

--#region Callbacks
function PlayerEvent:CallbackPlayerChanged(inEvent) 
    try(function ()
        XF.Player.Unit:Initialize(XF.Player.Unit:ID())
        XF.Player.Unit:Broadcast()
    end).
    catch(function (inErrorMessage)
        XF:Warn(ObjectName, inErrorMessage)
    end)
end

-- Zone changes are kinda funky, during a zone change C_Club.GetMemberInfo returns a lot of nils
-- So use a different API, detect zone text change, only update that information and broadcast
function PlayerEvent:CallbackZoneChanged()
    if(XF.Initialized) then 
        try(function ()
            local zoneName = GetRealZoneText()
            if(zoneName ~= nil and zoneName ~= XF.Player.Unit:Zone():Name()) then
                if(not XFO.Zones:Contains(zoneName)) then
                    XFO.Zones:Add(zoneName)
                end
                XF.Player.Unit:Zone(XFO.Zones:Get(zoneName))
            end
        end).
        catch(function (inErrorMessage)
            XF:Warn(ObjectName, inErrorMessage)
        end)
    end
end

function PlayerEvent:CallbackSkillChanged()
    try(function ()
        -- We only care if player has learned/unlearned a profession, the rest is noise
        local unitData = GetMemberInfo(XF.Player.Guild:ID(), XF.Player.Unit:ID())
        if(unitData.profession1ID ~= nil) then
            local profession = XFO.Professions:Get(unitData.profession1ID)
            if(not profession:Equals(XF.Player.Unit:GetProfession1())) then
                XF.Player.Unit:Initialize(XF.Player.Unit:ID())
                XF:Info(ObjectName, 'Updated player data based on SKILL_LINES_CHANGED event')
                XF.Player.Unit:Broadcast()
                return
            end
        end

        if(unitData.profession2ID ~= nil) then
            local profession = XFO.Professions:Get(unitData.profession2ID)
            if(not profession:Equals(XF.Player.Unit:GetProfession2())) then
                XF.Player.Unit:Initialize(XF.Player.Unit:ID())
                XF:Info(ObjectName, 'Updated player data based on SKILL_LINES_CHANGED event')
                XF.Player.Unit:Broadcast()
                return
            end
        end
    end).
    catch(function (inErrorMessage)
        XF:Warn(ObjectName, inErrorMessage)
    end)
end

function PlayerEvent:CallbackInstance()
    try(function ()
        local inInstance = IsInInstance()
        -- Enter instance for first time
        if(inInstance and not XF.Player.InInstance) then
            XF:Debug(ObjectName, 'Entering instance, disabling some event listeners and timers')
            XF.Player.InInstance = true
            XF.Events:EnterInstance()
            XF.Timers:EnterInstance()

        -- Just leaving instance or UI reload
        elseif(not inInstance and XF.Player.InInstance) then
            XF:Debug(ObjectName, 'Leaving instance, enabling some event listeners and timers')
            XF.Player.InInstance = false
            XF.Events:LeaveInstance()
            XF.Timers:LeaveInstance()            
        end
    end).
    catch(function (inErrorMessage)
        XF:Warn(ObjectName, inErrorMessage)
    end)
end
--#endregion