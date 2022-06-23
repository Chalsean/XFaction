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
		XFG:CreateEvent('ChannelJoin', 'CHAT_MSG_CHANNEL_NOTICE', XFG.Handlers.ChannelEvent.CallbackChannelNotice, true, true)
		XFG:CreateEvent('ChannelChange', 'CHANNEL_FLAGS_UPDATED', XFG.Handlers.ChannelEvent.CallbackChannelChange, true, true)
		XFG:CreateEvent('ChannelLeave', 'CHAT_MSG_CHANNEL_LEAVE', XFG.Handlers.ChannelEvent.CallbackOffline, true, true)
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
	local _Channel = XFG.Outbox:GetLocalChannel()
	-- Fires when player leaves a channel
	if(inAction == 'YOU_LEFT' and XFG.Settings.Network.Channel.Name == inChannelShortName) then
		XFG.Channels:RemoveChannel(inChannelShortName)
		XFG:Error(LogCategory, "Removed channel was the addon channel")

	-- Fires when player joins a channel
	elseif(inAction == 'YOU_CHANGED' and XFG.Settings.Network.Channel.Name == inChannelShortName) then
		if(XFG.Outbox:HasLocalChannel()) then
			local _Channel = XFG.Outbox:GetLocalChannel()
			_Channel:SetID(inChannelNumber)
		else
			local _NewChannel = Channel:new()
			_NewChannel:SetKey(inChannelShortName)
			_NewChannel:SetID(inChannelNumber)
			_NewChannel:SetShortName(inChannelShortName)
			XFG.Channels:AddChannel(_NewChannel)
			XFG.Outbox:SetLocalChannel(_NewChannel)
		end
	end
end

function ChannelEvent:CallbackChannelChange(inIndex)
	XFG.Channels:ScanChannel(inIndex)
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
	end
end