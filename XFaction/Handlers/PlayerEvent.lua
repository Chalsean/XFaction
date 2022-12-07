local XFG, G = unpack(select(2, ...))
local ObjectName = 'PlayerEvent'
local GetMemberInfo = C_Club.GetMemberInfo

PlayerEvent = Object:newChildConstructor()

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

        XFG.Events:Add('Mythic', 'CHALLENGE_MODE_COMPLETED', XFG.Handlers.PlayerEvent.CallbackPlayerChanged, true, true)
        XFG.Events:Add('Spec', 'ACTIVE_TALENT_GROUP_CHANGED', XFG.Handlers.PlayerEvent.CallbackPlayerChanged, true, false)        
        XFG.Events:Add('Instance', 'PLAYER_ENTERING_WORLD', XFG.Handlers.PlayerEvent.CallbackInstance, true, false)
        XFG.Events:Add('Level', 'PLAYER_LEVEL_CHANGED', XFG.Handlers.PlayerEvent.CallbackPlayerChanged, false, false)
        XFG.Events:Add('Profession', 'SKILL_LINES_CHANGED', XFG.Handlers.PlayerEvent.CallbackSkillChanged, false, false)
        XFG.Events:Add('Zone', 'ZONE_CHANGED_NEW_AREA', XFG.Handlers.PlayerEvent.CallbackZoneChanged, false, false)

		self:IsInitialized(true)
	end
end
--#endregion

--#region Callbacks
function PlayerEvent:CallbackPlayerChanged(inEvent) 
    try(function ()
        XFG.Player.Unit:Initialize(XFG.Player.Unit:GetID())
        --XFG:Info(ObjectName, 'Updated player data based on %s event', inEvent)
        XFG.Player.Unit:Broadcast()
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)
end

-- Zone changes are kinda funky, during a zone change C_Club.GetMemberInfo returns a lot of nils
-- So use a different API, detect zone text change, only update that information and broadcast
function PlayerEvent:CallbackZoneChanged()
    if(XFG.Initialized) then 
        try(function ()
            local zoneName = GetRealZoneText()
            if(zoneName ~= nil and zoneName ~= XFG.Player.Unit:GetZone():GetName()) then
                local zone = XFG.Zones:Get(zoneName)
                if(zone == nil) then
                    zone = XFG.Zones:AddZone(zoneName)
                end
                XFG.Player.Unit:SetZone(zone)
                --XFG:Info(ObjectName, 'Updated player data based on ZONE_CHANGED_NEW_AREA event')
            end
        end).
        catch(function (inErrorMessage)
            XFG:Warn(ObjectName, inErrorMessage)
        end)
    end
end

function PlayerEvent:CallbackSkillChanged()
    try(function ()
        -- We only care if player has learned/unlearned a profession, the rest is noise
        local unitData = GetMemberInfo(XFG.Player.Guild:GetID(), XFG.Player.Unit:GetID())
        if(unitData.profession1ID ~= nil) then
            local profession = XFG.Professions:Get(unitData.profession1ID)
            if(not profession:Equals(XFG.Player.Unit:GetProfession1())) then
                XFG.Player.Unit:Initialize(XFG.Player.Unit:GetID())
                XFG:Info(ObjectName, 'Updated player data based on SKILL_LINES_CHANGED event')
                XFG.Player.Unit:Broadcast()
                return
            end
        end

        if(unitData.profession2ID ~= nil) then
            local profession = XFG.Professions:Get(unitData.profession2ID)
            if(not profession:Equals(XFG.Player.Unit:GetProfession2())) then
                XFG.Player.Unit:Initialize(XFG.Player.Unit:GetID())
                XFG:Info(ObjectName, 'Updated player data based on SKILL_LINES_CHANGED event')
                XFG.Player.Unit:Broadcast()
                return
            end
        end
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)
end

function PlayerEvent:CallbackInstance()
    try(function ()
        local inInstance = IsInInstance()
        -- Enter instance for first time
        if(inInstance and not XFG.Player.InInstance) then
            XFG:Debug(ObjectName, 'Entering instance, disabling some event listeners and timers')
            XFG.Player.InInstance = true
            XFG.Events:EnterInstance()
            XFG.Timers:EnterInstance()

        -- Just leaving instance or UI reload
        elseif(not inInstance and XFG.Player.InInstance) then
            XFG:Debug(ObjectName, 'Leaving instance, enabling some event listeners and timers')
            XFG.Player.InInstance = false
            XFG.Events:LeaveInstance()
            XFG.Timers:LeaveInstance()            
        end
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)
end

-- Entering combat in an instance, disable as much messaging as we can to not interfere
-- An instance is raid, dungeon, bg, arena
function PlayerEvent:CallbackEnterCombat()
    if(XFG.Player.InInstance) then
        try(function ()
            XFG:Debug(ObjectName, 'Entering instance combat, disabling some event listeners and timers')
            XFG.Events:EnterCombat()
            XFG.Timers:EnterCombat()
        end).
        catch(function (inErrorMessage)
            XFG:Warn(ObjectName, inErrorMessage)
        end)
    end
end

-- Reenable things and fire if its been too long
function PlayerEvent:CallbackLeaveCombat()
    try(function ()
        if(XFG.Player.InInstance) then
            XFG:Debug(ObjectName, 'Leaving instance combat, enabling some event listeners and timers')
            XFG.Events:LeaveCombat()
            XFG.Timers:LeaveCombat()
        end
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)
end
--#endregion