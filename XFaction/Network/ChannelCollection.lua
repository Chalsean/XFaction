local XFG, G = unpack(select(2, ...))

ChannelCollection = ObjectCollection:newChildConstructor()

function ChannelCollection:new()
    local _Object = ChannelCollection.parent.new(self)
	_Object.__name = 'ChannelCollection'
    return _Object
end

function ChannelCollection:GetChannelByID(inID)
	assert(type(inID) == 'number')
	for _, _Channel in self:Iterator() do
		if(_Channel:GetID() == inID) then
			return _Channel
		end
	end
end

function ChannelCollection:SetChannelLast(inKey)
	if(not XFG.Config.Chat.Channel.Last) then return end
	if(not self:Contains(inKey)) then return end
	
	self:ScanChannels()
	local _Channel = self:GetObject(inKey)

	for i = _Channel:GetID() + 1, 10 do
		local _NextChannel = self:GetChannelByID(i)
		if(_NextChannel ~= nil) then
			XFG:Debug(self:GetObjectName(), 'Swapping [%d:%s] and [%d:%s]', _Channel:GetID(), _Channel:GetName(), _NextChannel:GetID(), _NextChannel:GetName())
			C_ChatInfo.SwapChatChannelsByChannelIndex(_Channel:GetID(), i)
			_NextChannel:SetID(_Channel:GetID())
			_Channel:SetID(i)
		end
	end

	if(XFG.Config.Chat.Channel.Color) then
		for _, _Channel in self:Iterator() do
			if(XFG.Config.Channels[_Channel:GetName()] ~= nil) then
				local _Color = XFG.Config.Channels[_Channel:GetName()]
				ChangeChatColor('CHANNEL' .. _Channel:GetID(), _Color.R, _Color.G, _Color.B)
				XFG:Debug(self:GetObjectName(), 'Set channel [%s] RGB [%f:%f:%f]', _Channel:GetName(), _Color.R, _Color.G, _Color.B)
			end		
		end
	end
end

function ChannelCollection:ScanChannels()
	try(function ()
		local _Channels = {GetChannelList()}
		local _IDs = {}
		for i = 1, #_Channels, 3 do
			local _ChannelID, _ChannelName, _Disabled = _Channels[i], _Channels[i+1], _Channels[i+2]
			_IDs[_ChannelID] = true
			if(self:Contains(_ChannelName)) then
				local _Channel = self:GetObject(_ChannelName)
				if(_Channel:GetID() ~= _ChannelID) then
					local _OldID = _Channel:GetID()
					_Channel:SetID(_ChannelID)
					XFG:Debug(self:GetObjectName(), 'Channel ID changed [%d:%d:%s]', _OldID, _Channel:GetID(), _Channel:GetName())
				end
			else
				local _NewChannel = Channel:new()
				_NewChannel:SetKey(_ChannelName)
				_NewChannel:SetName(_ChannelName)
				_NewChannel:SetID(_ChannelID)
				self:AddObject(_NewChannel)
			end
		end

		for _, _Channel in self:Iterator() do
			if(_IDs[_Channel:GetID()] == nil) then
				self:RemoveObject(_Channel)
			end
		end
	end).
	catch(function (inErrorMessage)
		XFG:Warn(self:GetObjectName(), 'Failed to scan channels: ' .. inErrorMessage)
	end)
end