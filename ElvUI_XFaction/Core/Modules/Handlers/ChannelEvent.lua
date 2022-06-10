local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'ChannelEvent'
local LogCategory = 'HEChannel'

ChannelEvent = {}

function ChannelEvent:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

	self._Key = nil
    self._Initialized = false

    return _Object
end

function ChannelEvent:Initialize()
	if(self:IsInitialized() == false) then
		self:SetKey(math.GenerateUID())
		XFG:RegisterEvent('CHAT_MSG_CHANNEL_NOTICE', self.CallbackChannelNotice)
        XFG:Info(LogCategory, "Registered for CHAT_MSG_CHANNEL_NOTICE events")
		XFG:RegisterEvent('CHANNEL_FLAGS_UPDATED', self.CallbackChannelChange)
        XFG:Info(LogCategory, "Registered for CHANNEL_FLAGS_UPDATED events")
		XFG:RegisterEvent('CHAT_SERVER_DISCONNECTED', self.CallbackDisconnect)
		XFG:Info(LogCategory, "Registered for CHAT_SERVER_DISCONNECTED events")
		XFG:RegisterEvent('CHAT_SERVER_RECONNECTED', self.CallbackReconnect)
		XFG:Info(LogCategory, "Registered for CHAT_SERVER_RECONNECTED events")		
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function ChannelEvent:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function ChannelEvent:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function ChannelEvent:GetKey()
    return self._Key
end

function ChannelEvent:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function ChannelEvent:CallbackChannelNotice(inAction, _, _, inChannelName, _, _, inChannelType, inChannelNumber, inChannelShortName)
	-- Fires when player leaves a channel
	if(inAction == 'YOU_LEFT') then
		if(XFG.Network.Channels:RemoveChannel(inChannelShortName)) then
			XFG:Info(LogCategory, "Removed channel [%d:%s] due to system event", inChannelNumber, inChannelShortName)
			local _Channel = XFG.Network.Outbox:GetLocalChannel()
			if(_Channel:GetShortName() == inChannelShortName) then
				XFG.Network.Outbox:CanBroadcast(false)
				XFG:Error(LogCategory, "Removed channel was the addon channel")
			end			
		end

	-- Fires when player joins a channel
	elseif(inAction == 'YOU_CHANGED') then
		local _NewChannel = Channel:new()
		_NewChannel:SetKey(inChannelShortName)
		_NewChannel:SetID(inChannelNumber)		
		_NewChannel:SetShortName(inChannelShortName)
		_NewChannel:SetType(inChannelType)
		-- Because the ElvUI and Blizzard APIs don't like each other
		if(inChannelType == 0) then
			_NewChannel:SetName(tostring(inChannelNumber) .. ". " .. inChannelShortName)
		else
			_NewChannel:SetName(inChannelName)
		end
		if(XFG.Network.Channels:AddChannel(_NewChannel)) then
			XFG:Info(LogCategory, "Added channel [%d:%s] due to system event", inChannelNumber, inChannelShortName)
			if(_NewChannel:GetShortName() == XFG.Network.ChannelName) then
				XFG.Network.Outbox:SetLocalChannel(_NewChannel)
				XFG.Network.Outbox:CanBroadcast(true)
			end
		end
	else
		XFG:Warn(LogCategory, "Received unhandled channel system event [%s]", inAction)
	end
end

function ChannelEvent:CallbackChannelChange(inIndex)
	local _ChannelInfo = C_ChatInfo.GetChannelInfoFromIdentifier(inIndex)
	if(_ChannelInfo ~= nil and XFG.Network.Channels:Contains(_ChannelInfo.shortcut)) then
		-- This event spams, so lets check before updating
		local _Channel = XFG.Network.Channels:GetChannel(_ChannelInfo.shortcut)
		if(_Channel:GetID() ~= _ChannelInfo.localID or _Channel:GetShortName() ~= _ChannelInfo.shortcut) then
			_Channel:SetID(_ChannelInfo.localID)
			_Channel:SetShortName(_ChannelInfo.shortcut)
			-- Because the ElvUI and Blizzard APIs don't like each other
			if(_ChannelInfo.channelType == 0) then
				_Channel:SetName(tostring(_ChannelInfo.localID) .. '. ' .. _ChannelInfo.shortcut)
			else
				_Channel:SetName(_ChannelInfo.name)
			end
			XFG:Info(LogCategory, "Changed channel information due to CHANNEL_FLAGS_UPDATED event [%d:%s]", _Channel:GetID(), _Channel:GetShortName())
		end
	end
end

function ChannelEvent:CallbackDisconnect()
	XFG:Info(LogCategory, "Received CHAT_SERVER_DISCONNECTED system event")
	XFG.Network.Outbox:CanBroadcast(false)
end

function ChannelEvent:CallbackReconnect()
	XFG:Info(LogCategory, "Received CHAT_SERVER_RECONNECTED system event")
	XFG.Network.Outbox:CanBroadcast(true)
end
