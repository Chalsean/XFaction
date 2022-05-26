local EKX, E, L, V, P, G = unpack(select(2, ...))
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
		EKX:RegisterEvent('CHAT_MSG_CHANNEL_NOTICE', self.CallbackChannelNotice)
        EKX:Info(LogCategory, "Registered for CHAT_MSG_CHANNEL_NOTICE events")
		EKX:RegisterEvent('CHANNEL_FLAGS_UPDATED', self.CallbackChannelChange)
        EKX:Info(LogCategory, "Registered for CHANNEL_FLAGS_UPDATED events")
		EKX:RegisterEvent('CHAT_SERVER_DISEKXNECTED', self.CallbackDisconnect)
		EKX:Info(LogCategory, "Registered for CHAT_SERVER_DISEKXNECTED events")
		EKX:RegisterEvent('CHAT_SERVER_REEKXNECTED', self.CallbackReconnect)
		EKX:Info(LogCategory, "Registered for CHAT_SERVER_REEKXNECTED events")		
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
    EKX:SingleLine(LogCategory)
    EKX:Debug(LogCategory, ObjectName .. " Object")
    EKX:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function ChannelEvent:CallbackChannelNotice(inAction, _, _, _, _, _, inChannelType, inChannelNumber, inChannelName)
	-- Fires when player leaves a channel
	if(inAction == 'YOU_LEFT') then
		if(EKX.Channels:RemoveChannel(inChannelName)) then
			EKX:Info(LogCategory, "Removed channel [%d:%s] due to system event", inChannelNumber, inChannelName)
			if(EKX.Channels:GetAddonKey() == inChannelName) then
				EKX.Network.Sender:CanBroadcast(false)
				EKX:Error(LogCategory, "Removed channel was the addon channel")
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
		if(EKX.Network.Channels:AddChannel(_NewChannel)) then
			EKX:Info(LogCategory, "Added channel [%d:%s] due to system event", inChannelNumber, inChannelName)
			if(_NewChannel:GetShortName() == EKX.ChannelName) then
				EKX.Network.Sender:SetLocalChannel(_NewChannel)
				EKX.Network.Sender:CanBroadcast(true)
			end
		end
	else
		EKX:Warn(LogCategory, "Received unhandled channel system event [%s]", inAction)
	end
end

function ChannelEvent:CallbackChannelChange(inIndex)
	local _ChannelInfo = C_ChatInfo.GetChannelInfoFromIdentifier(inIndex)
	if(_ChannelInfo ~= nil and EKX.Network.Channels:Contains(_ChannelInfo.shortcut)) then
		-- This event spams, so lets check before updating
		local _Channel = EKX.Network.Channels:GetChannel(_ChannelInfo.shortcut)
		if(_Channel:GetID() ~= _ChannelInfo.localID or _Channel:GetName() ~= _ChannelInfo.name or _Channel:GetShortName() ~= _ChannelInfo.shortcut) then
			EKX:Debug(LogCategory, "Passed [%d] [%s] [%s]", _ChannelInfo.localID, _ChannelInfo.name, _ChannelInfo.shortcut)
			_Channel:Print()
			_Channel:SetID(_ChannelInfo.localID)
			_Channel:SetName(_ChannelInfo.name)
			_Channel:SetShortName(_ChannelInfo.shortcut)
			EKX:Info(LogCategory, "Changed channel information due to CHANNEL_FLAGS_UPDATED event [%d:%s]", _Channel:GetID(), _Channel:GetShortName())
		end
	end
end

function ChannelEvent:CallbackDisconnect()
	EKX:Info(LogCategory, "Received CHAT_SERVER_DISEKXNECTED system event")
	EKX.Network.Sender:CanBroadcast(false)
	EKX.Network.Sender:CanWhisper(false)
end

function ChannelEvent:CallbackReconnect()
	EKX:Info(LogCategory, "Received CHAT_SERVER_DISEKXNECTED system event")
	EKX.Network.Sender:CanBroadcast(true)
	EKX.Network.Sender:CanWhisper(false)
end