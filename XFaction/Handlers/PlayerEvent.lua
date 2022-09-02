local XFG, G = unpack(select(2, ...))
local ObjectName = 'PlayerEvent'

PlayerEvent = Object:newChildConstructor()

function PlayerEvent:new()
    local _Object = PlayerEvent.parent.new(self)
    _Object.__name = ObjectName
    return _Object
end

function PlayerEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFG.Events:Add('Covenant', 'COVENANT_CHOSEN', XFG.Handlers.PlayerEvent.CallbackPlayerChanged, false, false)
        XFG.Events:Add('Soulbind', 'SOULBIND_ACTIVATED', XFG.Handlers.PlayerEvent.CallbackPlayerChanged, true, false)
        XFG.Events:Add('Mythic', 'CHALLENGE_MODE_COMPLETED', XFG.Handlers.PlayerEvent.CallbackPlayerChanged, true, true)
        XFG.Events:Add('Spec', 'ACTIVE_TALENT_GROUP_CHANGED', XFG.Handlers.PlayerEvent.CallbackPlayerChanged, true, false)        
        XFG.Events:Add('Instance', 'PLAYER_ENTERING_WORLD', XFG.Handlers.PlayerEvent.CallbackInstance, true, false)
        XFG.Events:Add('EnterCombat', 'PLAYER_REGEN_DISABLED', XFG.Handlers.PlayerEvent.CallbackEnterCombat, true, true)
        XFG.Events:Add('LeaveCombat', 'PLAYER_REGEN_ENABLED', XFG.Handlers.PlayerEvent.CallbackLeaveCombat, true, true)
        XFG.Events:Add('Level', 'PLAYER_LEVEL_CHANGED', XFG.Handlers.PlayerEvent.CallbackPlayerChanged, false, false)
        XFG.Events:Add('Profession', 'SKILL_LINES_CHANGED', XFG.Handlers.PlayerEvent.CallbackSkillChanged, false, false)
        XFG.Events:Add('Zone', 'ZONE_CHANGED_NEW_AREA', XFG.Handlers.PlayerEvent.CallbackZoneChanged, false, false)

		self:IsInitialized(true)
	end
end

function PlayerEvent:CallbackPlayerChanged(inEvent) 
    try(function ()
        XFG.Player.Unit:Initialize(XFG.Player.Unit:GetID())
        --XFG:Info(ObjectName, 'Updated player data based on %s event', inEvent)

        if(inEvent ~= 'SOULBIND_ACTIVATED') then
            XFG.Player.Unit:Broadcast()
        end

        if(inEvent == 'COVENANT_CHOSEN' or inEvent == 'SOULBIND_ACTIVATED') then
            XFG.DataText.Soulbind:RefreshBroker()
        end
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
            local _ZoneName = GetRealZoneText()
            if(_ZoneName ~= nil and _ZoneName ~= XFG.Player.Unit:GetZone():GetName()) then
                local _Zone = XFG.Zones:Get(_ZoneName)
                if(_Zone == nil) then
                    _Zone = XFG.Zones:AddZone(_ZoneName)
                end
                XFG.Player.Unit:SetZone(_Zone)
                XFG:Info(ObjectName, 'Updated player data based on ZONE_CHANGED_NEW_AREA event')
                local _Event = XFG.Events:Get('Covenant')
                if(XFG.Player.Unit:GetZone():GetName() == 'Oribos') then
                    if(not _Event:IsEnabled()) then
                        _Event:Start()
                    end
                elseif(_Event:IsEnabled()) then
                    _Event:Stop()
                end
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
        local _UnitData = C_Club.GetMemberInfo(XFG.Player.Guild:GetID(), XFG.Player.Unit:GetID())
        if(_UnitData.profession1ID ~= nil) then
            local _Profession = XFG.Professions:Get(_UnitData.profession1ID)
            if(not _Profession:Equals(XFG.Player.Unit:GetProfession1())) then
                XFG.Player.Unit:Initialize(XFG.Player.Unit:GetID())
                XFG:Info(ObjectName, 'Updated player data based on SKILL_LINES_CHANGED event')
                XFG.Player.Unit:Broadcast()
                return
            end
        end

        if(_UnitData.profession2ID ~= nil) then
            local _Profession = XFG.Professions:Get(_UnitData.profession2ID)
            if(not _Profession:Equals(XFG.Player.Unit:GetProfession2())) then
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
        local _InInstance, _InstanceType = IsInInstance()
        -- Enter instance for first time
        if(_InInstance and not XFG.Player.InInstance) then
            XFG:Debug(ObjectName, 'Entering instance, disabling some event listeners and timers')
            XFG.Player.InInstance = true
            XFG.Events:EnterInstance()
            XFG.Timers:EnterInstance()
            if(not XFG.Config.Debug.Instance) then
                XFG:Debug(ObjectName, 'Disabling logging based on configuration')
                XFG.DebugFlag = false
            end

        -- Just leaving instance or UI reload
        elseif(not _InInstance and XFG.Player.InInstance) then
            XFG.DebugFlag = XFG.Config.Debug.Enable
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