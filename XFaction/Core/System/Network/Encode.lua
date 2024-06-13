local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Encode'
local Deflate = XF.Lib.Deflate

-- BNet seems to have a cap of around 300 characters and there is no BNet support from AceComm/ChatThrottle
-- So have to strip down to bare essentials, like send race id instead of race name and reconstruct as much as we can on receiving end
-- I'm sure there's a cooler way of doing this :)
local function SerializeMessage(inMessage, inEncodeUnitData)
	local messageData = {}

	messageData.M = inMessage:GetMainName()
	messageData.N = inMessage:Name()
	messageData.U = inMessage:GetUnitName()
	if(inMessage:HasGuild()) then
		messageData.H = inMessage:GetGuild():Key()
		-- Remove G/R once everyone is on 4.4 build
		messageData.G = inMessage:GetGuild():Name()
		messageData.R = inMessage:GetGuild():GetRealm():ID()
	end

	if(inMessage:HasUnitData() and inEncodeUnitData) then
		messageData.D = XF:SerializeUnitData(inMessage:GetData())
	else
		messageData.D = inMessage:GetData()
	end

	messageData.K = inMessage:Key()
	messageData.T = inMessage:GetTo()
	messageData.F = inMessage:GetFrom()	
	messageData.S = inMessage:GetSubject()
	messageData.Y = inMessage:GetType()
	messageData.I = inMessage:GetTimeStamp()
	messageData.A = inMessage:GetRemainingTargets()
	messageData.P = inMessage:GetPacketNumber()
	messageData.Q = inMessage:GetTotalPackets()
	messageData.V = inMessage:GetVersion():Key()
	messageData.W = inMessage:GetFaction():Key()

	return pickle(messageData)
end

function XF:SerializeUnitData(inUnitData)
	local messageData = {}

	messageData.A = inUnitData:GetRace():Key()
	messageData.B = inUnitData:GetAchievementPoints()
	messageData.C = inUnitData:ID()
	messageData.E = inUnitData:GetPresence()
	messageData.F = inUnitData:GetFaction():Key()	
	messageData.H = inUnitData:GetGuild():Key()
	-- Remove G/R after everyone on 4.4
	messageData.G = inUnitData:GetGuild():Name()
	messageData.R = inUnitData:GetGuild():GetRealm():ID()
	messageData.K = inUnitData:GetGUID()
	messageData.I = inUnitData:GetItemLevel()
	messageData.J = inUnitData:GetRank()
	messageData.L = inUnitData:GetLevel()
	messageData.M = inUnitData:HasMythicKey() and inUnitData:GetMythicKey():Serialize() or nil
	messageData.N = inUnitData:GetNote()
	messageData.O = inUnitData:GetClass():Key()
	messageData.P1 = inUnitData:HasProfession1() and inUnitData:GetProfession1():Key() or nil
	messageData.P2 = inUnitData:HasProfession2() and inUnitData:GetProfession2():Key() or nil
	messageData.U = inUnitData:GetUnitName()
	messageData.V = inUnitData:HasSpec() and inUnitData:GetSpec():Key() or nil
	messageData.X = inUnitData:GetVersion():Key()
	messageData.Y = inUnitData:GetPvP()

	if(inUnitData:GetZone():HasID()) then
		messageData.D = inUnitData:GetZone():ID()
	else
		messageData.Z = inUnitData:GetZone():Name()
	end

	return pickle(messageData)
end

function XF:EncodeChatMessage(inMessage, inEncodeUnitData)
	assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), 'argument must be a Message type object')
	local serialized = SerializeMessage(inMessage, inEncodeUnitData)
	local compressed = Deflate:CompressDeflate(serialized, {level = XF.Settings.Network.CompressionLevel})
	return Deflate:EncodeForWoWAddonChannel(compressed)
end

-- Have not been able to identify why, but bnet does not like the output of deflate
function XF:EncodeBNetMessage(inMessage)
	assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), 'argument must be a Message type object')
	local serialized = SerializeMessage(inMessage, true)
	local compressed = Deflate:CompressDeflate(serialized, {level = XF.Settings.Network.CompressionLevel})
	return Deflate:EncodeForPrint(compressed)
end