local XFG, G = unpack(select(2, ...))
local ObjectName = 'SystemFrame'
local LogCategory = 'FSystem'
local IconTokenString = '|T%d:16:16:0:0:64:64:4:60:4:60|t'

SystemFrame = {}

function SystemFrame:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or 
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil, string or " .. ObjectName .. " object")

    if(_typeof == 'table') then
        Object = inObject
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject) then
        self._Key = nil
        self._Initialized = false
    end

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
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function SystemFrame:Print()
	XFG:SingleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
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
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be Message type object")
    local _Guild = XFG.Guilds:GetGuildByID(inMessage:GetGuildID())
    local _Faction = _Guild:GetFaction()
                    
    local _Message = format('%s ', format(IconTokenString, _Faction:GetIconID()))
    if(inMessage:GetSubject() == XFG.Network.Message.Subject.LOGOUT) then
        _Message = _Message .. inMessage:GetUnitName()
        if(inMessage:HasMainName()) then
            _Message = _Message .. ' (' .. inMessage:GetMainName() .. ')'
        end
    elseif(inMessage:GetSubject() == XFG.Network.Message.Subject.LOGIN) then
        local _UnitData = inMessage:GetData()
        _Message = _Message .. _UnitData:GetName()
        if(_UnitData:HasMainName()) then
            _Message = _Message .. ' (' .. _UnitData:GetMainName() .. ')'
        end
    end

    local _Guild = XFG.Guilds:GetGuildByID(inMessage:GetGuildID())
    _Message = _Message .. ' <' .. _Guild:GetShortName() .. '> '
    
    if(inMessage:GetSubject() == XFG.Network.Message.Subject.LOGOUT) then
        _Message = _Message .. 'has gone offline.'
    elseif(inMessage:GetSubject() == XFG.Network.Message.Subject.LOGIN) then
        _Message = _Message .. 'has come online.'
        if(XFG.Config.Chat.Login.Sound) then
            PlaySound(3332, 'Master')
        end
    end
    SendSystemMessage(_Message) 
end