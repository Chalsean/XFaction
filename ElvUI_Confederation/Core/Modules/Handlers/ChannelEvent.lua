local CON, E, L, V, P, G = unpack(select(2, ...))
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
		CON:RegisterEvent('CHAT_MSG_CHANNEL_NOTICE', self.CallbackChannelNotice)
        CON:Info(LogCategory, "Registered for CHAT_MSG_CHANNEL_NOTICE events")
		CON:RegisterEvent('CHANNEL_FLAGS_UPDATED', self.CallbackChannelChange)
        CON:Info(LogCategory, "Registered for CHANNEL_FLAGS_UPDATED events")
		CON:RegisterEvent('CHAT_SERVER_DISCONNECTED', self.CallbackDisconnect)
		CON:Info(LogCategory, "Registered for CHAT_SERVER_DISCONNECTED events")
		CON:RegisterEvent('CHAT_SERVER_RECONNECTED', self.CallbackReconnect)
		CON:Info(LogCategory, "Registered for CHAT_SERVER_RECONNECTED events")		
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
    CON:SingleLine(LogCategory)
    CON:Debug(LogCategory, ObjectName .. " Object")
    CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function ChannelEvent:CallbackChannelNotice(inAction, _, _, _, _, _, inChannelType, inChannelNumber, inChannelName)
	if(inAction == 'YOU_LEFT') then
		if(CON.Channels:RemoveChannel(inChannelName)) then
			CON:Info(LogCategory, "Removed channel [%d:%s] due to system event", inChannelNumber, inChannelName)
			if(CON.Channels:GetAddonKey() == inChannelName) then
				CON.Network.Sender:CanBroadcast(false)
				CON:Error(LogCategory, "Removed channel was the addon channel")
			end			
		end
	elseif(inAction == 'YOU_CHANGED') then
		local _NewChannel = Channel:new()
		_NewChannel:SetKey(inChannelName)
		_NewChannel:SetID(inChannelNumber)
		_NewChannel:SetName(inChannelName)
		_NewChannel:SetShortName(inChannelName)
		_NewChannel:SetType(inChannelType)
		if(CON.Network.Channels:AddChannel(_NewChannel)) then
			CON:Info(LogCategory, "Added channel [%d:%s] due to system event", inChannelNumber, inChannelName)
			if(_NewChannel:GetShortName() == CON.ChannelName) then
				CON.Network.Sender:SetLocalChannel(_NewChannel)
				CON.Network.Sender:CanBroadcast(true)
			end
		end
	else
		CON:Warn(LogCategory, "Received unhandled channel system event [%s]", inAction)
	end
end

function ChannelEvent:CallbackChannelChange(inIndex)
	local _ChannelInfo = C_ChatInfo.GetChannelInfoFromIdentifier(inIndex)
	if(_ChannelInfo ~= nil and CON.Network.Channels:Contains(_ChannelInfo.shortcut)) then
		-- This event spams, so lets check before updating
		local _Channel = CON.Network.Channels:GetChannel(_ChannelInfo.shortcut)
		if(_Channel:GetID() ~= _ChannelInfo.localID or _Channel:GetName() ~= _ChannelInfo.name or _Channel:GetShortName() ~= _ChannelInfo.shortcut) then
			_Channel:SetID(_ChannelInfo.localID)
			_Channel:SetName(_ChannelInfo.name)
			_Channel:SetShortName(_ChannelInfo.shortcut)
			CON:Info(LogCategory, "Changed channel information due to CHANNEL_FLAGS_UPDATED event [%d:%s]", _Channel:GetID(), _Channel:GetShortName())
		end
	end
end

function ChannelEvent:CallbackDisconnect()
	CON:Info(LogCategory, "Received CHAT_SERVER_DISCONNECTED system event")
	CON.Network.Sender:CanBroadcast(false)
	CON.Network.Sender:CanWhisper(false)
end

function ChannelEvent:CallbackReconnect()
	CON:Info(LogCategory, "Received CHAT_SERVER_DISCONNECTED system event")
	CON.Network.Sender:CanBroadcast(true)
	CON.Network.Sender:CanWhisper(false)
end