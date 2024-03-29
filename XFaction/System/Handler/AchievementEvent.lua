local XF, G = unpack(select(2, ...))
local ObjectName = 'AchievementEvent'
local GetAchievementInfo = GetAchievementInfo

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
        XF.Events:Add({name = 'Achievement', 
                        event = 'ACHIEVEMENT_EARNED', 
                        callback = XF.Handlers.AchievementEvent.CallbackAchievement, 
                        instance = true})
		self:IsInitialized(true)
	end
end
--#endregion

--#region Callbacks
function AchievementEvent:CallbackAchievement(inID)
    try(function ()
        local _, name, _, _, _, _, _, _, _, _, _, isGuild = GetAchievementInfo(inID)
        if(not isGuild and string.find(name, XF.Lib.Locale['EXPLORE']) == nil) then
            local message = nil
            try(function ()
                message = XF.Mailbox.Chat:Pop()
                message:Initialize()
                message:SetType(XF.Enum.Network.BROADCAST)
                message:SetSubject(XF.Enum.Message.ACHIEVEMENT)
                message:SetData(inID) -- Leave as ID to localize on receiving end
                message:SetName(XF.Player.Unit:GetName())
                if(XF.Player.Unit:IsAlt() and XF.Player.Unit:HasMainName()) then
                    message:SetMainName(XF.Player.Unit:GetMainName())
                end
                message:SetUnitName(XF.Player.Unit:GetUnitName())
                message:SetGuild(XF.Player.Guild)
                XF.Mailbox.Chat:Send(message)
            end).
            finally(function ()
                XF.Mailbox.Chat:Push(message)
            end)
        end
    end).
    catch(function (inErrorMessage)
        XF:Warn(ObjectName, inErrorMessage)
    end)    
end
--#endregion