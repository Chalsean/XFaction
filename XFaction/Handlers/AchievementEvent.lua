local XFG, G = unpack(select(2, ...))
local ObjectName = 'AchievementEvent'

AchievementEvent = Object:newChildConstructor()

function AchievementEvent:new()
    local _Object = AchievementEvent.parent.new(self)
    _Object.__name = ObjectName
    return _Object
end

function AchievementEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFG:RegisterEvent('ACHIEVEMENT_EARNED', XFG.Handlers.AchievementEvent.CallbackAchievement)
        XFG:Info(ObjectName, 'Registered for ACHIEVEMENT_EARNED events')
		self:IsInitialized(true)
	end
end

function AchievementEvent:CallbackAchievement(inID)
    try(function ()
        local _, _Name, _, _, _, _, _, _, _, _, _, _IsGuild, _, _EarnedBy = GetAchievementInfo(inID)
        if(_IsGuild) then
            local _UnitData = XFG.Confederate:GetUnitByName(_EarnedBy)    
            if(_UnitData ~= nil) then
                XFG.Frames.Chat:Display('GUILD_ACHIEVEMENT', _UnitData:GetName(), _UnitData:GetUnitName(), _UnitData:GetMainName(), _UnitData:GetGuild(), _UnitData:GetRealm(), _UnitData:GetGUID(), inID)
            else
                XFG.Frames.Chat:Display('GUILD_ACHIEVEMENT', _EarnedBy, _EarnedBy .. '-' .. XFG.Player.Realm:GetName(), nil, XFG.Player.Guild, XFG.Player.Realm, XFG.Player.Unit:GetGUID(), inID)
            end
        elseif(string.find(_Name, XFG.Lib.Locale['EXPLORE']) == nil) then
            local _NewMessage = nil
            try(function ()
                _NewMessage = XFG.Mailbox:Pop()
                _NewMessage:Initialize()
                _NewMessage:SetType(XFG.Settings.Network.Type.BROADCAST)
                _NewMessage:SetSubject(XFG.Settings.Network.Message.Subject.ACHIEVEMENT)
                _NewMessage:SetData(inID) -- Leave as ID to localize on receiving end
                if(XFG.Player.Unit:IsAlt() and XFG.Player.Unit:HasMainName()) then
                    _NewMessage:SetMainName(XFG.Player.Unit:GetMainName())
                end
                _NewMessage:SetUnitName(XFG.Player.Unit:GetName())
                _NewMessage:SetRealm(XFG.Player.Realm)
                _NewMessage:SetGuild(XFG.Player.Guild)
                XFG.Outbox:Send(_NewMessage)
            end).
            finally(function ()
                XFG.Mailbox:Push(_NewMessage)
            end)
        end
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)    
end
