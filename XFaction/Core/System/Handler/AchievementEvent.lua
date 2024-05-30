local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'AchievementEvent'
local GetAchievementInfo = GetAchievementInfo

AchievementEvent = XFC.Object:newChildConstructor()

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
            XFO.Chat:SendAchievementMessage(inID)
        end
    end).
    catch(function (err)
        XF:Warn(ObjectName, err)
    end)    
end
--#endregion