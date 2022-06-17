local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

local function SwapChannels(inSourceNode, inTargetKey)
	local _SourceIndex = string.sub(inSourceNode, 8, 10)
	for _ChannelIndex, _ChannelKey in pairs (XFG.Config.Channel.Channels) do
		if(_ChannelKey == inTargetKey) then
			XFG.Config.Channel.Channels[_ChannelIndex] = XFG.Config.Channel.Channels[inSourceNode]
			local _Index = string.sub(_ChannelIndex, 8, 10)
			local _SwapChannel1 = XFG.Network.Channels:GetChannelByID(tonumber(_Index))
			local _SwapChannel2 = XFG.Network.Channels:GetChannelByID(tonumber(_SourceIndex))
			C_ChatInfo.SwapChatChannelsByChannelIndex(_SwapChannel1:GetID(), _SwapChannel2:GetID())
			_SwapChannel1:SetID(tonumber(_SourceIndex))
			_SwapChannel2:SetID(tonumber(_Index))
		end
	end
	XFG.Config.Channel.Channels[inSourceNode] = inTargetKey
end

XFG.Options.args.Channel = {
	name = XFG.Lib.Locale['CHANNEL'],
	order = 1,
	type = 'group',
	args = {
		Enable = {
			order = 1,
			type = 'toggle',
			name = XFG.Lib.Locale['ENABLE'],
			desc = XFG.Lib.Locale['CHANNEL_ENABLE_TOOLTIP'],
			get = function(info) return XFG.Config.Channel[ info[#info] ] end,
			set = function(info, value) 
				XFG.Config.Channel[ info[#info] ] = value; 
				if(value) then XFG.Network.Channels:SyncChannels() end
			end
		},
		Channels = {
			order = 2,
			type = 'group',
			name = '',
			guiInline = true,
			args = {
				Channel1 = {
					order = 1,
					type = 'select',
					name = XFG.Lib.Locale['CHANNEL1'],
					desc = '',
					disabled = function(info) 
						local _ChannelNumber = string.sub(info[#info], 8, 10)
						return XFG.Config.Channel.Enable == false or tonumber(_ChannelNumber) > XFG.Network.Channels:GetCount()
					end,
					values = {},
					get = function(info) return XFG.Config.Channel.Channels[info[#info]] end,
					set = function(info, value) SwapChannels(info[#info], value); end,
				},
				Channel2 = {
					order = 2,
					type = 'select',
					name = XFG.Lib.Locale['CHANNEL2'],
					desc = '',
					disabled = function(info) 
						local _ChannelNumber = string.sub(info[#info], 8, 10)
						return XFG.Config.Channel.Enable == false or tonumber(_ChannelNumber) > XFG.Network.Channels:GetCount()
					end,
					values = {},
					get = function(info) return XFG.Config.Channel.Channels[info[#info]] end,
					set = function(info, value) SwapChannels(info[#info], value); end,
				},
				Channel3 = {
					order = 3,
					type = 'select',
					name = XFG.Lib.Locale['CHANNEL3'],
					desc = '',
					disabled = function(info) 
						local _ChannelNumber = string.sub(info[#info], 8, 10)
						return XFG.Config.Channel.Enable == false or tonumber(_ChannelNumber) > XFG.Network.Channels:GetCount()
					end,
					values = {},
					get = function(info) return XFG.Config.Channel.Channels[info[#info]] end,
					set = function(info, value) SwapChannels(info[#info], value); end,
				},
				Channel4 = {
					order = 4,
					type = 'select',
					name = XFG.Lib.Locale['CHANNEL4'],
					desc = '',
					disabled = function(info) 
						local _ChannelNumber = string.sub(info[#info], 8, 10)
						return XFG.Config.Channel.Enable == false or tonumber(_ChannelNumber) > XFG.Network.Channels:GetCount()
					end,
					values = {},
					get = function(info) return XFG.Config.Channel.Channels[info[#info]] end,
					set = function(info, value) SwapChannels(info[#info], value); end,
				},
				Channel5 = {
					order = 5,
					type = 'select',
					name = XFG.Lib.Locale['CHANNEL5'],
					desc = '',
					disabled = function(info) 
						local _ChannelNumber = string.sub(info[#info], 8, 10)
						return XFG.Config.Channel.Enable == false or tonumber(_ChannelNumber) > XFG.Network.Channels:GetCount()
					end,
					values = {},
					get = function(info) return XFG.Config.Channel.Channels[info[#info]] end,
					set = function(info, value) SwapChannels(info[#info], value); end,
				},
				Channel6 = {
					order = 6,
					type = 'select',
					name = XFG.Lib.Locale['CHANNEL6'],
					desc = '',
					disabled = function(info) 
						local _ChannelNumber = string.sub(info[#info], 8, 10)
						return XFG.Config.Channel.Enable == false or tonumber(_ChannelNumber) > XFG.Network.Channels:GetCount()
					end,
					values = {},
					get = function(info) return XFG.Config.Channel.Channels[info[#info]] end,
					set = function(info, value) SwapChannels(info[#info], value); end,
				},
				Channel7 = {
					order = 7,
					type = 'select',
					name = XFG.Lib.Locale['CHANNEL7'],
					desc = '',
					disabled = function(info) 
						local _ChannelNumber = string.sub(info[#info], 8, 10)
						return XFG.Config.Channel.Enable == false or tonumber(_ChannelNumber) > XFG.Network.Channels:GetCount()
					end,
					values = {},
					get = function(info) return XFG.Config.Channel.Channels[info[#info]] end,
					set = function(info, value) SwapChannels(info[#info], value); end,
				},
				Channel8 = {
					order = 8,
					type = 'select',
					name = XFG.Lib.Locale['CHANNEL8'],
					desc = '',
					disabled = function(info) 
						local _ChannelNumber = string.sub(info[#info], 8, 10)
						return XFG.Config.Channel.Enable == false or tonumber(_ChannelNumber) > XFG.Network.Channels:GetCount()
					end,
					values = {},
					get = function(info) return XFG.Config.Channel.Channels[info[#info]] end,
					set = function(info, value) SwapChannels(info[#info], value); end,
				},
				Channel9 = {
					order = 9,
					type = 'select',
					name = XFG.Lib.Locale['CHANNEL9'],
					desc = '',
					disabled = function(info) 
						local _ChannelNumber = string.sub(info[#info], 8, 10)
						return XFG.Config.Channel.Enable == false or tonumber(_ChannelNumber) > XFG.Network.Channels:GetCount()
					end,
					values = {},
					get = function(info) return XFG.Config.Channel.Channels[info[#info]] end,
					set = function(info, value) SwapChannels(info[#info], value); end,
				},
				Channel10 = {
					order = 10,
					type = 'select',
					name = XFG.Lib.Locale['CHANNEL10'],
					desc = '',
					disabled = function(info) 
						local _ChannelNumber = string.sub(info[#info], 8, 10)
						return XFG.Config.Channel.Enable == false or tonumber(_ChannelNumber) > XFG.Network.Channels:GetCount()
					end,
					values = {},
					get = function(info) return XFG.Config.Channel.Channels[info[#info]] end,
					set = function(info, value) SwapChannels(info[#info], value); end,
				},
			}
		},
	}
}