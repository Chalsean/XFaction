local XFG, G = unpack(select(2, ...))
local ObjectName = 'ChannelCollection'
local SwapChannels = C_ChatInfo.SwapChatChannelsByChannelIndex
local SetChatColor = ChangeChatColor
local GetChannels = GetChannelList

ChannelCollection = ObjectCollection:newChildConstructor()

--#region Constructors
function ChannelCollection:new()
    local object = ChannelCollection.parent.new(self)
	object.__name = ObjectName
	object.localChannel = nil
    return object
end
--#endregion

--#region Initializers
function ChannelCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		if(XFG.Cache.Channel.Password == nil) then
			JoinChannelByName(XFG.Cache.Channel.Name)
		else
			JoinChannelByName(XFG.Cache.Channel.Name, XFG.Cache.Channel.Password)
		end
		XFG:Info(ObjectName, 'Joined confederate channel [%s]', XFG.Cache.Channel.Name)
		local channelInfo = C_ChatInfo.GetChannelInfoFromIdentifier(XFG.Cache.Channel.Name)
		local channel = Channel:new()
		channel:SetKey(channelInfo.shortcut)
		channel:SetID(channelInfo.localID)
		channel:SetName(channelInfo.shortcut)
		if(XFG.Cache.Channel.Password ~= nil) then
			channel:SetPassword(XFG.Cache.Channel.Password)
		end
		self:Add(channel)
		self:SetLocalChannel(channel)
		self:SetLast(channel:GetKey())
		self:IsInitialized(true)
	end
end
--#endregion

--#region Print
function ChannelCollection:Print()
	self:ParentPrint()
	XFG:Debug(ObjectName, '  localChannel (' .. type(self.localChannel) .. ')')
	if(self.localChannel ~= nil) then
		self.localChannel:Print()
	end
end
--#endregion

--#region Accessors
function ChannelCollection:GetByID(inID)
	assert(type(inID) == 'number')
	for _, channel in self:Iterator() do
		if(channel:GetID() == inID) then
			return channel
		end
	end
end

function ChannelCollection:SetLast(inKey)
	if(not XFG.Config.Chat.Channel.Last) then return end
	if(not self:Contains(inKey)) then return end
	
	self:Scan()
	local channel = self:Get(inKey)

	for i = channel:GetID() + 1, 10 do
		local nextChannel = self:GetByID(i)
		if(nextChannel ~= nil and not nextChannel:IsCommunity()) then
			XFG:Debug(ObjectName, 'Swapping [%d:%s] and [%d:%s]', channel:GetID(), channel:GetName(), nextChannel:GetID(), nextChannel:GetName()) 
			SwapChannels(channel:GetID(), i)
			nextChannel:SetID(channel:GetID())
			channel:SetID(i)
		end
	end

	if(XFG.Config.Chat.Channel.Color) then
		for _, _Channel in self:Iterator() do
			if(XFG.Config.Channels[_Channel:GetName()] ~= nil) then
				local _Color = XFG.Config.Channels[_Channel:GetName()]
				SetChatColor('CHANNEL' .. _Channel:GetID(), _Color.R, _Color.G, _Color.B)
				XFG:Debug(ObjectName, 'Set channel [%s] RGB [%f:%f:%f]', _Channel:GetName(), _Color.R, _Color.G, _Color.B)
			end		
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
--#endregion

--#region DataSet
function ChannelCollection:Scan()
	try(function ()
		local channels = {GetChannels()}
		local IDs = {}
		for i = 1, #channels, 3 do
			local channelID, channelName, disabled = channels[i], channels[i+1], channels[i+2]
			IDs[channelID] = true
			if(self:Contains(channelName)) then
				local channel = self:Get(channelName)
				if(channel:GetID() ~= channelID) then
					local oldID = channel:GetID()
					channel:SetID(channelID)
					XFG:Debug(ObjectName, 'Channel ID changed [%d:%d:%s]', oldID, channel:GetID(), channel:GetName())
				end
			else
				local channelInfo = C_ChatInfo.GetChannelInfoFromIdentifier(channelName)
				local channel = Channel:new()
				channel:SetKey(channelName)
				channel:SetName(channelName)
				channel:SetID(channelID)
				channel:IsCommunity(channelInfo.channelType == 2)
				self:Add(channel)
			end
		end

		for _, channel in self:Iterator() do
			if(IDs[channel:GetID()] == nil) then
				self:Remove(channel:GetKey())
			end
		end
	end).
	catch(function (inErrorMessage)
		XFG:Warn(ObjectName, inErrorMessage)
	end)
end
--#endregion