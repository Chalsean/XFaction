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
		XFG.Events:Add({name = 'ChannelChange', 
		                event = 'CHAT_MSG_CHANNEL_NOTICE', 
						callback = XFG.Handlers.ChannelEvent.CallbackChannelNotice, 
						instance = true,
						groupDelta = XFG.Settings.Network.Channel.NoticeTimer,
						start = true})
		XFG.Events:Add({name = 'ChannelColor', 
		                event = 'UPDATE_CHAT_COLOR', 
						callback = XFG.Handlers.ChannelEvent.CallbackUpdateColor, 
						instance = true,
					    start = true})
		self:IsInitialized(true)
	end
end
--#endregion

--#region Callbacks
function ChannelEvent:CallbackChannelNotice()
	try(function ()
		XFG.Channels:Scan()
		XFG.Channels:SetLast(XFG.Channels:GetLocalChannel():GetKey())
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
				XFG:Debug(ObjectName, 'Captured new RGB [%f:%f:%f] for channel [%s]', inR, inG, inB, channel:GetName())
			end
		end
	end).
	catch(function (inErrorMessage)
		XFG:Error(ObjectName, inErrorMessage)
	end)
end
--#endregion