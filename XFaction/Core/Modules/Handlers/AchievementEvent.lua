local XFG, G = unpack(select(2, ...))
local ObjectName = 'AchievementEvent'
local LogCategory = 'HEAchievement'

AchievementEvent = {}

function AchievementEvent:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName
    self._Initialized = false
    
    return _Object
end

function AchievementEvent:Initialize()
	if(self:IsInitialized() == false) then
		XFG:RegisterEvent('ACHIEVEMENT_EARNED', self.CallbackAchievement)
        XFG:Info(LogCategory, "Registered for ACHIEVEMENT_EARNED events")
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function AchievementEvent:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function AchievementEvent:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function AchievementEvent:CallbackAchievement(inID)
    local _, _, _, _, _, _, _, _, _, _, _, _IsGuild = GetAchievementInfo(inID)
    if(_IsGuild == false) then
        local _NewMessage = AchievementMessage:new()
        _NewMessage:Initialize()
        _NewMessage:SetType(XFG.Network.Type.BROADCAST)
        _NewMessage:SetSubject(XFG.Network.Message.Subject.ACHIEVEMENT)
        _NewMessage:SetData('has earned the achievement ' .. GetAchievementLink(inID) .. '!')
        if(XFG.Player.Unit:IsAlt() and XFG.Player.Unit:HasMainName()) then
            _NewMessage:SetMainName(XFG.Player.Unit:GetMainName())
        end
        _NewMessage:SetUnitName(XFG.Player.Unit:GetUnitName())
        XFG.Network.Outbox:Send(_NewMessage)
    end
end