local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'ChannelCollection'
local LogCategory = 'OCChannel'
local TotalChannels = 10

ChannelCollection = {}

function ChannelCollection:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or 
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(_typeof == 'table') then
        Object = inObject
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject == true) then
        self._Channels = {}
		self._ChannelCount = 0
		self._Initialized = false
    end

    return Object
end

function ChannelCollection:Initialize()
	if(self:IsInitialized() == false) then
		for i = 1, TotalChannels do
			local _ChannelInfo = C_ChatInfo.GetChannelInfoFromIdentifier(i)
			if(_ChannelInfo ~= nil) then
				local _NewChannel = Channel:new()
				_NewChannel:SetKey(_ChannelInfo.shortcut)
				_NewChannel:SetID(_ChannelInfo.localID)
				_NewChannel:SetName(_ChannelInfo.name)
				_NewChannel:SetShortName(_ChannelInfo.shortcut)
				_NewChannel:SetType(_ChannelInfo.channelType)
				if(self:AddChannel(_NewChannel) and _NewChannel:GetKey() == CON.Network.ChannelName) then
					CON.Network.Sender:SetLocalChannel(_NewChannel)
					CON.Network.Sender:CanBroadcast(true)
				end				
			end
		end
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function ChannelCollection:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function ChannelCollection:Print()
	CON:DoubleLine(LogCategory)
	CON:Debug(LogCategory, ObjectName .. " Object")
	CON:Debug(LogCategory, "  _ChannelCount (" .. type(self._ChannelCount) .. "): ".. tostring(self._ChannelCount))
	CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
	CON:Debug(LogCategory, "  _AddonKey (" .. type(self._AddonKey) .. "): ".. tostring(self._AddonKey))
	for _, _Channel in pairs (self._Channels) do
		_Channel:Print()
	end
end

function ChannelCollection:Contains(inKey)
	assert(type(inKey) == 'string')
	return self._Channels[inKey] ~= nil
end

function ChannelCollection:GetChannel(inKey)
	assert(type(inKey) == 'string')
    return self._Channels[inKey]
end

function ChannelCollection:AddChannel(inChannel)
    assert(type(inChannel) == 'table' and inChannel.__name ~= nil and inChannel.__name == 'Channel', "argument must be Channel object")
	if(self:Contains(inChannel:GetKey()) == false) then
		self._ChannelCount = self._ChannelCount + 1
	end
	self._Channels[inChannel:GetKey()] = inChannel
	return self:Contains(inChannel:GetKey())
end

function ChannelCollection:RemoveChannel(inKey)
	assert(type(inKey) == 'string')
	if(self:Contains(inKey)) then
		table.RemoveKey(self._Channels, inKey)
		self._ChannelCount = self._ChannelCount - 1
	end
	return self:Contains(inKey) == false
end