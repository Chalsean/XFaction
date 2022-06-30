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

function SystemFrame:Display(inMessage)
    if(XFG.Config.Chat.Login.Enable == false) then return end
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), 'argument must be Message type object')

    local _Name = nil
    local _UnitName = nil -- Fully qualified name
    local _MainName = nil
    local _Guild = nil
    local _Realm = nil

    if(inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.LOGIN) then
        local _UnitData = inMessage:GetData()
        _Name = _UnitData:GetName()
        _UnitName = _UnitData:GetUnitName()
        _Guild = _UnitData:GetGuild()
        _Realm = _UnitData:GetRealm()
        if(_UnitData:HasMainName()) then
            _MainName = _UnitData:GetMainName()
        end        
    else
        _Name = inMessage:GetName()
        _UnitName = inMessage:GetUnitName()
        _MainName = inMessage:GetMainName()
        _Guild = inMessage:GetGuild()
        _Realm = inMessage:GetRealm()
    end

    local _Faction = _Guild:GetFaction()
    local _Link = nil
    local _Message = ''
    
    if(XFG.Config.Chat.Login.Faction) then  
        _Message = format('%s ', format(XFG.Icons.String, _Faction:GetIconID()))
    end
  
    if(inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.LOGOUT) then
        _Message = _Message .. _Name .. ' '
    elseif(_Faction:Equals(XFG.Player.Faction)) then
        _Message = _Message .. format('|Hplayer:%s|h[%s]|h', _UnitName, _Name) .. ' '
    else
        local _Friend = XFG.Friends:GetFriendByRealmUnitName(_Realm, _Name)
        if(_Friend ~= nil) then
            _Message = _Message .. format('|HBNplayer:%s:%d:1:WHISPER:%s|h[%s]|h', _Friend:GetAccountName(), _Friend:GetAccountID(), _Friend:GetTag(), _Name) .. ' '
        else
            _Message = _Message .. _Name .. ' '
        end
    end
    
    if(XFG.Config.Chat.Login.Main and _MainName ~= nil) then
        _Message = _Message .. '(' .. _MainName .. ') '
    end

    if(XFG.Config.Chat.Login.Guild) then
        _Message = _Message .. '<' .. _Guild:GetInitials() .. '> '
    end
    
    if(inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.LOGOUT) then
        _Message = _Message .. XFG.Lib.Locale['CHAT_LOGOUT']
    elseif(inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.LOGIN) then
        _Message = _Message .. XFG.Lib.Locale['CHAT_LOGIN']
        if(XFG.Config.Chat.Login.Sound) then
            PlaySound(3332, 'Master')
        end
    end
    SendSystemMessage(_Message) 
end

function SystemFrame:DisplayLocalOffline(inUnitData)
    if(XFG.Config.Chat.Login.Enable == false) then return end
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