local XFG, G = unpack(select(2, ...))
local ObjectName = 'SystemFrame'

SystemFrame = Object:newChildConstructor()

function SystemFrame:new()
    local object = SystemFrame.parent.new(self)
    object.__name = ObjectName
    return object
end

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
    local _UnitData = inMessage:GetData()
    self:Display(inMessage:GetSubject(), _UnitData:GetName(), _UnitData:GetUnitName(), _UnitData:GetMainName(), _UnitData:GetGuild(), _UnitData:GetRealm())
end

function SystemFrame:DisplayLoginMessage(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), 'argument must be Message type object')
    local _UnitData = inMessage:GetData()
    self:Display(inMessage:GetSubject(), _UnitData:GetName(), _UnitData:GetUnitName(), _UnitData:GetMainName(), _UnitData:GetGuild(), _UnitData:GetRealm())
end

function SystemFrame:DisplayLogoutMessage(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), 'argument must be Message type object')
    self:Display(inMessage:GetSubject(), inMessage:GetName(), inMessage:GetUnitName(), inMessage:GetMainName(), inMessage:GetGuild(), inMessage:GetRealm())
end