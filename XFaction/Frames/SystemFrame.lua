local XFG, G = unpack(select(2, ...))
local ObjectName = 'SystemFrame'

SystemFrame = Object:newChildConstructor()

--#region Constructors
function SystemFrame:new()
    local object = SystemFrame.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function SystemFrame:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        ChatFrame_AddMessageEventFilter('CHAT_MSG_SYSTEM', XFG.Frames.System.ChatFilter)
        XFG:Info(ObjectName, 'Created CHAT_MSG_SYSTEM event filter')
        self:IsInitialized(true)
    end
end
--#endregion

--#region Callbacks
function SystemFrame:ChatFilter(inEvent, inMessage, ...)
    if(string.find(inMessage, XFG.Settings.Frames.Chat.Prepend)) then
        inMessage = string.gsub(inMessage, XFG.Settings.Frames.Chat.Prepend, '')
        return false, inMessage, ...
    -- Hide Blizz login/logout messages, we display our own, this is a double notification
    elseif(string.find(inMessage, XFG.Lib.Locale['CHAT_LOGIN'])) then
        return true
    elseif(string.find(inMessage, XFG.Lib.Locale['CHAT_LOGOUT'])) then
        return true
    elseif(string.find(inMessage, XFG.Lib.Locale['CHAT_JOIN_GUILD'])) then
        return true 
    end
    return false, inMessage, ...
end
--#endregion

--#region Display
function SystemFrame:Display(inType, inName, inUnitName, inMainName, inGuild, inRealm)
    if(not XFG.Config.Chat.Login.Enable) then return end
    assert(type(inName) == 'string')
    assert(type(inUnitName) == 'string')
    assert(type(inGuild) == 'table' and inGuild.__name == 'Guild', 'argument must be Guild object')
    assert(type(inRealm) == 'table' and inRealm.__name == 'Realm', 'argument must be Realm object')

    local faction = inGuild:GetFaction()
    local text = XFG.Settings.Frames.Chat.Prepend
    
    if(XFG.Config.Chat.Login.Faction) then  
        text = text .. format('%s ', format(XFG.Icons.String, faction:GetIconID()))
    end
  
    if(inType == XFG.Settings.Network.Message.Subject.LOGOUT) then
        text = text .. inName .. ' '
    elseif(faction:Equals(XFG.Player.Faction)) then
        text = text .. format('|Hplayer:%s|h[%s]|h', inUnitName, inName) .. ' '
    else
        local friend = XFG.Friends:GetByRealmUnitName(inRealm, inName)
        if(friend ~= nil) then
            text = text .. format('|HBNplayer:%s:%d:1:WHISPER:%s|h[%s]|h', friend:GetAccountName(), friend:GetAccountID(), friend:GetTag(), inName) .. ' '
        else
            -- Maybe theyre in a bnet community together, no way to associate tho
            text = text .. format('|Hplayer:%s|h[%s]|h', inUnitName, inName) .. ' '
        end
    end
    
    if(XFG.Config.Chat.Login.Main and inMainName ~= nil) then
        text = text .. '(' .. inMainName .. ') '
    end

    if(XFG.Config.Chat.Login.Guild) then
        text = text .. '<' .. inGuild:GetInitials() .. '> '
    end
    
    if(inType == XFG.Settings.Network.Message.Subject.LOGOUT) then
        text = text .. XFG.Lib.Locale['CHAT_LOGOUT']
    elseif(inType == XFG.Settings.Network.Message.Subject.JOIN) then
        text = text .. XFG.Lib.Locale['CHAT_JOIN_CONFEDERATE']
    elseif(inType == XFG.Settings.Network.Message.Subject.LOGIN) then
        text = text .. XFG.Lib.Locale['CHAT_LOGIN']
        if(XFG.Config.Chat.Login.Sound and not XFG.Player.Guild:Equals(inGuild)) then
            PlaySound(3332, 'Master')
        end
    end
    SendSystemMessage(text) 
end

function SystemFrame:DisplayJoinMessage(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), 'argument must be Message type object')
    local unitData = inMessage:GetData()
    self:Display(inMessage:GetSubject(), unitData:GetName(), unitData:GetUnitName(), unitData:GetMainName(), unitData:GetGuild(), unitData:GetRealm())
end

function SystemFrame:DisplayLoginMessage(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), 'argument must be Message type object')
    local unitData = inMessage:GetData()
    self:Display(inMessage:GetSubject(), unitData:GetName(), unitData:GetUnitName(), unitData:GetMainName(), unitData:GetGuild(), unitData:GetRealm())
end

function SystemFrame:DisplayLogoutMessage(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), 'argument must be Message type object')
    self:Display(inMessage:GetSubject(), inMessage:GetName(), inMessage:GetUnitName(), inMessage:GetMainName(), inMessage:GetGuild(), inMessage:GetRealm())
end
--#endregion