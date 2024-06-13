local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'ChannelEvent'

ChannelEvent = XFC.Object:newChildConstructor()

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
		XF.Events:Add({name = 'ChannelChange', 
		                event = 'CHAT_MSG_CHANNEL_NOTICE', 
						callback = XF.Handlers.ChannelEvent.CallbackChannelNotice,
						groupDelta = 3,
						instance = true,
						start = true})
		XF.Events:Add({name = 'ChannelColor', 
		                event = 'UPDATE_CHAT_COLOR', 
						callback = XF.Handlers.ChannelEvent.CallbackUpdateColor, 
						instance = true,
					    start = true})
		self:IsInitialized(true)
	end
end
--#endregion

--#region Callbacks
function ChannelEvent:CallbackChannelNotice()
	try(function ()
		XF.Channels:Sync()
	end).
	catch(function (inErrorMessage)
		XF:Warn(ObjectName, inErrorMessage)
	end)
end

function ChannelEvent:CallbackUpdateColor(inChannel, inR, inG, inB)
	try(function ()
		if(inChannel) then
			local channelID = tonumber(inChannel:match("(%d+)$"))
			local channel = XF.Channels:GetByID(channelID)
			if(channel ~= nil) then
				if(XF.Config.Channels[channel:Name()] == nil) then
					XF.Config.Channels[channel:Name()] = {}
				end
				XF.Config.Channels[channel:Name()].R = inR
				XF.Config.Channels[channel:Name()].G = inG
				XF.Config.Channels[channel:Name()].B = inB
				XF:Trace(ObjectName, 'Captured new RGB [%f:%f:%f] for channel [%s]', inR, inG, inB, channel:Name())
			end
		end
	end).
	catch(function (inErrorMessage)
		XF:Error(ObjectName, inErrorMessage)
	end)
end
--#endregion