local XFG, G = unpack(select(2, ...))
local ObjectName = 'ChannelCollection'
local LogCategory = 'NCChannel'
local TotalChannels = 10

ChannelCollection = {}

function ChannelCollection:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Channels = {}
    self._ChannelCount = 0
    self._Initialized = false
    
    return _Object
end

function ChannelCollection:Initialize()
	if(self:IsInitialized() == false) then
		self:SetKey(math.GenerateUID())
		for i = 1, TotalChannels do
			local _ChannelInfo = C_ChatInfo.GetChannelInfoFromIdentifier(i)
			if(_ChannelInfo ~= nil) then
				local _NewChannel = Channel:new()
				_NewChannel:SetKey(_ChannelInfo.shortcut)
				_NewChannel:SetID(_ChannelInfo.localID)
				_NewChannel:SetShortName(_ChannelInfo.shortcut)
				_NewChannel:SetType(_ChannelInfo.channelType)
				-- Because the ElvUI and Blizzard APIs don't like each other
				if(_ChannelInfo.channelType == 0) then
					_NewChannel:SetName(tostring(_ChannelInfo.localID) .. ". " .. _ChannelInfo.shortcut)
				else
					_NewChannel:SetName(_ChannelInfo.name)
				end
				if(self:AddChannel(_NewChannel) and _NewChannel:GetKey() == XFG.Network.ChannelName) then
					XFG.Network.Outbox:SetLocalChannel(_NewChannel)
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
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
	XFG:Debug(LogCategory, "  _ChannelCount (" .. type(self._ChannelCount) .. "): ".. tostring(self._ChannelCount))
	XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))	
	for _, _Channel in self:Iterator() do
		_Channel:Print()
	end
end

function ChannelCollection:GetKey()
    return self._Key
end

function ChannelCollection:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
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

function ChannelCollection:Iterator()
	return next, self._Channels, nil
end
