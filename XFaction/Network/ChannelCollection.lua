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
	object.useGuild = true
    return object
end
--#endregion

--#region Initializers
function ChannelCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		-- If there is more than 1 guild on a target, then need to manage a custom channel
		for _, target in XFG.Targets:Iterator() do
			if(target:GetTargetCount() > 1) then
				self:UseGuild(false)
				JoinChannelByName(XFG.Cache.Channel.Name, XFG.Cache.Channel.Password)
				XFG:Info(ObjectName, 'Joined confederate channel [%s]', XFG.Cache.Channel.Name)		
				break
			end
		end
		self:IsInitialized(true)
	end
end
--#endregion

--#region Print
function ChannelCollection:Print()
	self:ParentPrint()
	XFG:Debug(ObjectName, '  useGuild (' .. type(self.useGuild) .. ')')
	XFG:Debug(ObjectName, '  localChannel (' .. type(self.localChannel) .. ')')
	if(self:HasLocalChannel()) then self:GetLocalChannel():Print() end
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
	for i = channel:GetID() + 1, XFG.Settings.Network.Channel.Total do
		local nextChannel = self:GetByID(i)
		-- Blizzard swap channel API does not work with community channels, so have to ignore them
		if(nextChannel ~= nil and not nextChannel:IsCommunity()) then
			XFG:Debug(ObjectName, 'Swapping [%d:%s] and [%d:%s]', channel:GetID(), channel:GetName(), nextChannel:GetID(), nextChannel:GetName()) 
			SwapChannels(channel:GetID(), i)
			nextChannel:SetID(channel:GetID())
			channel:SetID(i)
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
--#endregion

--#region DataSet
function ChannelCollection:Sync()
	try(function ()
		XFG.Channels:RemoveAll()
		XFG.Channels:VoidLocalChannel()
		local channels = {GetChannels()}
		for i = 1, #channels, 3 do
			local channelID, channelName, disabled = channels[i], channels[i+1], channels[i+2]
			local channelInfo = GetChannelInfo(channelName)
			local channel = Channel:new()
			channel:SetKey(channelName)
			channel:SetName(channelName)
			channel:SetID(channelID)
			channel:IsCommunity(channelInfo.channelType == Enum.PermanentChatChannelType.Communities)
			channel:SetColor()
			self:Add(channel)
			if(not self:UseGuild() and channel:GetName() == XFG.Cache.Channel.Name) then
				self:SetLocalChannel(channel)
			end
		end
	end).
	catch(function (inErrorMessage)
		XFG:Warn(ObjectName, inErrorMessage)
	end)
end
--#endregion