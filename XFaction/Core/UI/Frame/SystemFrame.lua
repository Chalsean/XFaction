local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'SystemFrame'

XFC.SystemFrame = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.SystemFrame:new()
    local object = XFC.SystemFrame.parent.new(self)
    object.__name = ObjectName
    return object
end

function XFC.SystemFrame:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFF.ChatFrameFilter('CHAT_MSG_SYSTEM', XFO.SystemFrame.CallbackChatFilter)
        XF:Info(self:ObjectName(), 'Created CHAT_MSG_SYSTEM event filter')
        self:IsInitialized(true)
    end
end
--#endregion

--#region Methods
function XFC.SystemFrame:CallbackChatFilter(inEvent, inMessage, ...)
    local self = XFO.SystemFrame
    if(string.find(inMessage, XF.Settings.Frames.Chat.Prepend)) then
        inMessage = string.gsub(inMessage, XF.Settings.Frames.Chat.Prepend, '')
        return false, inMessage, ...
    -- Hide Blizz login/logout messages, we display our own, this is a double notification
    elseif(string.find(inMessage, XF.Lib.Locale['CHAT_LOGIN'])) then
        return true
    elseif(string.find(inMessage, XF.Lib.Locale['CHAT_LOGOUT'])) then
        return true
    -- Hide Blizz API spam
    elseif(string.find(inMessage, XF.Lib.Locale['CHAT_NO_PLAYER_FOUND'])) then
        return true
    end
    return false, inMessage, ...
end

local function _GetChatLink(inUnit)

    if(inUnit:IsFriend() and not inUnit:IsSameFaction()) then
        local friend = XFO.Friends:GetByGUID(inUnit:GUID())
        friend:Print()
        return format('|HBNplayer:%s:%d:1:WHISPER:%s|h[%s]|h', friend:AccountName(), friend:AccountID(), friend:Tag(), inUnit:Name())
    end
    
    -- Maybe theyre in a bnet community together, no way to associate tho
    return format('|Hplayer:%s|h[%s]|h', inUnit:UnitName(), inUnit:Name())
end

function XFC.SystemFrame:DisplayLogin(inUnit)
    if(not XF.Config.Chat.Login.Enable) then return end
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')

    local text = XF.Settings.Frames.Chat.Prepend
    if(XF.Config.Chat.Login.Faction) then
        text = text .. format('%s ', format(XF.Icons.String, inUnit:Race():Faction():IconID()))
    end

    text = text .. _GetChatLink(inUnit) .. ' '
    if(inUnit:IsAlt() and XF.Config.Chat.Login.Main) then
        text = text .. '(' .. inUnit:MainName() .. ') '
    end
    if(XF.Config.Chat.Login.Guild) then  
        text = text .. '<' .. inUnit:Guild():Initials() .. '> '
    end
    text = text .. XF.Lib.Locale['CHAT_LOGIN']

    if(not inUnit:IsSameGuild() and XF.Config.Chat.Login.Sound) then
        XFF.UISystemSound(3332, 'Master')
    end
    XFF.UISystemMessage(text) 
end

function XFC.SystemFrame:DisplayLogout(inName)
    if(not XF.Config.Chat.Login.Enable) then return end
    assert(type(inName) == 'string')
    XFF.UISystemMessage(XF.Settings.Frames.Chat.Prepend .. inName .. ' ' .. XF.Lib.Locale['CHAT_LOGOUT'])
end

function XFC.SystemFrame:DisplayOrder(inOrder)
    if(not XF.Config.Chat.Crafting.Enable) then return end    
    assert(type(inOrder) == 'table' and inOrder.__name == 'Order')

    local text = XF.Settings.Frames.Chat.Prepend    
    if(XF.Config.Chat.Crafting.Faction) then
        text = text .. format('%s ', format(XF.Icons.String, inOrder:Customer():Race():Faction():IconID()))
    end

    text = text .. _GetChatLink(inOrder:Customer()) .. ' '
    if(inOrder:Customer():IsAlt() and XF.Config.Chat.Crafting.Main) then
        text = text .. '(' .. inOrder:Customer():MainName() .. ') '
    end
    if(XF.Config.Chat.Crafting.Guild) then  
        text = text .. '<' .. inOrder:Customer():Guild():Initials() .. '> '
    end

    if(inOrder:IsGuild()) then
        text = text .. format(XF.Lib.Locale['NEW_GUILD_CRAFTING_ORDER'], inOrder:GetLink())
    else
        text = text .. format(XF.Lib.Locale['NEW_PERSONAL_CRAFTING_ORDER'], inOrder:CrafterName(), inOrder:GetLink())
    end

    XFF.UISystemMessage(text)
end
--#endregion