local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'GuildBroker'
local LogCategory = 'BGuild'

GuildBroker = {}

function GuildBroker:new(inObject)
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
        self._BrokerData = {}
        self._Initialized = false
    end

    return Object
end

function GuildBroker:RegisterLDBCallback()
    XFG:Debug(LogCategory, "do something 2")
end

function GuildBroker:Initialize()
	if(self:IsInitialized() == false) then
		self:SetKey(math.GenerateUID())
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function GuildBroker:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function GuildBroker:Print()
	XFG:SingleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
end

function GuildBroker:GetKey()
    return self._Key
end

function GuildBroker:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function GuildBroker:RefreshDT()
    
    --if(XFG.DataText.Guild:IsEnabled()) then
        -- local _OnlineUnits = XFG.Guild:GetOnlineUnits()
        -- wipe(self._BrokerData)
        -- XFG:Debug(LogCategory, "got here")
        -- for _, _Unit in pairs (_OnlineUnits) do
        --     table.insert(self._BrokerData, _Unit)
        -- end
    --end
end