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
	XFG:Debug(LogCategory, 'Added channel [%s]', inChannel:GetName())
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
	if(not XFG.Config.Chat.Channel.Last) then return end
	if(not self:Contains(inKey)) then return end
	
	self:ScanChannels()
	local _Channel = self:GetChannel(inKey)

	for i = _Channel:GetID() + 1, 10 do
		local _NextChannel = self:GetChannelByID(i)
		if(_NextChannel ~= nil) then
			XFG:Debug(LogCategory, 'Swapping [%d:%s] and [%d:%s]', _Channel:GetID(), _Channel:GetName(), _NextChannel:GetID(), _NextChannel:GetName())
			C_ChatInfo.SwapChatChannelsByChannelIndex(_Channel:GetID(), i)
			_NextChannel:SetID(_Channel:GetID())
			_Channel:SetID(i)
		end
	end

	if(XFG.Config.Chat.Channel.Color) then
		for _, _Channel in self:Iterator() do
			if(XFG.Config.Channels[_Channel:GetName()] ~= nil) then
				local _Color = XFG.Config.Channels[_Channel:GetName()]
				ChangeChatColor('CHANNEL' .. _Channel:GetID(), _Color.R, _Color.G, _Color.B)
				XFG:Debug(LogCategory, 'Set channel [%s] RGB [%f:%f:%f]', _Channel:GetName(), _Color.R, _Color.G, _Color.B)
			end		
		end
	end
end

function ChannelCollection:ScanChannels()
	try(function ()
		local _Channels = {GetChannelList()}
		local _IDs = {}
		for i = 1, #_Channels, 3 do
			local _ChannelID, _ChannelName, _Disabled = _Channels[i], _Channels[i+1], _Channels[i+2]
			_IDs[_ChannelID] = true
			if(self:Contains(_ChannelName)) then
				local _Channel = self:GetChannel(_ChannelName)
				if(_Channel:GetID() ~= _ChannelID) then
					local _OldID = _Channel:GetID()
					_Channel:SetID(_ChannelID)
					XFG:Debug(LogCategory, 'Channel ID changed [%d:%d:%s]', _OldID, _Channel:GetID(), _Channel:GetName())
				end
			else
				local _NewChannel = Channel:new()
				_NewChannel:SetKey(_ChannelName)
				_NewChannel:SetName(_ChannelName)
				_NewChannel:SetID(_ChannelID)
				self:AddChannel(_NewChannel)
			end
		end

		for _, _Channel in self:Iterator() do
			if(_IDs[_Channel:GetID()] == nil) then
				self:RemoveChannel(_Channel)
			end
		end
	end).
	catch(function (inErrorMessage)
		XFG:Warn(LogCategory, 'Failed to scan channels: ' .. inErrorMessage)
	end)
end