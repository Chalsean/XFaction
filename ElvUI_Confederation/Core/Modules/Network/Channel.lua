local CON, E, L, V, P, G = unpack(select(2, ...))
local DB = E.db.Confederation
local LogCategory = 'MChannel'
local Initialized = false
local MaxChannels = 100

local function ScanChannels()
	CON:Info(LogCategory, "Caching channel information")
	for i = 1, MaxChannels do
		local ChannelInfo = C_ChatInfo.GetChannelInfoFromIdentifier(i)
		if(ChannelInfo == nil) then
			break
		end
		CON.Network.Channel[ChannelInfo.localID] = {
			Name = ChannelInfo.name,
			ShortName = ChannelInfo.shortcut,
			ChannelID = ChannelInfo.localID,
			Community = (ChannelInfo.channelType == 2) and true or false
		}
		
		if(CON.Network.Channel[ChannelInfo.localID].Name == CON.Category) then
			CON.Network.ChannelID = CON.Network.Channel[ChannelInfo.localID].ChannelID
		end
	end
	CON:DataDumper(LogCategory, CON.Network)
end

local function IsChannelConnected(ChannelName)
	local ChannelID = GetChannelName(ChannelName)
	return (ChannelID ~= 0) and true or false
end

function CON:JoinChannel(ChannelName, Password)
	local result = JoinChannelByName(ChannelName, Password)
	if(result == 0) then
		CON:Error(LogCategory, "Failed to join channel [%s]", ChannelName)
	else
		CON:Info(LogCategory, "Joined channel [%s]", ChannelName)
	end
	return result
end

function CON:InitializeChannel()
	if(Initialized == false) then
		if(CON.Network == nil) then 
			CON.Network = {}
		end
		if(CON.Network.Channel == nil) then
			CON.Network.Channel = {}
		end
		if(IsChannelConnected(CON.Category) == false) then
			CON:JoinChannel(CON.Category)
		end
		CON.Network.Message = {
			UnitData = 'CON_DATA',
			Status = 'CON_STATUS'
		}
		ScanChannels()
		Initialized = true
	end
end