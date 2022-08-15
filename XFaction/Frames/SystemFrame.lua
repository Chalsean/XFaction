local XFG, G = unpack(select(2, ...))

SystemFrame = Object:newChildConstructor()

function SystemFrame:new()
    local _Object = SystemFrame.parent.new(self)
    _Object.__name = 'SystemFrame'
    return _Object
end

function SystemFrame:Display(inType, inName, inUnitName, inMainName, inGuild, inRealm)
    if(not XFG.Config.Chat.Login.Enable) then return end
    assert(type(inName) == 'string')
    assert(type(inUnitName) == 'string')
    assert(type(inGuild) == 'table' and inGuild.__name ~= nil and inGuild.__name == 'Guild', 'argument must be Guild object')
    assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', 'argument must be Realm object')

    local _Faction = inGuild:GetFaction()
    local _Message = XFG.Settings.Frames.Chat.Prepend
    
    if(XFG.Config.Chat.Login.Faction) then  
        _Message = _Message .. format('%s ', format(XFG.Icons.String, _Faction:GetIconID()))
    end
  
    if(inType == XFG.Settings.Network.Message.Subject.LOGOUT) then
        _Message = _Message .. inName .. ' '
    elseif(_Faction:Equals(XFG.Player.Faction)) then
        _Message = _Message .. format('|Hplayer:%s|h[%s]|h', inUnitName, inName) .. ' '
    else
        local _Friend = XFG.Friends:GetFriendByRealmUnitName(inRealm, inName)
        if(_Friend ~= nil) then
            _Message = _Message .. format('|HBNplayer:%s:%d:1:WHISPER:%s|h[%s]|h', _Friend:GetAccountName(), _Friend:GetAccountID(), _Friend:GetTag(), inName) .. ' '
        else
            -- Maybe theyre in a bnet community together, no way to associate tho
            _Message = _Message .. format('|Hplayer:%s|h[%s]|h', inUnitName, inName) .. ' '
        end
    end
    
    if(XFG.Config.Chat.Login.Main and inMainName ~= nil) then
        _Message = _Message .. '(' .. inMainName .. ') '
    end

    if(XFG.Config.Chat.Login.Guild) then
        _Message = _Message .. '<' .. inGuild:GetInitials() .. '> '
    end
    
    if(inType == XFG.Settings.Network.Message.Subject.LOGOUT) then
        _Message = _Message .. XFG.Lib.Locale['CHAT_LOGOUT']
    elseif(inType == XFG.Settings.Network.Message.Subject.JOIN) then
        _Message = _Message .. XFG.Lib.Locale['CHAT_JOIN_CONFEDERATE']
    elseif(inType == XFG.Settings.Network.Message.Subject.LOGIN) then
        _Message = _Message .. XFG.Lib.Locale['CHAT_LOGIN']
        if(XFG.Config.Chat.Login.Sound and not XFG.Player.Guild:Equals(inGuild)) then
            PlaySound(3332, 'Master')
        end
    end
    SendSystemMessage(_Message) 
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