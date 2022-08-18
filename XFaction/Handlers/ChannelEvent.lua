local XFG, G = unpack(select(2, ...))
local ObjectName = 'ChannelEvent'

ChannelEvent = Object:newChildConstructor()

function ChannelEvent:new()
	local _Object = ChannelEvent.parent.new(self)
    _Object.__name = ObjectName
    return _Object
end

function ChannelEvent:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		XFG:RegisterEvent('CHAT_MSG_CHANNEL_NOTICE', XFG.Handlers.ChannelEvent.CallbackChannelNotice)
		XFG:Info(ObjectName, 'Registered to receive CHAT_MSG_CHANNEL_NOTICE events')
		XFG:RegisterEvent('UPDATE_CHAT_COLOR', XFG.Handlers.ChannelEvent.CallbackUpdateColor)
		XFG:Info(ObjectName, 'Registered to receive UPDATE_CHAT_COLOR events')
		self:IsInitialized(true)
	end
end

function ChannelEvent:CallbackChannelNotice(inAction, _, _, _, _, _, inChannelType, inChannelNumber, inChannelName)
	try(function ()
		local _Channel = XFG.Outbox:GetLocalChannel()
		
		if(inAction == 'YOU_LEFT') then
			if(inChannelName == _Channel:GetName()) then
				XFG:Error(ObjectName, 'Removed channel was the addon channel')			
				XFG.Outbox:VoidLocalChannel()
			end
			XFG.Channels:RemoveObject(_Channel:GetKey())

		elseif(inAction == 'YOU_CHANGED') then
			XFG.Channels:SetChannelLast(_Channel:GetKey())

		elseif(inAction == 'YOU_JOINED') then
			local _NewChannel = Channel:new()
		    _NewChannel:SetKey(inChannelName)
		    _NewChannel:SetID(inChannelNumber)
		   	_NewChannel:SetName(inChannelName)
		    XFG.Channels:AddObject(_NewChannel)
			XFG.Channels:SetChannelLast(_Channel:GetKey())
		end
	end).
	catch(function (inErrorMessage)
		XFG:Warn(ObjectName, inErrorMessage)
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
				if(XFG.DebugFlag) then
					XFG:Debug(ObjectName, 'Captured new RGB [%f:%f:%f] for channel [%s]', inR, inG, inB, _Channel:GetName())
				end
			end
		end
	end).
	catch(function (inErrorMessage)
		XFG:Error(ObjectName, inErrorMessage)
	end)
end