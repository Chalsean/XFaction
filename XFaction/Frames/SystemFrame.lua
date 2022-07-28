local XFG, G = unpack(select(2, ...))
local ObjectName = 'SystemFrame'
local LogCategory = 'FSystem'

SystemFrame = {}

function SystemFrame:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Initialized = false

    return Object
end

function SystemFrame:Initialize()
	if(self:IsInitialized() == false) then
		self:SetKey(math.GenerateUID())
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function SystemFrame:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function SystemFrame:Print()
	XFG:SingleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. ' Object')
	XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
    XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
end

function SystemFrame:GetKey()
    return self._Key
end

function SystemFrame:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
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
    elseif(inType == XFG.Settings.Network.Message.Subject.LOGIN) then
        _Message = _Message .. XFG.Lib.Locale['CHAT_LOGIN']
        if(XFG.Config.Chat.Login.Sound and not XFG.Player.Guild:Equals(inGuild)) then
            PlaySound(3332, 'Master')
        end
    end
    SendSystemMessage(_Message) 
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

function SystemFrame:DisplayLocalOffline(inUnitData)
    assert(type(inUnitData) == 'table' and inUnitData.__name ~= nil and inUnitData.__name == 'Unit', 'argument must be Unit object')

    local _Faction = inUnitData:GetFaction()
    local _Guild = inUnitData:GetGuild()
    local _Message = ''
    
    if(XFG.Config.Chat.Login.Faction) then  
        _Message = format('%s ', format(XFG.Icons.String, _Faction:GetIconID()))
    end
    
    _Message = _Message .. inUnitData:GetName() .. ' '
    
    if(XFG.Config.Chat.Login.Main and _MainName ~= nil) then
        _Message = _Message .. '(' .. _MainName .. ') '
    end

    if(XFG.Config.Chat.Login.Guild) then
        _Message = _Message .. '<' .. _Guild:GetInitials() .. '> ' 
    end
    
    _Message = _Message.. XFG.Lib.Locale['CHAT_LOGOUT']
    SendSystemMessage(_Message) 
end