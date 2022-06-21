local XFG, G = unpack(select(2, ...))
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
		XFG:RegisterEvent('CHAT_MSG_CHANNEL_LEAVE', self.CallbackOffline)
		XFG:Info(LogCategory, "Registered for CHAT_MSG_CHANNEL_LEAVE events")
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
		if(XFG.Channels:RemoveChannel(inChannelShortName)) then
			local _Channel = XFG.Outbox:GetLocalChannel()
			if(_Channel:GetShortName() == inChannelShortName) then
				XFG:Error(LogCategory, "Removed channel was the addon channel")
			end
		end

	-- Fires when player joins a channel
	elseif(inAction == 'YOU_CHANGED') then
		XFG.Channels:ScanChannels()
	end
end

function ChannelEvent:CallbackChannelChange(inIndex)
	XFG.Channels:ScanChannel(inIndex)
end

function ChannelEvent:CallbackDisconnect()
	XFG:Info(LogCategory, "Received CHAT_SERVER_DISCONNECTED system event")
end

function ChannelEvent:CallbackReconnect()
	XFG:Info(LogCategory, "Received CHAT_SERVER_RECONNECTED system event")
end

function ChannelEvent:CallbackOffline(_, inUnitName, _, _, _, _, _, inChannelID, _, _, _, inGUID)
	XFG:Debug(LogCategory, "Received CHAT_MSG_CHANNEL_LEAVE system event")
	local _Channel = XFG.Outbox:GetLocalChannel()
	if(_Channel:GetID() == inChannelID and XFG.Confederate:Contains(inGUID)) then
		XFG:Info(LogCategory, 'Detected %s has left channel %s and presumed offline', inUnitName, _Channel:GetName())
		local _UnitData = XFG.Confederate:GetUnit(inGUID)
		XFG.Confederate:RemoveUnit(inGUID)
		XFG.Frames.System:DisplayLocalOffline(_UnitData)
		XFG.Links:RemoveNode(_UnitData:GetName())
		XFG.DataText.Guild:RefreshBroker()
		XFG.DataText.Links:RefreshBroker()
	end
end