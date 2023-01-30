local XFG, G = unpack(select(2, ...))
local ObjectName = 'AchievementEvent'

AchievementEvent = Object:newChildConstructor()

--#region Constructors
function AchievementEvent:new()
    local object = AchievementEvent.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function AchievementEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFG.Events:Add({name = 'Achievement', 
                        event = 'ACHIEVEMENT_EARNED', 
                        callback = XFG.Handlers.AchievementEvent.CallbackAchievement, 
                        instance = true,
                        start = false,})
		self:IsInitialized(true)
	end
end
--#endregion

--#region Callbacks
function AchievementEvent:CallbackAchievement(inID)
    try(function ()
        local _, name, _, _, _, _, _, _, _, _, _, isGuild, _, earnedBy = GetAchievementInfo(inID)
        local unitData = XFG.Confederate:GetUnitByName(earnedBy)
        if(unitData ~= nil) then
            XFG.Frames.Chat:Display('GUILD_ACHIEVEMENT', unitData:GetName(), unitData:GetUnitName(), unitData:GetMainName(), unitData:GetGuild(), unitData:GetRealm(), unitData:GetGUID(), inID)
        else
            XFG.Frames.Chat:Display('GUILD_ACHIEVEMENT', earnedBy, earnedBy .. '-' .. XFG.Player.Realm:GetName(), nil, XFG.Player.Guild, XFG.Player.Realm, XFG.Player.Unit:GetGUID(), inID)
        end

        if(not isGuild and string.find(name, XFG.Lib.Locale['EXPLORE']) == nil) then
            local message = nil
            try(function ()
                message = XFG.Mailbox.Chat:Pop()
                message:Initialize()
                message:SetType(XFG.Settings.Network.Type.BROADCAST)
                message:SetSubject(XFG.Settings.Network.Message.Subject.ACHIEVEMENT)
                message:SetData(inID) -- Leave as ID to localize on receiving end
                message:SetName(XFG.Player.Unit:GetName())
                if(XFG.Player.Unit:IsAlt() and XFG.Player.Unit:HasMainName()) then
                    message:SetMainName(XFG.Player.Unit:GetMainName())
                end
                message:SetUnitName(XFG.Player.Unit:GetUnitName())
                message:SetRealm(XFG.Player.Realm)
                message:SetGuild(XFG.Player.Guild)
                XFG.Mailbox.Chat:Send(message)
            end).
            finally(function ()
                XFG.Mailbox.Chat:Push(message)
            end)
        end
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)    
end
--#endregion