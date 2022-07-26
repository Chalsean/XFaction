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
	if(not self:IsInitialized()) then
		self:SetKey(math.GenerateUID())
		XFG:RegisterEvent('CHAT_MSG_CHANNEL_NOTICE', XFG.Handlers.ChannelEvent.CallbackChannelNotice)
		XFG:Info(LogCategory, 'Registered to receive CHAT_MSG_CHANNEL_NOTICE events')
		--XFG:RegisterEvent('CHANNEL_FLAGS_UPDATED', XFG.Handlers.ChannelEvent.CallbackChannelChange)
		--XFG:Info(LogCategory, 'Registered to receive CHANNEL_FLAGS_UPDATED events')
		XFG:RegisterEvent('UPDATE_CHAT_COLOR', XFG.Handlers.ChannelEvent.CallbackUpdateColor)
		XFG:Info(LogCategory, 'Registered to receive UPDATE_CHAT_COLOR events')
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

function ChannelEvent:CallbackChannelNotice(inAction, _, _, _, _, _, inChannelType, inChannelNumber, inChannelName)
	try(function ()
		local _Channel = XFG.Outbox:GetLocalChannel()
		
		if(inAction == 'YOU_LEFT') then
			if(inChannelName == _Channel:GetName()) then
				XFG:Error(LogCategory, 'Removed channel was the addon channel')			
				XFG.Outbox:VoidLocalChannel()
			end
			XFG.Channels:RemoveChannel(_Channel:GetKey())

		elseif(inAction == 'YOU_CHANGED') then
			XFG.Channels:SetChannelLast(_Channel:GetKey())

		elseif(inAction == 'YOU_JOINED') then
			local _NewChannel = Channel:new()
		    _NewChannel:SetKey(inChannelName)
		    _NewChannel:SetID(inChannelNumber)
		   	_NewChannel:SetName(inChannelName)
		    XFG.Channels:AddChannel(_NewChannel)
			XFG.Channels:SetChannelLast(_Channel:GetKey())
		end
	end)
	.catch(function (inErrorMessage)
		XFG:Warn(LogCategory, 'Failed to update channel information based on event: ' .. inErrorMessage)
	end)
end

function ChannelEvent:CallbackChannelChange(inChannelIndex)
	try(function ()
		if(XFG.Outbox:HasLocalChannel()) then
			XFG.Channels:SetChannelLast(XFG.Outbox:GetLocalChannel():GetKey())
		end
	end)
	.catch(function (inErrorMessage)
		XFG:Error(LogCategory, 'Failure moving channel: ' .. inErrorMessage)
	end)
end

function ChannelEvent:CallbackUpdateColor(inChannel, inR, inG, inB)
	try(function ()
		if(inChannel) then
			local _ChannelID = tonumber(inChannel:match("(%d+)$"))
			local _Channel = XFG.Channels:GetChannelByID(_ChannelID)
			if(_Channel ~= nil) then
				if(XFG.Config.Channels[_Channel:GetName()] == nil) then
					XFG.Config.Channels[_Channel:GetName()] = {}
				end
				XFG.Config.Channels[_Channel:GetName()].R = inR
				XFG.Config.Channels[_Channel:GetName()].G = inG
				XFG.Config.Channels[_Channel:GetName()].B = inB
				XFG:Debug(LogCategory, 'Captured new RGB [%f:%f:%f] for channel [%s]', inR, inG, inB, _Channel:GetName())
			end
		end
	end)
	.catch(function (inErrorMessage)
		XFG:Error(LogCategory, 'Failure capturing channel color: ' .. inErrorMessage)
	end)
end