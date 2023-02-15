local XFG, G = unpack(select(2, ...))
local ObjectName = 'ChannelCollection'
local SwapChannels = C_ChatInfo.SwapChatChannelsByChannelIndex
local GetChannels = GetChannelList
local GetChannelInfo = C_ChatInfo.GetChannelInfoFromIdentifier

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
		self:Sync()
		self:SetLast(XFG.Cache.Channel.Name)
		self:SetLocalChannel(self:Get(XFG.Cache.Channel.Name))
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

	self:Sync()
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
function ChannelCollection:Sync()
	try(function ()
		XFG.Channels:RemoveAll()
		local channels = {GetChannels()}
		local IDs = {}
		for i = 1, #channels, 3 do
			local channelID, channelName, disabled = channels[i], channels[i+1], channels[i+2]
			IDs[channelID] = true
			local channelInfo = GetChannelInfo(channelName)
			local channel = Channel:new()
			channel:SetKey(channelName)
			channel:SetName(channelName)
			channel:SetID(channelID)
			channel:IsCommunity(channelInfo.channelType == 2)
			channel:SetColor()
			self:Add(channel)			
		end
	end).
	catch(function (inErrorMessage)
		XFG:Warn(ObjectName, inErrorMessage)
	end)
end
--#endregion