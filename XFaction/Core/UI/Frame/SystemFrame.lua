local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'SystemFrame'

XFC.SystemFrame = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.SystemFrame:new()
    local object = SystemFrame.parent.new(self)
    object.__name = ObjectName
    return object
end

function XFC.SystemFrame:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        ChatFrame_AddMessageEventFilter('CHAT_MSG_SYSTEM', XFO.SystemFrame.CallbackChatFilter)
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
    elseif(string.find(inMessage, XF.Lib.Locale['CHAT_JOIN_GUILD'])) then
        return true 
    elseif(string.find(inMessage, XF.Lib.Locale['CHAT_NO_PLAYER_FOUND'])) then
        return true
    end
    return false, inMessage, ...
end

function XFC.SystemFrame:Display(inType, inName, inUnitName, inMainName, inGuild, inOrder, inFaction)

    local text = XF.Settings.Frames.Chat.Prepend
    
    if(inType == XF.Enum.Message.LOGIN and XF.Config.Chat.Login.Faction) then  
        text = text .. format('%s ', format(XF.Icons.String, inFaction:IconID()))
    elseif(inType == XF.Enum.Message.ORDER and XF.Config.Chat.Crafting.Faction) then
        text = text .. format('%s ', format(XF.Icons.String, inFaction:IconID()))
    end
  
    if(inType == XF.Enum.Message.LOGOUT) then
        text = text .. inName .. ' '
    elseif(inFaction:Equals(XF.Player.Faction)) then
        text = text .. format('|Hplayer:%s|h[%s]|h', inUnitName, inName) .. ' '
        -- TODO
    -- else
    --     local friend = XFO.Friends:GetByRealmUnitName(inGuild:Realm(), inName)
    --     if(friend ~= nil) then
    --         text = text .. format('|HBNplayer:%s:%d:1:WHISPER:%s|h[%s]|h', friend:GetAccountName(), friend:GetAccountID(), friend:GetTag(), inName) .. ' '
    --     else
    --         -- Maybe theyre in a bnet community together, no way to associate tho
    --         text = text .. format('|Hplayer:%s|h[%s]|h', inUnitName, inName) .. ' '
    --     end
    end
    
    if(inType == XF.Enum.Message.LOGIN and XF.Config.Chat.Login.Main and inMainName ~= nil) then
        text = text .. '(' .. inMainName .. ') '
    elseif(inType == XF.Enum.Message.ORDER and XF.Config.Chat.Crafting.Main and inMainName ~= nil) then
        text = text .. '(' .. inMainName .. ') '
    end

    if(inType == XF.Enum.Message.LOGIN and XF.Config.Chat.Login.Guild) then  
        text = text .. '<' .. inGuild:Initials() .. '> '
    elseif(inType == XF.Enum.Message.ORDER and XF.Config.Chat.Crafting.Guild) then
        text = text .. '<' .. inGuild:Initials() .. '> '
    end
    
    if(inType == XF.Enum.Message.LOGOUT) then
        text = text .. XF.Lib.Locale['CHAT_LOGOUT']
    elseif(inType == XF.Enum.Message.LOGIN) then
        text = text .. XF.Lib.Locale['CHAT_LOGIN']
        if(XF.Config.Chat.Login.Sound and not XF.Player.Guild:Equals(inGuild)) then
            XFF.UISystemSound(3332, 'Master')
        end
    elseif(inType == XF.Enum.Message.ORDER) then
        if(inOrder:IsGuild()) then
            text = text .. format(XF.Lib.Locale['NEW_GUILD_CRAFTING_ORDER'], inOrder:GetLink())
        else
            text = text .. format(XF.Lib.Locale['NEW_PERSONAL_CRAFTING_ORDER'], inOrder:CrafterName(), inOrder:GetLink())
        end
    end
    XFF.UISystemMessage(text) 
end

function XFC.SystemFrame:DisplayLoginMessage(inMessage)
    if(not XF.Config.Chat.Login.Enable) then return end
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')    
    local unitData = inMessage:Data()
    self:Display(inMessage:Subject(), unitData:Name(), unitData:UnitName(), unitData:MainName(), unitData:Guild(), nil, unitData:Race():Faction())
end

function XFC.SystemFrame:DisplayLogoutMessage(inMessage)
    if(not XF.Config.Chat.Login.Enable) then return end
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')
    self:Display(inMessage:Subject(), inMessage:Name(), inMessage:UnitName(), inMessage:MainName(), inMessage:Guild(), nil, inMessage:Faction())
end

function XFC.SystemFrame:DisplayOrder(inOrder)
    if(not XF.Config.Chat.Crafting.Enable) then return end    
    assert(type(inOrder) == 'table' and inOrder.__name == 'Order')
    local customer = inOrder:Customer()
    self:Display(XF.Enum.Message.ORDER, customer:Name(), customer:UnitName(), customer:MainName(), customer:Guild(), inOrder, customer:Faction())
end
--#endregion