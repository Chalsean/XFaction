local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'AchievementEvent'
local GetAchievementInfo = GetAchievementInfo

XFC.AchievementEvent = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.AchievementEvent:new()
    local object = XFC.AchievementEvent.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function XFC.AchievementEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFO.Events:Add({name = 'Achievement', 
                        event = 'ACHIEVEMENT_EARNED', 
                        callback = XFO.AchievementEvent.CallbackAchievement, 
                        instance = true})
		self:IsInitialized(true)
	end
end
--#endregion

--#region Callbacks
function XFC.AchievementEvent:CallbackAchievement(inID)
    try(function ()
        local _, name, _, _, _, _, _, _, _, _, _, isGuild = GetAchievementInfo(inID)
        if(not isGuild and string.find(name, XF.Lib.Locale['EXPLORE']) == nil) then
            local message = nil
            try(function ()
                message = XFO.Chat:Pop()
                message:Initialize()
                message:SetType(XF.Enum.Network.BROADCAST)
                message:SetSubject(XF.Enum.Message.ACHIEVEMENT)
                message:SetData(inID) -- Leave as ID to localize on receiving end
                XFO.Chat:Send(message)
            end).
            finally(function ()
                XFO.Chat:Push(message)
            end)
        end
    end).
    catch(function (err)
        XF:Warn(self:GetObjectName(), err)
    end)    
end
--#endregion