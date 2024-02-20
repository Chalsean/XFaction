local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'ChannelCollection'
local SwapChannels = C_ChatInfo.SwapChatChannelsByChannelIndex
local GetChannels = GetChannelList
local GetChannelInfo = C_ChatInfo.GetChannelInfoFromIdentifier

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
				JoinChannelByName(XF.Cache.Channel.Name, XF.Cache.Channel.Password)
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

		XFO.Timers:Add
		({
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
			SwapChannels(channel:GetID(), i)
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

--#region DataSet
function XFC.ChannelCollection:Sync()
	local self = XFO.Channels
	try(function ()
		self:RemoveAll()
		self:VoidLocalChannel()
		local channels = {GetChannels()}
		for i = 1, #channels, 3 do
			local channelID, channelName, disabled = channels[i], channels[i+1], channels[i+2]
			local channelInfo = GetChannelInfo(channelName)
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
	end).
	catch(function (inErrorMessage)
		XF:Warn(self:GetObjectName(), inErrorMessage)
	end)
end
--#endregion