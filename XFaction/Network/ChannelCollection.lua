local XFG, G = unpack(select(2, ...))
local ObjectName = 'ChannelCollection'

local SwapChannels = C_ChatInfo.SwapChatChannelsByChannelIndex
local SetChatColor = ChangeChatColor
local GetChannels = GetChannelList

ChannelCollection = ObjectCollection:newChildConstructor()

function ChannelCollection:new()
    local _Object = ChannelCollection.parent.new(self)
	_Object.__name = ObjectName
	_Object._LocalChannel = nil
    return _Object
end

function ChannelCollection:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  _LocalChannel (' .. type(self._LocalChannel) .. ')')
        if(self._LocalChannel ~= nil) then
            self._LocalChannel:Print()
        end
    end
end

function ChannelCollection:GetByID(inID)
	assert(type(inID) == 'number')
	for _, _Channel in self:Iterator() do
		if(_Channel:GetID() == inID) then
			return _Channel
		end
	end
end

function ChannelCollection:SetLast(inKey)
	if(not XFG.Config.Chat.Channel.Last) then return end
	if(not self:Contains(inKey)) then return end
	
	self:Scan()
	local _Channel = self:Get(inKey)

	for i = _Channel:GetID() + 1, 10 do
		local _NextChannel = self:GetByID(i)
		if(_NextChannel ~= nil and not _NextChannel:IsCommunity()) then
			if(XFG.DebugFlag) then 
				XFG:Debug(ObjectName, 'Swapping [%d:%s] and [%d:%s]', _Channel:GetID(), _Channel:GetName(), _NextChannel:GetID(), _NextChannel:GetName()) 
			end
			SwapChannels(_Channel:GetID(), i)
			_NextChannel:SetID(_Channel:GetID())
			_Channel:SetID(i)
		end
	end

	if(XFG.Config.Chat.Channel.Color) then
		for _, _Channel in self:Iterator() do
			if(XFG.Config.Channels[_Channel:GetName()] ~= nil) then
				local _Color = XFG.Config.Channels[_Channel:GetName()]
				SetChatColor('CHANNEL' .. _Channel:GetID(), _Color.R, _Color.G, _Color.B)
				if(XFG.DebugFlag) then
					XFG:Debug(ObjectName, 'Set channel [%s] RGB [%f:%f:%f]', _Channel:GetName(), _Color.R, _Color.G, _Color.B)
				end
			end		
		end
	end
end

function ChannelCollection:Scan()
	try(function ()
		local _Channels = {GetChannels()}
		local _IDs = {}
		for i = 1, #_Channels, 3 do
			local _ChannelID, _ChannelName, _Disabled = _Channels[i], _Channels[i+1], _Channels[i+2]
			_IDs[_ChannelID] = true
			if(self:Contains(_ChannelName)) then
				local _Channel = self:Get(_ChannelName)
				if(_Channel:GetID() ~= _ChannelID) then
					local _OldID = _Channel:GetID()
					_Channel:SetID(_ChannelID)
					if(XFG.DebugFlag) then
						XFG:Debug(ObjectName, 'Channel ID changed [%d:%d:%s]', _OldID, _Channel:GetID(), _Channel:GetName())
					end
				end
			else
				local _ChannelInfo = C_ChatInfo.GetChannelInfoFromIdentifier(_ChannelName)
				local _NewChannel = Channel:new()
				_NewChannel:SetKey(_ChannelName)
				_NewChannel:SetName(_ChannelName)
				_NewChannel:SetID(_ChannelID)
				_NewChannel:IsCommunity(_ChannelInfo.channelType == 2)
				self:Add(_NewChannel)
			end
		end

		for _, _Channel in self:Iterator() do
			if(_IDs[_Channel:GetID()] == nil) then
				self:Remove(_Channel:GetKey())
			end
		end
	end).
	catch(function (inErrorMessage)
		XFG:Warn(ObjectName, inErrorMessage)
	end)
end

function ChannelCollection:HasLocalChannel()
    return self._LocalChannel ~= nil
end

function ChannelCollection:GetLocalChannel()
    return self._LocalChannel
end

function ChannelCollection:SetLocalChannel(inChannel)
    assert(type(inChannel) == 'table' and inChannel.__name ~= nil and inChannel.__name == 'Channel', "argument must be Channel object")
    self._LocalChannel = inChannel
end

function ChannelCollection:VoidLocalChannel()
    self._LocalChannel = nil
end