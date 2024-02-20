local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'ChannelEvent'

XFC.ChannelEvent = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.ChannelEvent:new()
	local object = XFC.ChannelEvent.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function XFC.ChannelEvent:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		XFO.Events:Add({name = 'ChannelChange', 
		                event = 'CHAT_MSG_CHANNEL_NOTICE', 
						callback = XFO.Channels.Sync,
						groupDelta = 3,
						instance = true,
						start = true})
		XFO.Events:Add({name = 'ChannelColor', 
		                event = 'UPDATE_CHAT_COLOR', 
						callback = XFO.ChannelEvent.CallbackUpdateColor, 
						instance = true,
					    start = true})
		self:IsInitialized(true)
	end
end
--#endregion

--#region Callbacks
function XFC.ChannelEvent:CallbackUpdateColor(inChannel, inR, inG, inB)
	try(function ()
		if(inChannel) then
			local channelID = tonumber(inChannel:match("(%d+)$"))
			local channel = XFO.Channels:GetByID(channelID)
			if(channel ~= nil) then
				if(XF.Config.Channels[channel:GetName()] == nil) then
					XF.Config.Channels[channel:GetName()] = {}
				end
				XF.Config.Channels[channel:GetName()].R = inR
				XF.Config.Channels[channel:GetName()].G = inG
				XF.Config.Channels[channel:GetName()].B = inB
				XF:Trace(self:GetObjectName(), 'Captured new RGB [%f:%f:%f] for channel [%s]', inR, inG, inB, channel:GetName())
			end
		end
	end).
	catch(function (err)
		XF:Error(self:GetObjectName(), err)
	end)
end
--#endregion