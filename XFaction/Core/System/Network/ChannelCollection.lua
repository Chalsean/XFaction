local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'ChannelCollection'

XFC.ChannelCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.ChannelCollection:new()
    local object = XFC.ChannelCollection.parent.new(self)
	object.__name = ObjectName
	object.localChannel = nil
	object.useGuild = false
    return object
end
--#endregion

--#region Initializers
function XFC.ChannelCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		-- Remove this block after everyone on 4.4, its for backwards compat while guild members are a mix of 4.4 and pre-4.4
		if(XF.Cache.Channel.Name ~= nil and XF.Cache.Channel.Password ~= nil) then
			try(function ()
				XFF.ChatJoinChannel(XF.Cache.Channel.Name, XF.Cache.Channel.Password)
				XF:Info(self:GetObjectName(), 'Joined confederate channel [%s]', XF.Cache.Channel.Name)
			end).
			catch(function (inErrorMessage)
				XF:Error(self:GetObjectName(), inErrorMessage)
			end)
		end

		if(XF.Player.Target:GetTargetCount() > 1) then
			self:UseGuild(false)
			--JoinChannelByName(XF.Cache.Channel.Name, XF.Cache.Channel.Password)
			--XF:Info(ObjectName, 'Joined confederate channel [%s]', XF.Cache.Channel.Name)
		end

		XFO.Events:Add({
			name = 'ChannelChange', 
			event = 'CHAT_MSG_CHANNEL_NOTICE', 
			callback = XFO.Channels.Sync,
			groupDelta = 3,
			instance = true,
			start = true
		})
		XFO.Events:Add({
			name = 'ChannelColor', 
			event = 'UPDATE_CHAT_COLOR', 
			callback = XFO.Channels.UpdateColor, 
			instance = true,
			start = true
		})
		XFO.Timers:Add({
			name = 'LoginChannelSync',
			delta = XF.Settings.Network.Channel.LoginChannelSyncTimer, 
			callback = XFO.Channels.Sync,
			repeater = true,
			maxAttempts = XF.Settings.Network.Channel.LoginChannelSyncAttempts,
			instance = true
		})

		self:IsInitialized(true)
	end
end
--#endregion

--#region Print
function XFC.ChannelCollection:Print()
	self:ParentPrint()
	XF:Debug(self:GetObjectName(), '  useGuild (' .. type(self.useGuild) .. '): ' .. tostring(self.useGuild))
	XF:Debug(self:GetObjectName(), '  localChannel (' .. type(self.localChannel) .. ')')
	if(self:HasLocalChannel()) then self:GetLocalChannel():Print() end
end
--#endregion

--#region Accessors
function XFC.ChannelCollection:GetByID(inID)
	assert(type(inID) == 'number')
	for _, channel in self:Iterator() do
		if(channel:GetID() == inID) then
			return channel
		end
	end
end

function XFC.ChannelCollection:SetLast(inKey)
	if(not XF.Config.Chat.Channel.Last) then return end
	if(not self:Contains(inKey)) then return end
	
	local channel = self:Get(inKey)
	for i = channel:GetID() + 1, XF.Settings.Network.Channel.Total do
		local nextChannel = self:GetByID(i)
		-- Blizzard swap channel API does not work with community channels, so have to ignore them
		if(nextChannel ~= nil and not nextChannel:IsCommunity()) then
			XF:Debug(self:GetObjectName(), 'Swapping [%d:%s] and [%d:%s]', channel:GetID(), channel:GetName(), nextChannel:GetID(), nextChannel:GetName()) 
			XFF.ChatSwapChannels(channel:GetID(), i)
			nextChannel:SetID(channel:GetID())
			channel:SetID(i)
		end
	end
end

function XFC.ChannelCollection:HasLocalChannel()
    return self.localChannel ~= nil
end

function XFC.ChannelCollection:GetLocalChannel()
    return self.localChannel
end

function XFC.ChannelCollection:SetLocalChannel(inChannel)
    assert(type(inChannel) == 'table' and inChannel.__name == 'Channel', 'argument must be Channel object')
    self.localChannel = inChannel
end

function XFC.ChannelCollection:VoidLocalChannel()
    self.localChannel = nil
end

function XFC.ChannelCollection:UseGuild(inBoolean)
	assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
	if(inBoolean ~= nil) then
		self.useGuild = inBoolean
	end
	return self.useGuild
end
--#endregion

--#region Callbacks
function XFC.ChannelCollection:Sync()
	local self = XFO.Channels
	try(function ()
		self:RemoveAll()
		self:VoidLocalChannel()
		local channels = {XFF.ChatGetChannels()}
		for i = 1, #channels, 3 do
			local channelID, channelName, disabled = channels[i], channels[i+1], channels[i+2]
			local channelInfo = XFF.ChatGetChannelInfo(channelName)
			local channel = XFC.Channel:new()
			channel:SetKey(channelName)
			channel:SetName(channelName)
			channel:SetID(channelID)
			channel:IsCommunity(channelInfo.channelType == Enum.PermanentChatChannelType.Communities)
			channel:SetColor()
			self:Add(channel)
			if(channel:GetName() == XF.Cache.Channel.Name) then
				self:SetLocalChannel(channel)
			end
		end

		-- FIX: Channel sorting
		--if(XF.Config.Chat.Channel.Last)
	end).
	catch(function (inErrorMessage)
		XF:Warn(self:GetObjectName(), inErrorMessage)
	end)
end

function XFC.ChannelCollection:UpdateColor(inChannel, inR, inG, inB)
	local self = XFO.Channels
	try(function ()
		if(inChannel) then
			local channelID = tonumber(inChannel:match("(%d+)$"))
			local channel = self:GetByID(channelID)
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