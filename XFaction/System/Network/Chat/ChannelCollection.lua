local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'ChannelCollection'

XFC.ChannelCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.ChannelCollection:new()
    local object = XFC.ChannelCollection.parent.new(self)
	object.__name = ObjectName
	object.localName = nil
	object.localPassword = nil
    return object
end

function XFC.ChannelCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()

		local channel = XFC.Channel:new()
        channel:Initialize()
        channel:Key('GUILD')
        channel:Name('GUILD')
		self:Add(channel)

		self.localName = XF.Cache.Channel.Name
		self.localPassword = XF.Cache.Channel.Password

		XFO.Events:Add({
			name = 'ChannelLeft', 
			event = 'CHAT_MSG_CHANNEL_LEAVE', 
			callback = XFO.Channels.CallbackUnitLeftChannel, 
			instance = true,
			restricted = true
		})

		self:IsInitialized(true)
	end
end
--#endregion

--#region Methods
function XFC.ChannelCollection:CallbackUnitLeftChannel(_, name, _, _, _, _, _, _, channelName, _, _, guid)
	local self = XFO.Channels
	try(function()
		if(self:LocalChannel():Key() == channelName) then
			XF:Debug(self:ObjectName(), 'Detected channel logout: %s', name)
			XFO.Confederate:Logout(guid)
			XFO.ChatWindow:DisplayLogout(guid)
		end
	end).
	catch(function(err)
		XF:Warn(self:ObjectName(), err)
	end)
end

function XFC.ChannelCollection:CallbackLoginChannel()
	local self = XFO.Channels
	try(function()
		JoinTemporaryChannel(self.localName, self.localPassword)
        XF:Info(self:ObjectName(), 'Joined confederate channel [%s]', self.localName)

		local channels = {XFF.ChatChannels()}
		for i = 1, #channels, 3 do
			local channelID, channelName, disabled = channels[i], channels[i+1], channels[i+2]
			if (channelName == self.localName) then
				local channel = XFC.Channel:new()
				channel:Initialize()
				channel:Key('CHANNEL')
				channel:Name(channelName)
				channel:ID(channelID)
				self:Add(channel)
				break
			end
		end
	end).
	catch(function(err)
		XF:Warn(self:ObjectName(), err)
	end)
end
--#endregion