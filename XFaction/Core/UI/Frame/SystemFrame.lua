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
--#endregion

--#region Initializers
function XFC.SystemFrame:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFF.ChatFrameFilter('CHAT_MSG_SYSTEM', XFO.SystemFrame.ChatFilter)
        XF:Info(self:ObjectName(), 'Created CHAT_MSG_SYSTEM event filter')
        self:IsInitialized(true)
    end
end
--#endregion

--#region Callbacks
function XFC.SystemFrame:ChatFilter(inEvent, inMessage, ...)
    if(string.find(inMessage, XF.Settings.Frames.Chat.Prepend)) then
        inMessage = string.gsub(inMessage, XF.Settings.Frames.Chat.Prepend, '')
        return false, inMessage, ...
    -- Hide Blizz login/logout messages, we display our own, this is a double notification
    elseif(string.find(inMessage, XF.Lib.Locale['CHAT_LOGIN'])) then
        return true
    elseif(string.find(inMessage, XF.Lib.Locale['CHAT_LOGOUT'])) then
        return true
    elseif(string.find(inMessage, XF.Lib.Locale['CHAT_NO_PLAYER_FOUND'])) then
        return true
    end
    return false, inMessage, ...
end
--#endregion

--#region Display
function XFC.SystemFrame:Display(inType, inUnit, inOrder)

    local faction = inUnit:Race():Faction()
    local text = XF.Settings.Frames.Chat.Prepend
    
    if(inType == XF.Enum.Message.LOGIN and XF.Config.Chat.Login.Faction) then  
        text = text .. format('%s ', format(XF.Icons.String, inUnit:Race():Faction():IconID()))
    elseif(inType == XF.Enum.Message.ORDER and XF.Config.Chat.Crafting.Faction) then
        text = text .. format('%s ', format(XF.Icons.String, inUnit:Race():Faction():IconID()))
    end
  
    if(inType == XF.Enum.Message.LOGOUT) then
        text = text .. inUnit:Name() .. ' '
    elseif(inUnit:Race():Faction():Equals(XF.Player.Faction)) then
        text = text .. format('|Hplayer:%s|h[%s]|h', inUnit:UnitName(), inUnit:Name()) .. ' '
    --FIXelse
        -- local friend = XFO.Friends:GetByRealmUnitName(inUnit:GetGuild():GetRealm(), inUnit:GetName())
        -- if(friend ~= nil) then
        --     text = text .. format('|HBNplayer:%s:%d:1:WHISPER:%s|h[%s]|h', friend:GetAccountName(), friend:GetAccountID(), friend:GetTag(), inName) .. ' '
        -- else
        --     -- Maybe theyre in a bnet community together, no way to associate tho
        --     text = text .. format('|Hplayer:%s|h[%s]|h', inUnit:GetUnitName(), inUnit:GetName()) .. ' '
        -- end
    end
    
    if(inType == XF.Enum.Message.LOGIN and XF.Config.Chat.Login.Main and inUnit:IsAlt()) then
        text = text .. '(' .. inUnit:MainName() .. ') '
    elseif(inType == XF.Enum.Message.ORDER and XF.Config.Chat.Crafting.Main and inUnit:IsAlt()) then
        text = text .. '(' .. inUnit:MainName() .. ') '
    end

    if(inType == XF.Enum.Message.LOGIN and XF.Config.Chat.Login.Guild) then  
        text = text .. '<' .. inUnit:Guild():Initials() .. '> '
    elseif(inType == XF.Enum.Message.ORDER and XF.Config.Chat.Crafting.Guild) then
        text = text .. '<' .. inUnit:Guild():Initials() .. '> '
    end
    
    if(inType == XF.Enum.Message.LOGOUT) then
        text = text .. XF.Lib.Locale['CHAT_LOGOUT']
    elseif(inType == XF.Enum.Message.LOGIN) then
        text = text .. XF.Lib.Locale['CHAT_LOGIN']
        if(XF.Config.Chat.Login.Sound and not XF.Player.Guild:Equals(inUnit:Guild())) then
            PlaySound(3332, 'Master')
        end
    elseif(inType == XF.Enum.Message.ORDER) then
        if(inOrder:IsGuild()) then
            text = text .. format(XF.Lib.Locale['NEW_GUILD_CRAFTING_ORDER'], inOrder:Link())
        else
            text = text .. format(XF.Lib.Locale['NEW_PERSONAL_CRAFTING_ORDER'], inOrder:CrafterName(), inOrder:Link())
        end
    end
    SendSystemMessage(text) 
end

function XFC.SystemFrame:DisplayLogMessage(inMessage)
    if(not XF.Config.Chat.Login.Enable) then return end
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), 'argument must be Message type object')    
    self:Display(inMessage:Subject(), inMessage:From())
end
--#endregion