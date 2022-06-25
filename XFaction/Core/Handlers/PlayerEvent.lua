local XFG, G = unpack(select(2, ...))
local ObjectName = 'PlayerEvent'
local LogCategory = 'HEPlayer'

PlayerEvent = {}

function PlayerEvent:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Initialized = false

    return Object
end



function PlayerEvent:Initialize()
	if(self:IsInitialized() == false) then

        XFG:CreateEvent('Covenant', 'COVENANT_CHOSEN', XFG.Handlers.PlayerEvent.CallbackPlayerChanged, false, false)
        XFG:CreateEvent('Soulbind', 'SOULBIND_ACTIVATED', XFG.Handlers.PlayerEvent.CallbackPlayerChanged, true, false)
        XFG:CreateEvent('Spec', 'ACTIVE_TALENT_GROUP_CHANGED', XFG.Handlers.PlayerEvent.CallbackPlayerChanged, true, false)
        XFG:CreateEvent('Mythic', 'CHALLENGE_MODE_COMPLETED', XFG.Handlers.PlayerEvent.CallbackPlayerChanged, true, true)
        XFG:CreateEvent('Instance', 'PLAYER_ENTERING_WORLD', XFG.Handlers.PlayerEvent.CallbackInstance, true, false)
        XFG:CreateEvent('EnterCombat', 'PLAYER_REGEN_DISABLED', XFG.Handlers.PlayerEvent.CallbackEnterCombat, true, true)
        XFG:CreateEvent('LeaveCombat', 'PLAYER_REGEN_ENABLED', XFG.Handlers.PlayerEvent.CallbackLeaveCombat, true, true)
        XFG:CreateEvent('Level', 'PLAYER_LEVEL_CHANGED', XFG.Handlers.PlayerEvent.CallbackPlayerChanged, false, false)
        XFG:CreateEvent('Profession', 'SKILL_LINES_CHANGED', XFG.Handlers.PlayerEvent.CallbackSkillChanged, false, false)
        XFG:CreateEvent('Zone', 'ZONE_CHANGED_NEW_AREA', XFG.Handlers.PlayerEvent.CallbackZoneChanged, false, false)

		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function PlayerEvent:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function PlayerEvent:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function PlayerEvent:CallbackPlayerChanged(inEvent) 
    XFG.Player.Unit:Initialize(XFG.Player.Unit:GetID())
    XFG:Info(LogCategory, 'Updated player data based on %s event', inEvent)

    if(inEvent ~= 'SOULBIND_ACTIVATED') then
        XFG.Outbox:BroadcastUnitData(XFG.Player.Unit)
        XFG.DataText.Guild:RefreshBroker()
    end

    if(inEvent == 'COVENANT_CHOSEN' or inEvent == 'SOULBIND_ACTIVATED') then
        XFG.DataText.Soulbind:RefreshBroker()
    end
end

-- Zone changes are kinda funky, during a zone change C_Club.GetMemberInfo returns a lot of nils
-- So use a different API, detect zone text change, only update that information and broadcast
function PlayerEvent:CallbackZoneChanged()
    if(XFG.Initialized) then 
        local _Zone = GetZoneText()
        if(_Zone ~= nil and _Zone ~= XFG.Player.Unit:GetZone()) then
            XFG.Player.Unit:SetZone(_Zone)
            XFG:Info(LogCategory, 'Updated player data based on ZONE_CHANGED_NEW_AREA event')
            --XFG.Outbox:BroadcastUnitData(XFG.Player.Unit)
            XFG.DataText.Guild:RefreshBroker()
            local _Event = XFG.Events:GetEvent('Covenant')
            if(XFG.Player.Unit:GetZone() == 'Oribos') then
                if(_Event:IsEnabled() == false) then
                    _Event:Start()
                end
            elseif(_Event:IsEnabled()) then
                _Event:Stop()
            end
        end
    end
end

function PlayerEvent:CallbackSkillChanged()
    -- We only care if player has learned/unlearned a profession, the rest is noise
    local _UnitData = C_Club.GetMemberInfo(XFG.Player.Guild:GetID(), XFG.Player.Unit:GetID())
    if(_UnitData.profession1ID ~= nil) then
        local _Profession = XFG.Professions:GetProfession(_UnitData.profession1ID)
        if(_Profession:Equals(XFG.Player.Unit:GetProfession1()) == false) then
            XFG.Player.Unit:Initialize(XFG.Player.Unit:GetID())
            XFG:Info(LogCategory, 'Updated player data based on SKILL_LINES_CHANGED event')
            XFG.Outbox:BroadcastUnitData(XFG.Player.Unit)
            XFG.DataText.Guild:RefreshBroker()
            return
        end
    end

    if(_UnitData.profession2ID ~= nil) then
        local _Profession = XFG.Professions:GetProfession(_UnitData.profession2ID)
        if(_Profession:Equals(XFG.Player.Unit:GetProfession2()) == false) then
            XFG.Player.Unit:Initialize(XFG.Player.Unit:GetID())
            XFG:Info(LogCategory, 'Updated player data based on SKILL_LINES_CHANGED event')
            XFG.Outbox:BroadcastUnitData(XFG.Player.Unit)
            XFG.DataText.Guild:RefreshBroker()
            return
        end
    end
end

function PlayerEvent:CallbackInstance()
    local _InInstance, _InstanceType = IsInInstance()
    -- Enter instance for first time
    if(_InInstance and XFG.Player.InInstance == false) then
        XFG:Debug(LogCategory, 'Entering instance, disabling some event listeners and timers')
        XFG.Player.InInstance = true
        XFG.Events:EnterInstance()
        XFG.Timers:EnterInstance()        

    -- Just leaving instance or UI reload
    elseif(_InInstance == false and XFG.Player.InInstance) then
        XFG:Debug(LogCategory, 'Leaving instance, enabling some event listeners and timers')
        XFG.Player.InInstance = false
        XFG.Events:LeaveInstance()
        XFG.Timers:LeaveInstance()
    end
end

-- Entering combat in an instance, disable as much messaging as we can to not interfere
-- An instance is raid, dungeon, bg, arena
function PlayerEvent:CallbackEnterCombat()
    if(XFG.Player.InInstance) then
        XFG:Debug(LogCategory, 'Entering instance combat, disabling some event listeners and timers')
        XFG.Events:EnterCombat()
        XFG.Timers:EnterCombat()
    end
end

-- Reenable things and fire if its been too long
function PlayerEvent:CallbackLeaveCombat()
    if(XFG.Player.InInstance) then
        XFG:Debug(LogCategory, 'Leaving instance combat, enabling some event listeners and timers')
        XFG.Events:LeaveCombat()
        XFG.Timers:LeaveCombat()
    end
end