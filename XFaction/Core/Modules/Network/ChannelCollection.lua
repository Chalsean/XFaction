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
		if(XFG.Config.Channel.Channels == nil) then
			XFG.Config.Channel.Channels = {}
		end
		self:ScanChannels()
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

local function GetFrameID(inChannelName)
	for i = 1, NUM_CHAT_WINDOWS do
		local _Frame = 'ChatFrame' .. i
		if _G[_Frame] then
			for _, _ChannelName in pairs (_G[_Frame].channelList) do
				if(inChannelName == _ChannelName) then
					return i
				end
			end
		end
	end
end

function ChannelCollection:ScanChannels()
	self._Channels = {}
	self._ChannelCount = 0

	-- Repopulate channels, the channel events are not very trustworthy
	for i = 1, TotalChannels do
		self:ScanChannel(i)
	end

	self:SyncChannels()
end

function ChannelCollection:ScanChannel(inIndex)
	local _ChannelInfo = C_ChatInfo.GetChannelInfoFromIdentifier(inIndex)
	if(_ChannelInfo ~= nil) then
		local _Channel = nil
		if(self:Contains(_ChannelInfo.shortcut)) then
			_Channel = self:GetChannel(_ChannelInfo.shortcut)
		else
			_Channel = Channel:new()
			_Channel:SetKey(_ChannelInfo.shortcut)
			_Channel:SetID(inIndex)
			_Channel:SetShortName(_ChannelInfo.shortcut)
			self:AddChannel(_Channel)
		end

		_Channel:SetType(_ChannelInfo.channelType)
		-- Because the ElvUI and Blizzard APIs don't like each other
		if(_ChannelInfo.channelType == 0) then
			_Channel:SetName(tostring(_ChannelInfo.localID) .. ". " .. _ChannelInfo.shortcut)
		else
			_Channel:SetName(_ChannelInfo.name)
		end

		if(_Channel:GetKey() == XFG.Network.Channel.Name) then
			XFG.Network.Outbox:SetLocalChannel(_Channel)
		end
		if(XFG.Config.Channel.Channels['Channel' .. tostring(_Channel:GetID())] == nil) then
			XFG.Config.Channel.Channels['Channel' .. tostring(_Channel:GetID())] = _Channel:GetKey()
		end
		XFG.Cache.Channels[_Channel:GetKey()] = _Channel:GetShortName()	
	end
end

function ChannelCollection:SyncChannels()
	for i = 1, 10 do
		local _ChannelNode = 'Channel' .. tostring(i)
		XFG.Options.args.Channel.args.Channels.args[_ChannelNode].values = XFG.Cache.Channels

		if(XFG.Config.Channel.Enable) then
			-- Ensure the channels are in the correct order
			local _ChannelKey = XFG.Config.Channel.Channels[_ChannelNode]
			if(_ChannelKey ~= nil) then
				local _Channel = self:GetChannel(_ChannelKey)
				if(_Channel ~= nil) then
					if(i ~= _Channel:GetID()) then
						local _SwapChannel = self:GetChannelByID(i)
						if(_SwapChannel ~= nil) then
							C_ChatInfo.SwapChatChannelsByChannelIndex(_Channel:GetID(), _SwapChannel:GetID())
							_SwapChannel:SetID(_Channel:GetID())
							_Channel:SetID(i)
						end
					end
				end
			end
		end
	end
end

function ChannelCollection:GetCount()
	return self._ChannelCount
end