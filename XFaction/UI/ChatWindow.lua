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

function XFC.ChatWindow:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        -- XFF.ChatWindowFilter('CHAT_MSG_GUILD', XFO.ChatWindow.Filter)
        -- XF:Info(self:ObjectName(), 'Created CHAT_MSG_GUILD event filter')
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end
--#endregion

--#region Methods
function XFC.ChatWindow:Filter(inEvent, inText, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, inGUID, ...)
    -- This is an erronous error from Blizzard that has no association with xfaction but people blame it anyway
    if (not issecretvalue(inText) and string.find(inText, XF.Lib.Locale['CHAT_NO_PLAYER_FOUND'])) then
        return true
    end
    return false, inText, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, inGUID, ...
end

local function GetPrefix(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')
    local self = XFO.ChatWindow
    
    local text = string.format("|T%s:16:16:0:0|t", 'Interface\\AddOns\\XFaction\\Assets\\xfaction-icon.png')
    -- if (XF.Config.Chat.GChat.Faction and inUnit:HasFaction()) then
    --     text = format('%s ', format(XF.Icons.String, inUnit:Faction():IconID()))
    -- end
    text = text .. inUnit:GetLink()
    if(XF.Config.Chat.GChat.Main and inUnit:IsAlt()) then
        text = text .. '(' .. inUnit:MainName() .. ')'
    end
    return text
end

local function DisplayOnFrame(inFrameName, inEvent, inChatType, inUnit, inText)
    local self = XFO.ChatWindow
    for i = 1, Constants.ChatFrameConstants.MaxChatWindows do
        local window = { XFF.ChatGetWindow(i) }
        for _, frameName in ipairs(window) do
            if frameName == inFrameName then
                local frame = 'ChatFrame' .. i
                if _G[frame] and _G[frame]:IsShown() then

                    local registered = _G[frame]:IsEventRegistered(inEvent)
                    if (registered) then
                        -- local _, fontSize = _G[frame]:GetFont()
                        -- local iconSize = math.floor(fontSize * 1.2)
                        --local text = string.format("|T%s:%d:%d:0:0|t", 'Interface\\AddOns\\XFaction\\Core\\System\\Media\\Images\\xfaction_icon-01_1.tga', iconSize, iconSize) .. ' ' .. GetPrefix(inUnit) .. inText
                        local text = GetPrefix(inUnit) .. ' ' .. inText

                    XF:Warn(self:ObjectName(), text)
                    local color = _G.ChatTypeInfo[inChatType]
                    --XFF.ChatHandler(_G[frame], inEvent, text, inUnit:UnitName(), XF.Player.Faction:Language(), '', inUnit:UnitName(), '', 0, 0, '', 0, _, inUnit:GUID())
                    _G[frame]:AddMessage(text, color.r, color.g, color.b)
                    end

                    --local color = _G.ChatTypeInfo[inChatType]

                    -- if(XFO.WIM:IsLoaded() and XFO.WIM:API().modules.GuildChat.enabled) then
                    --     XFO.WIM:API():CHAT_MSG_GUILD(inText, inUnit:UnitName(), XF.Player.Faction():Language(), '', inUnit:UnitName(), '', 0, 0, '', 0, _, inUnit:GUID())
                    -- else                
                      --  frame:AddMessage(inText, color.r, color.g, color.b)
                    -- end
                end
            end            
        end
    end
end

function XFC.ChatWindow:DisplayGuildChat(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')
    XF:Warn(self:ObjectName(), inMessage:Data())
    DisplayOnFrame('GUILD', 'CHAT_MSG_GUILD', 'GUILD', inMessage:FromUnit(), inMessage:Data())
    --XFO.Elephant:AddMessage(inMessage, 'CHAT_MSG_GUILD', text)
end

function XFC.ChatWindow:DisplayAchievement(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')
    XF:Warn(self:ObjectName(), inMessage:Data())
    DisplayOnFrame('GUILD_ACHIEVEMENT', 'CHAT_MSG_GUILD_ACHIEVEMENT', 'GUILD_ACHIEVEMENT', inMessage:FromUnit(), XF.Lib.Locale['ACHIEVEMENT_EARNED'] .. ' ' .. gsub(XFF.PlayerAchievementLink(inMessage:Data()), "(Player.-:.-:.-:.-:.-:)"  , inMessage:FromUnit():GUID() .. ':1:' .. date("%m:%d:%y:") ) .. '!')
    --XFO.Elephant:AddMessage(inMessage, 'CHAT_MSG_GUILD_ACHIEVEMENT', text)
end

function XFC.ChatWindow:DisplayLogin(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')
    DisplayOnFrame('GUILD', 'CHAT_MSG_GUILD', 'SYSTEM', inUnit, XF.Lib.Locale['CHAT_LOGIN'])
end

function XFC.ChatWindow:DisplayLogout(inGUID)
    assert(type(inGUID) == 'string')
    if (XFO.Confederate:Contains(inGUID)) then
        local unit = XFO.Confederate:Get(inGUID)
        DisplayOnFrame('GUILD', 'CHAT_MSG_GUILD', 'SYSTEM', unit, XF.Lib.Locale['CHAT_LOGOUT'])
    end
end

function XFC.ChatWindow:DisplayOrder(inOrder)
    assert(type(inOrder) == 'table' and inOrder.__name == 'Order')

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