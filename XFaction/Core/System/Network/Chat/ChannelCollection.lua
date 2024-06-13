local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'ChannelCollection'
local SwapChannels = C_ChatInfo.SwapChatChannelsByChannelIndex
local GetChannels = GetChannelList
local GetChannelInfo = C_ChatInfo.GetChannelInfoFromIdentifier

ChannelCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function ChannelCollection:new()
    local object = ChannelCollection.parent.new(self)
	object.__name = ObjectName
	object.localChannel = nil
	object.useGuild = false
    return object
end
--#endregion

--#region Initializers
function ChannelCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		-- Remove this block after everyone on 4.4, its for backwards compat while guild members are a mix of 4.4 and pre-4.4
		if(XF.Cache.Channel.Name ~= nil and XF.Cache.Channel.Password ~= nil) then
			try(function ()
				JoinChannelByName(XF.Cache.Channel.Name, XF.Cache.Channel.Password)
				XF:Info(ObjectName, 'Joined confederate channel [%s]', XF.Cache.Channel.Name)
			end).
			catch(function (inErrorMessage)
				XF:Error(ObjectName, inErrorMessage)
			end)
		end

		if(XF.Player.Target:GetTarCount() > 1) then
			self:UseGuild(false)
			--JoinChannelByName(XF.Cache.Channel.Name, XF.Cache.Channel.Password)
			--XF:Info(ObjectName, 'Joined confederate channel [%s]', XF.Cache.Channel.Name)
		end

		XF.Events:Add({name = 'ChannelLeft', 
                        event = 'CHAT_MSG_CHANNEL_LEAVE', 
                        callback = XF.Channels.UnitLeftChannel, 
                        instance = true})
		self:IsInitialized(true)
	end
end
--#endregion

--#region Print
function ChannelCollection:Print()
	self:ParentPrint()
	XF:Debug(ObjectName, '  useGuild (' .. type(self.useGuild) .. '): ' .. tostring(self.useGuild))
	XF:Debug(ObjectName, '  localChannel (' .. type(self.localChannel) .. ')')
	if(self:HasLocalChannel()) then self:GetLocalChannel():Print() end
end
--#endregion

--#region Accessors
function ChannelCollection:GetByID(inID)
	assert(type(inID) == 'number')
	for _, channel in self:Iterator() do
		if(channel:ID() == inID) then
			return channel
		end
	end
end

function ChannelCollection:SetLast(inKey)
	if(not XF.Config.Chat.Channel.Last) then return end
	if(not self:Contains(inKey)) then return end
	
	local channel = self:Get(inKey)
	for i = channel:ID() + 1, XF.Settings.Network.Channel.Total do
		local nextChannel = self:GetByID(i)
		-- Blizzard swap channel API does not work with community channels, so have to ignore them
		if(nextChannel ~= nil and not nextChannel:IsCommunity()) then
			XF:Debug(ObjectName, 'Swapping [%d:%s] and [%d:%s]', channel:ID(), channel:Name(), nextChannel:ID(), nextChannel:Name()) 
			SwapChannels(channel:ID(), i)
			nextChannel:ID(channel:ID())
			channel:ID(i)
		end
	end
end

function ChannelCollection:HasLocalChannel()
    return self.localChannel ~= nil
end

function ChannelCollection:GetLocalChannel()
    return self.localChannel
end

function ChannelCollection:SetLocalChannel(inChannel)
    assert(type(inChannel) == 'table' and inChannel.__name == 'Channel', 'argument must be Channel object')
    self.localChannel = inChannel
end

function ChannelCollection:VoidLocalChannel()
    self.localChannel = nil
end

function ChannelCollection:UseGuild(inBoolean)
	assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
	if(inBoolean ~= nil) then
		self.useGuild = inBoolean
	end
	return self.useGuild
end

function ChannelCollection:UnitLeftChannel(_, _, _, _, _, _, _, _, channelName, _, _, guid)
	local self = XF.Channels
	if(self:HasLocalChannel()) then
		local channel = self:GetLocalChannel()
		if(channel:Key() == channelName and XF.Confederate:Contains(guid)) then
			local unit = XF.Confederate:Get(guid)
			if(unit:IsOnline() and not XF.Player.Guild:Equals(unit:GetGuild())) then
				XF:Info(ObjectName, 'Guild member logout via event: ' .. unit:GetUnitName())
				XF.Frames.System:Display(XF.Enum.Message.LOGOUT, unit:Name(), unit:GetUnitName(), unit:GetMainName(), unit:GetGuild(), nil, unit:GetFaction())
				XF.Confederate:Remove(unit:Key())
				XF.Confederate:Push(unit)
				XF.DataText.Guild:RefreshBroker()
			end
		end
	end	
end
--#endregion

--#region DataSet
function ChannelCollection:Sync()
	try(function ()
		XF.Channels:RemoveAll()
		XF.Channels:VoidLocalChannel()
		local channels = {GetChannels()}
		for i = 1, #channels, 3 do
			local channelID, channelName, disabled = channels[i], channels[i+1], channels[i+2]
			local channelInfo = GetChannelInfo(channelName)
			local channel = Channel:new()
			channel:Key(channelName)
			channel:Name(channelName)
			channel:ID(channelID)
			channel:IsCommunity(channelInfo.channelType == Enum.PermanentChatChannelType.Communities)
			channel:SetColor()
			self:Add(channel)
			if(channel:Name() == XF.Cache.Channel.Name) then
				self:SetLocalChannel(channel)
			end
		end
	end).
	catch(function (inErrorMessage)
		XF:Warn(ObjectName, inErrorMessage)
	end)
end
--#endregion