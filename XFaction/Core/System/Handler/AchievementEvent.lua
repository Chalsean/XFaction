local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'AchievementEvent'

XFC.AchievementEvent = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.AchievementEvent:new()
    local object = XFC.AchievementEvent.parent.new(self)
    object.__name = ObjectName
    return object
end

function XFC.AchievementEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFO.Events:Add({
            name = 'Achievement', 
            event = 'ACHIEVEMENT_EARNED', 
            callback = XFO.AchievementHandler.CallbackAchievementEarned, 
            instance = true
        })
		self:IsInitialized(true)
	end
end
--#endregion

--#region Methods
function XFC.AchievementEvent:CallbackAchievementEarned(inID)
    local self = XFO.AchievementHandler
    try(function ()
        local _, name, _, _, _, _, _, _, _, _, _, isGuild = XFF.PlayerGetAchievement(inID)
        if(not isGuild and string.find(name, XF.Lib.Locale['EXPLORE']) == nil) then
            XFO.Mailbox:SendAchievementMessage(inID)
        end
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)    
end
--#endregion