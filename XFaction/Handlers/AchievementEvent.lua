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
	if(not self:IsInitialized()) then
        XFG:RegisterEvent('ACHIEVEMENT_EARNED', XFG.Handlers.AchievementEvent.CallbackAchievement)
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function AchievementEvent:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function AchievementEvent:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. ' Object')
    XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
end

function AchievementEvent:CallbackAchievement(inID)
    try(function ()
        local _, _Name, _, _, _, _, _, _, _, _, _, _IsGuild = GetAchievementInfo(inID)
        if(not _IsGuild and string.find(_Name, XFG.Lib.Locale['EXPLORE']) == nil) then
            local _Message = XFG.Factories.GuildMessage:CheckOut()
            try(function ()
                _Message:SetType(XFG.Settings.Network.Type.BROADCAST)
                _Message:SetSubject(XFG.Settings.Network.Message.Subject.ACHIEVEMENT)
                _Message:SetData(inID) -- Leave as ID to localize on receiving end
                if(XFG.Player.Unit:IsAlt() and XFG.Player.Unit:HasMainName()) then
                    _Message:SetMainName(XFG.Player.Unit:GetMainName())
                end
                _Message:SetUnitName(XFG.Player.Unit:GetName())
                _Message:SetRealm(XFG.Player.Realm)
                _Message:SetGuild(XFG.Player.Guild)
                XFG.Outbox:Send(_Message)
            end).
            finally(function ()
                XFG.Factories.GuildMessage:CheckIn(_Message)
            end)
        end
    end)
    .catch(function (inErrorMessage)
        XFG:Warn(LogCategory, 'Failed to send achievement message: ' .. inErrorMessage)
    end)    
end
