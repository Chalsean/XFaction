local XFG, G = unpack(select(2, ...))
local ObjectName = 'Encode'
local Deflate = XFG.Lib.Deflate

-- BNet seems to have a cap of around 300 characters and there is no BNet support from AceComm/ChatThrottle
-- So have to strip down to bare essentials, like send race id instead of race name and reconstruct as much as we can on receiving end
-- I'm sure there's a cooler way of doing this :)
local function SerializeMessage(inMessage, inEncodeUnitData)
	local messageData = {}

	messageData.M = inMessage:GetMainName()
	messageData.N = inMessage:GetName()
	messageData.U = inMessage:GetUnitName()
	if(inMessage:HasGuild()) then
		messageData.G = inMessage:GetGuild():GetName()
	end
	if(inMessage:HasRealm()) then
		messageData.R = inMessage:GetRealm():GetID()
	end

	if(inMessage:HasUnitData() and inEncodeUnitData) then
		messageData.D = XFG:SerializeUnitData(inMessage:GetData())
	else
		messageData.D = inMessage:GetData()
	end

	messageData.K = inMessage:GetKey()
	messageData.T = inMessage:GetTo()
	messageData.F = inMessage:GetFrom()	
	messageData.S = inMessage:GetSubject()
	messageData.Y = inMessage:GetType()
	messageData.I = inMessage:GetTimeStamp()
	messageData.A = inMessage:GetRemainingTargets()
	messageData.P = inMessage:GetPacketNumber()
	messageData.Q = inMessage:GetTotalPackets()
	messageData.V = inMessage:GetVersion():GetKey()

	return pickle(messageData)
end

function XFG:SerializeUnitData(inUnitData)
	local messageData = {}

	messageData.A = inUnitData:GetRace():GetKey()
	messageData.B = inUnitData:GetAchievementPoints()
	messageData.C = inUnitData:GetID()
	messageData.E = inUnitData:GetPresence()
	messageData.F = inUnitData:GetFaction():GetKey()
	messageData.G = inUnitData:GetGuild():GetName()
	messageData.R = inUnitData:GetRealm():GetID()
	messageData.K = inUnitData:GetGUID()
	messageData.I = inUnitData:GetItemLevel()
	messageData.J = inUnitData:GetRank()
	messageData.L = inUnitData:GetLevel()
	messageData.N = inUnitData:GetNote()
	messageData.O = inUnitData:GetClass():GetKey()
	if(inUnitData:HasProfession1()) then
		messageData.P1 = inUnitData:GetProfession1():GetKey()
	end
	if(inUnitData:HasProfession2()) then
		messageData.P2 = inUnitData:GetProfession2():GetKey()
	end
	messageData.U = inUnitData:GetUnitName()	
	if(inUnitData:HasSpec()) then
		messageData.V = inUnitData:GetSpec():GetKey()
	end
	messageData.X = inUnitData:GetVersion():GetKey()
	messageData.Y = inUnitData:GetPvP()

	if(inUnitData:GetZone():HasID()) then
		messageData.D = inUnitData:GetZone():GetID()
	else
		messageData.Z = inUnitData:GetZone():GetName()
	end

	return pickle(messageData)
end

function XFG:EncodeChatMessage(inMessage, inEncodeUnitData)
	assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), 'argument must be a Message type object')
	local serialized = SerializeMessage(inMessage, inEncodeUnitData)
	local compressed = Deflate:CompressDeflate(serialized, {level = XFG.Settings.Network.CompressionLevel})
	return Deflate:EncodeForWoWAddonChannel(compressed)
end

-- Have not been able to identify why, but bnet does not like the output of deflate
function XFG:EncodeBNetMessage(inMessage)
	assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), 'argument must be a Message type object')
	local serialized = SerializeMessage(inMessage, true)
	local compressed = Deflate:CompressDeflate(serialized, {level = XFG.Settings.Network.CompressionLevel})
	return Deflate:EncodeForPrint(compressed)
end