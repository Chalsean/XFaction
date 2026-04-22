local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'ChatWindow'

XFC.ChatWindow = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.ChatWindow:new()
    local object = XFC.ChatWindow.parent.new(self)
    object.__name = ObjectName
    return object
end

local function GetPrefix(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')
    
    local text = ''
    if (XF.Config.Chat.GChat.Icon) then
        text = text .. string.format("|T%s:14:14:0:0|t", 'Interface\\AddOns\\XFaction\\Assets\\xfaction-icon.png')
    end
    if (XF.Config.Chat.GChat.Faction and inUnit:HasFaction()) then
        text = text .. format('%s', format(XF.Icons, inUnit:Faction():IconID()))
    end
    text = text .. inUnit:GetLink()
    if(XF.Config.Chat.GChat.Guild and inUnit:HasGuild()) then
        text = text .. '(' .. inUnit:Guild():Initials()
        if(XF.Config.Chat.GChat.Main and inUnit:IsAlt()) then
            text = text .. '-' .. inUnit:MainName()
        end
        text = text ..  ')'
    elseif(XF.Config.Chat.GChat.Main and inUnit:IsAlt()) then
        text = text .. '(' .. inUnit:MainName() .. ')'
    end
    return text
end

local function ChatFilter(inFrame, inEvent, inText, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, inGUID, ...)
    local achievement = inEvent == 'CHAT_MSG_GUILD_ACHIEVEMENT'
    if (not XF.Config.Chat.GChat.Enable) then
        return true
    elseif (achievement and not XF.Config.Chat.GChat.Achievement) then
        return true
    elseif (not issecretvalue(inGUID) and XFO.Confederate:Contains(inGUID)) then
        local unit = XFO.Confederate:Get(inGUID)
        local text = GetPrefix(unit) .. ' ' .. (achievement and string.sub(inText, 4) or inText)
        local color = _G.ChatTypeInfo[achievement and 'GUILD_ACHIEVEMENT' or 'GUILD']
        inFrame:AddMessage(text, color.r, color.g, color.b)
        return true
    end
    return false, inText, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, inGUID, ...
end

local function SystemFilter(_, _, inText, ...)
    -- This is an erronous error from Blizzard that has no association with xfaction but people blame it anyway
    if (not issecretvalue(inText) and string.find(inText, XF.Lib.Locale['CHAT_NO_PLAYER_FOUND'])) then
        return true
    end
    return false, inText, ...
end

function XFC.ChatWindow:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        ChatFrameUtil.AddMessageEventFilter('CHAT_MSG_GUILD', ChatFilter)
        XF:Info(self:ObjectName(), 'Created CHAT_MSG_GUILD event filter')
        ChatFrameUtil.AddMessageEventFilter('CHAT_MSG_GUILD_ACHIEVEMENT', ChatFilter)
        XF:Info(self:ObjectName(), 'Created CHAT_MSG_GUILD_ACHIEVEMENT event filter')
        ChatFrameUtil.AddMessageEventFilter('CHAT_MSG_SYSTEM', SystemFilter)
        XF:Info(self:ObjectName(), 'Created CHAT_MSG_SYSTEM event filter')
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end
--#endregion

--#region Methods
local function DisplayOnFrame(inFrameName, inEvent, inChatType, inUnit, inText)
    local text = GetPrefix(inUnit) .. ' ' .. inText
    local color = _G.ChatTypeInfo[inChatType]

    for i = 1, Constants.ChatFrameConstants.MaxChatWindows do
        local window = { GetChatWindowMessages(i) }
        for _, frameName in ipairs(window) do
            if frameName == inFrameName then
                local frame = 'ChatFrame' .. i
                if _G[frame] and _G[frame]:IsShown() then
                    _G[frame]:AddMessage(text, color.r, color.g, color.b)
                end
            end            
        end
    end
    return text
end

function XFC.ChatWindow:DisplayGuildChat(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')
    if (not XF.Config.Chat.GChat.Enable or inMessage:FromUnit():IsSameGuild()) then return end
    local text = DisplayOnFrame('GUILD', 'CHAT_MSG_GUILD', 'GUILD', inMessage:FromUnit(), inMessage:Data())
    XFO.Elephant:AddMessage(inMessage:FromUnit(), 'CHAT_MSG_GUILD', text)
    XFO.WIM:AddMessage(inMessage:FromUnit(), text)
end

function XFC.ChatWindow:DisplayAchievement(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')
    if (not XF.Config.Chat.GChat.Enable or not XF.Config.Chat.GChat.Achievement or inMessage:FromUnit():IsSameGuild()) then return end
    local text = DisplayOnFrame('GUILD_ACHIEVEMENT', 'CHAT_MSG_GUILD_ACHIEVEMENT', 'GUILD_ACHIEVEMENT', inMessage:FromUnit(), XF.Lib.Locale['ACHIEVEMENT_EARNED'] .. ' ' .. gsub(GetAchievementLink(inMessage:Data()), "(Player.-:.-:.-:.-:.-:)"  , inMessage:FromUnit():GUID() .. ':1:' .. date("%m:%d:%y:") ) .. '!')
    XFO.Elephant:AddMessage(inMessage:FromUnit(), 'CHAT_MSG_GUILD_ACHIEVEMENT', text)
end

function XFC.ChatWindow:DisplayLogin(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')
    if (not XF.Config.Chat.Login.Enable or inUnit:IsSameGuild()) then return end
    DisplayOnFrame('GUILD', 'CHAT_MSG_GUILD', 'SYSTEM', inUnit, XF.Lib.Locale['CHAT_LOGIN'])
    if(XF.Config.Chat.Login.Sound) then
        PlaySound(3332, 'Master')
    end
end

function XFC.ChatWindow:DisplayLogout(inGUID)
    assert(type(inGUID) == 'string')
    if (not XF.Config.Chat.Login.Enable) then return end
    if (XFO.Confederate:Contains(inGUID)) then
        local unit = XFO.Confederate:Get(inGUID)
        if (not unit:IsSameGuild()) then
            DisplayOnFrame('GUILD', 'CHAT_MSG_GUILD', 'SYSTEM', unit, XF.Lib.Locale['CHAT_LOGOUT'])
        end
    end
end

function XFC.ChatWindow:DisplayOrder(inOrder)
    assert(type(inOrder) == 'table' and inOrder.__name == 'Order')
    if (not XF.Config.Chat.Crafting.Enable) then return end

    if(inOrder:IsGuild() and not XF.Config.Chat.Crafting.GuildOrder) then return end
    if(inOrder:IsPersonal() and not XF.Config.Chat.Crafting.PersonalOrder) then return end
    if(inOrder:IsPersonal() and not inOrder:IsMyOrder() and not inOrder:IsPlayerCrafter()) then return end

    local display = false
    if(not XF.Config.Chat.Crafting.Professions) then
        display = true
    elseif(inOrder:HasProfession() and inOrder:Profession():Equals(XF.Player.Unit:Profession1())) then
        display = true
    elseif(inOrder:HasProfession() and inOrder:Profession():Equals(XF.Player.Unit:Profession2())) then
        display = true
    end

    if(display) then
        if(inOrder:IsGuild()) then
            DisplayOnFrame('GUILD', 'CHAT_MSG_GUILD', 'SYSTEM', inOrder:Customer(), format(XF.Lib.Locale['NEW_GUILD_CRAFTING_ORDER'], inOrder:Link()))
        else
            DisplayOnFrame('GUILD', 'CHAT_MSG_GUILD', 'SYSTEM', inOrder:Customer(), format(XF.Lib.Locale['NEW_PERSONAL_CRAFTING_ORDER'], inOrder:CrafterName(), inOrder:Link()))
        end
    end
end
--#endregion