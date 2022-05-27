local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'ChannelEvent'
local LogCategory = 'H' .. ObjectName

ChannelEvent = {}

function ChannelEvent:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(typeof == 'table') then
        Object = inObject
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject == true) then
        self._Initialized = false
    end

    return Object
end

function ChannelEvent:Initialize()
	if(self:IsInitialized() == false) then
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
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function ChannelEvent:CallbackChannelNotice(inAction, _, _, _, _, _, inChannelType, inChannelNumber, inChannelName)
	-- Fires when player leaves a channel
	if(inAction == 'YOU_LEFT') then
		if(XFG.Channels:RemoveChannel(inChannelName)) then
			XFG:Info(LogCategory, "Removed channel [%d:%s] due to system event", inChannelNumber, inChannelName)
			if(XFG.Channels:GetAddonKey() == inChannelName) then
				XFG.Network.Sender:CanBroadcast(false)
				XFG:Error(LogCategory, "Removed channel was the addon channel")
			end			
		end

	-- Fires when player joins a channel
	elseif(inAction == 'YOU_CHANGED') then
		local _NewChannel = Channel:new()
		_NewChannel:SetKey(inChannelName)
		_NewChannel:SetID(inChannelNumber)
		_NewChannel:SetName(inChannelName)
		_NewChannel:SetShortName(inChannelName)
		_NewChannel:SetType(inChannelType)
		if(XFG.Network.Channels:AddChannel(_NewChannel)) then
			XFG:Info(LogCategory, "Added channel [%d:%s] due to system event", inChannelNumber, inChannelName)
			if(_NewChannel:GetShortName() == XFG.ChannelName) then
				XFG.Network.Sender:SetLocalChannel(_NewChannel)
				XFG.Network.Sender:CanBroadcast(true)
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
		if(_Channel:GetID() ~= _ChannelInfo.localID or _Channel:GetName() ~= _ChannelInfo.name or _Channel:GetShortName() ~= _ChannelInfo.shortcut) then
			XFG:Debug(LogCategory, "Passed [%d] [%s] [%s]", _ChannelInfo.localID, _ChannelInfo.name, _ChannelInfo.shortcut)
			_Channel:Print()
			_Channel:SetID(_ChannelInfo.localID)
			_Channel:SetName(_ChannelInfo.name)
			_Channel:SetShortName(_ChannelInfo.shortcut)
			XFG:Info(LogCategory, "Changed channel information due to CHANNEL_FLAGS_UPDATED event [%d:%s]", _Channel:GetID(), _Channel:GetShortName())
		end
	end
end

function ChannelEvent:CallbackDisconnect()
	XFG:Info(LogCategory, "Received CHAT_SERVER_DISCONNECTED system event")
	XFG.Network.Sender:CanBroadcast(false)
	XFG.Network.Sender:CanWhisper(false)
end

function ChannelEvent:CallbackReconnect()
	XFG:Info(LogCategory, "Received CHAT_SERVER_RECONNECTED system event")
	XFG.Network.Sender:CanBroadcast(true)
	XFG.Network.Sender:CanWhisper(true)
end