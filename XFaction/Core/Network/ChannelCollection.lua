local XFG, G = unpack(select(2, ...))
local ObjectName = 'ChannelCollection'
local LogCategory = 'NCChannel'

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

function ChannelCollection:GetChannelByID(inID)
	assert(type(inID) == 'number')
	for _, _Channel in self:Iterator() do
		if(_Channel:GetID() == inID) then
			return _Channel
		end
	end
end

function ChannelCollection:AddChannel(inChannel)
    assert(type(inChannel) == 'table' and inChannel.__name ~= nil and inChannel.__name == 'Channel', "argument must be Channel object")
	if(self:Contains(inChannel:GetKey()) == false) then
		self._ChannelCount = self._ChannelCount + 1
	end
	self._Channels[inChannel:GetKey()] = inChannel
	XFG.Cache.Channels[inChannel:GetKey()] = inChannel:GetShortName()
	XFG:Debug(LogCategory, 'Added channel [%s]', inChannel:GetShortName())
	return self:Contains(inChannel:GetKey())
end

function ChannelCollection:RemoveChannel(inKey)
	assert(type(inKey) == 'string')
	if(self:Contains(inKey)) then
		self._Channels[inKey] = nil
		XFG.Cache.Channels[inKey] = nil
		self._ChannelCount = self._ChannelCount - 1
	end
	XFG:Debug(LogCategory, 'Removed channel [%s]', inKey)
	return self:Contains(inKey) == false	
end

function ChannelCollection:Iterator()
	return next, self._Channels, nil
end

function ChannelCollection:GetCount()
	return self._ChannelCount
end

function ChannelCollection:SetChannelLast(inKey)
	if(not XFG.Config.Chat.ChannelLast.Enable) then return end
	if(not self:Contains(inKey)) then return end
	local _Channel = self:GetChannel(inKey)
	local _TotalChannels = C_ChatInfo.GetNumActiveChannels()
	if(_Channel:GetID() ~= _TotalChannels) then
		XFG:Debug(LogCategory, 'Moving channel to last place [%s]', inKey)
		for i = _Channel:GetID(), _TotalChannels - 1 do
			C_ChatInfo.SwapChatChannelsByChannelIndex(i, i + 1)
		end
		_Channel:SetID(_TotalChannels)
	end
end