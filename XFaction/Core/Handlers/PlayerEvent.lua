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
		XFG:RegisterEvent('COVENANT_CHOSEN', self.CallbackPlayerChanged, 'COVENANT_CHOSEN')
        XFG:Info(LogCategory, 'Registered for COVENANT_CHOSEN events')
        XFG:RegisterEvent('SOULBIND_ACTIVATED', self.CallbackPlayerChanged, 'SOULBIND_ACTIVATED')
        XFG:Info(LogCategory, 'Registered for SOULBIND_ACTIVATED events')
        XFG:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED', self.CallbackPlayerChanged, 'ACTIVE_TALENT_GROUP_CHANGED')
        XFG:Info(LogCategory, 'Registered for ACTIVE_TALENT_GROUP_CHANGED events')
        XFG:RegisterEvent('PLAYER_LEVEL_CHANGED', self.CallbackPlayerChanged, 'PLAYER_LEVEL_CHANGED')
        XFG:Info(LogCategory, 'Registered for PLAYER_LEVEL_CHANGED events')
        XFG:RegisterEvent('SKILL_LINES_CHANGED', self.CallbackPlayerChanged, 'SKILL_LINES_CHANGED')
        XFG:Info(LogCategory, 'Registered for SKILL_LINES_CHANGED events')
        XFG:RegisterEvent('ZONE_CHANGED_NEW_AREA', self.CallbackPlayerChanged, 'ZONE_CHANGED_NEW_AREA')
        XFG:Info(LogCategory, 'Registered for ZONE_CHANGED_NEW_AREA events')
        XFG:RegisterEvent('CHALLENGE_MODE_COMPLETED', self.CallbackPlayerChanged, 'CHALLENGE_MODE_COMPLETED')
        XFG:Info(LogCategory, 'Registered for CHALLENGE_MODE_COMPLETED events')
        XFG:RegisterBucketEvent({'ACHIEVEMENT_EARNED'}, 10, self.CallbackPlayerChanged, 'ACHIEVEMENT_EARNED')
        XFG:Info(LogCategory, 'Registered for ACHIEVEMENT_EARNED events')
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
    XFG.Outbox:BroadcastUnitData(XFG.Player.Unit)
    XFG.DataText.Guild:RefreshBroker()

    if(inEvent == 'COVENANT_CHOSEN' or inEvent == 'SOULBIND_ACTIVATED') then
        XFG.DataText.Soulbind:RefreshBroker()
    end
end