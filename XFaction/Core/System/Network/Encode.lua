local XF, G = unpack(select(2, ...))
local ObjectName = 'Encode'
local Deflate = XF.Lib.Deflate

-- FIX: Move all this logic into Message class

-- BNet seems to have a cap of around 300 characters and there is no BNet support from AceComm/ChatThrottle
-- So have to strip down to bare essentials, like send race id instead of race name and reconstruct as much as we can on receiving end
-- I'm sure there's a cooler way of doing this :)
local function SerializeMessage(inMessage, inEncodeUnitData)
	local messageData = {}

	messageData.F = XF:SerializeUnitData(inMessage:GetFrom())
	messageData.K = inMessage:GetKey()
	messageData.T = inMessage:GetTo()
	messageData.S = inMessage:GetSubject()
	messageData.Y = inMessage:GetType()
	messageData.I = inMessage:GetTimeStamp()
	messageData.A = inMessage:GetRemainingTargets()
	messageData.P = inMessage:GetPacketNumber()
	messageData.Q = inMessage:GetTotalPackets()

	return pickle(messageData)
end

function XF:SerializeUnitData(inUnitData)
	local messageData = {}

	-- FIX: Faction can be gotten via Race
	messageData.A = inUnitData:GetRace():GetKey()
	messageData.B = inUnitData:GetAchievementPoints()
	-- FIX: memberID is not used
	messageData.C = inUnitData:GetID()
	messageData.E = inUnitData:GetPresence()
	messageData.H = inUnitData:GetGuild():GetKey()
	messageData.K = inUnitData:GetGUID()
	messageData.I = inUnitData:GetItemLevel()
	messageData.J = inUnitData:GetRank()
	messageData.L = inUnitData:GetLevel()
	messageData.M = inUnitData:HasMythicKey() and inUnitData:GetMythicKey():Serialize() or nil
	messageData.N = inUnitData:GetNote()
	-- FIX: Class can be gotten via Spec
	messageData.O = inUnitData:GetClass():GetKey()
	messageData.P1 = inUnitData:HasProfession1() and inUnitData:GetProfession1():GetKey() or nil
	messageData.P2 = inUnitData:HasProfession2() and inUnitData:GetProfession2():GetKey() or nil
	messageData.U = inUnitData:GetUnitName()
	messageData.V = inUnitData:HasSpec() and inUnitData:GetSpec():GetKey() or nil
	messageData.X = inUnitData:GetVersion():GetKey()
	messageData.Y = inUnitData:GetPvP()
	messageData.Z = inUnitData:GetZone():GetName()

	return pickle(messageData)
end

-- FIX: Move to Chat class
function XF:EncodeChatMessage(inMessage, inEncodeUnitData)
	assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), 'argument must be a Message type object')
	local serialized = SerializeMessage(inMessage, inEncodeUnitData)
	local compressed = Deflate:CompressDeflate(serialized, {level = XF.Settings.Network.CompressionLevel})
	return Deflate:EncodeForWoWAddonChannel(compressed)
end

-- FIX: Move to BNet class
-- Have not been able to identify why, but bnet does not like the output of deflate
function XF:EncodeBNetMessage(inMessage)
	assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), 'argument must be a Message type object')
	local serialized = SerializeMessage(inMessage, true)
	local compressed = Deflate:CompressDeflate(serialized, {level = XF.Settings.Network.CompressionLevel})
	return Deflate:EncodeForPrint(compressed)
end