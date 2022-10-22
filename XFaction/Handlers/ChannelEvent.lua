local XFG, G = unpack(select(2, ...))
local ObjectName = 'ChannelEvent'

ChannelEvent = Object:newChildConstructor()

--#region Constructors
function ChannelEvent:new()
	local object = ChannelEvent.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function ChannelEvent:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		XFG.Events:Add('ChannelChange', 'CHAT_MSG_CHANNEL_NOTICE', XFG.Handlers.ChannelEvent.CallbackChannelNotice)
		XFG.Events:Add('ChannelColor', 'UPDATE_CHAT_COLOR', XFG.Handlers.ChannelEvent.CallbackUpdateColor)
		self:IsInitialized(true)
	end
end
--#endregion

--#region Callbacks
function ChannelEvent:CallbackChannelNotice(inAction, _, _, _, _, _, inChannelType, inChannelNumber, inChannelName)
	try(function ()
		local channel = XFG.Channels:GetLocalChannel()
		
		if(inAction == 'YOU_LEFT') then
			if(inChannelName == channel:GetName()) then
				XFG:Error(ObjectName, 'Removed channel was the addon channel')			
				XFG.Channels:VoidLocalChannel()
			end
			XFG.Channels:Remove(channel:GetKey())

		elseif(inAction == 'YOU_CHANGED') then
			XFG.Channels:SetLast(channel:GetKey())

		elseif(inAction == 'YOU_JOINED') then
			local newChannel = Channel:new()
		    newChannel:SetKey(inChannelName)
		    newChannel:SetID(inChannelNumber)
			newChannel:SetName(inChannelName)
		    XFG.Channels:Add(newChannel)
			XFG.Channels:SetLast(channel:GetKey())
		end
	end).
	catch(function (inErrorMessage)
		XFG:Warn(ObjectName, inErrorMessage)
	end)
end

function ChannelEvent:CallbackUpdateColor(inChannel, inR, inG, inB)
	try(function ()
		if(inChannel) then
			local channelID = tonumber(inChannel:match("(%d+)$"))
			local channel = XFG.Channels:GetByID(channelID)
			if(channel ~= nil) then
				if(XFG.Config.Channels[channel:GetName()] == nil) then
					XFG.Config.Channels[channel:GetName()] = {}
				end
				XFG.Config.Channels[channel:GetName()].R = inR
				XFG.Config.Channels[channel:GetName()].G = inG
				XFG.Config.Channels[channel:GetName()].B = inB
				if(XFG.Verbosity) then
					XFG:Debug(ObjectName, 'Captured new RGB [%f:%f:%f] for channel [%s]', inR, inG, inB, channel:GetName())
				end
			end
		end
	end).
	catch(function (inErrorMessage)
		XFG:Error(ObjectName, inErrorMessage)
	end)
end
--#endregion