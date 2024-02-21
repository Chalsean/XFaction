local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
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
        ChatFrame_AddMessageEventFilter('CHAT_MSG_SYSTEM', XFO.SystemFrame.ChatFilter)
        XF:Info(ObjectName, 'Created CHAT_MSG_SYSTEM event filter')
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
    elseif(string.find(inMessage, XF.Lib.Locale['CHAT_JOIN_GUILD'])) then
        return true 
    elseif(string.find(inMessage, XF.Lib.Locale['CHAT_NO_PLAYER_FOUND'])) then
        return true
    end
    return false, inMessage, ...
end
--#endregion

--#region Display
function XFC.SystemFrame:Display(inType, inUnit, inOrder)

    local faction = inUnit:GetRace():GetFaction()
    local text = XF.Settings.Frames.Chat.Prepend
    
    if(inType == XF.Enum.Message.LOGIN and XF.Config.Chat.Login.Faction) then  
        text = text .. format('%s ', format(XF.Icons.String, inUnit:GetRace():GetFaction():GetIconID()))
    elseif(inType == XF.Enum.Message.ORDER and XF.Config.Chat.Crafting.Faction) then
        text = text .. format('%s ', format(XF.Icons.String, inUnit:GetRace():GetFaction():GetIconID()))
    end
  
    if(inType == XF.Enum.Message.LOGOUT) then
        text = text .. inUnit:GetName() .. ' '
    elseif(inUnit:GetRace():GetFaction():Equals(XF.Player.Faction)) then
        text = text .. format('|Hplayer:%s|h[%s]|h', inUnit:GetUnitName(), inUnit:GetName()) .. ' '
    else
        local friend = XFO.Friends:GetByRealmUnitName(inUnit:GetGuild():GetRealm(), inUnit:GetName())
        if(friend ~= nil) then
            text = text .. format('|HBNplayer:%s:%d:1:WHISPER:%s|h[%s]|h', friend:GetAccountName(), friend:GetAccountID(), friend:GetTag(), inName) .. ' '
        else
            -- Maybe theyre in a bnet community together, no way to associate tho
            text = text .. format('|Hplayer:%s|h[%s]|h', inUnit:GetUnitName(), inUnit:GetName()) .. ' '
        end
    end
    
    if(inType == XF.Enum.Message.LOGIN and XF.Config.Chat.Login.Main and inUnit:HasMainName()) then
        text = text .. '(' .. inUnit:GetMainName() .. ') '
    elseif(inType == XF.Enum.Message.ORDER and XF.Config.Chat.Crafting.Main and inUnit:HasMainName()) then
        text = text .. '(' .. inUnit:GetMainName() .. ') '
    end

    if(inType == XF.Enum.Message.LOGIN and XF.Config.Chat.Login.Guild) then  
        text = text .. '<' .. inUnit:GetGuild():GetInitials() .. '> '
    elseif(inType == XF.Enum.Message.ORDER and XF.Config.Chat.Crafting.Guild) then
        text = text .. '<' .. inUnit:GetGuild():GetInitials() .. '> '
    end
    
    if(inType == XF.Enum.Message.LOGOUT) then
        text = text .. XF.Lib.Locale['CHAT_LOGOUT']
    elseif(inType == XF.Enum.Message.LOGIN) then
        text = text .. XF.Lib.Locale['CHAT_LOGIN']
        if(XF.Config.Chat.Login.Sound and not XF.Player.Guild:Equals(inUnit:GetGuild())) then
            PlaySound(3332, 'Master')
        end
    elseif(inType == XF.Enum.Message.ORDER) then
        if(inOrder:IsGuild()) then
            text = text .. format(XF.Lib.Locale['NEW_GUILD_CRAFTING_ORDER'], inOrder:GetLink())
        else
            text = text .. format(XF.Lib.Locale['NEW_PERSONAL_CRAFTING_ORDER'], inOrder:GetCrafterName(), inOrder:GetLink())
        end
    end
    SendSystemMessage(text) 
end

function XFC.SystemFrame:DisplayLogMessage(inMessage)
    if(not XF.Config.Chat.Login.Enable) then return end
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), 'argument must be Message type object')    
    self:Display(inMessage:GetSubject(), inMessage:GetFrom())
end

function XFC.SystemFrame:DisplayOrder(inOrder)
    if(not XF.Config.Chat.Crafting.Enable) then return end    
    assert(type(inOrder) == 'table' and inOrder.__name ~= nil and inOrder.__name == 'Order', 'argument must be Order type object')
    self:Display(XF.Enum.Message.ORDER, inOrder:GetCustomerUnit(), inOrder)
end
--#endregion