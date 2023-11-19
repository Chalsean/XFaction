local XF, G = unpack(select(2, ...))
local ObjectName = 'Encode'
local Deflate = XF.Lib.Deflate

-- BNet seems to have a cap of around 300 characters and there is no BNet support from AceComm/ChatThrottle
-- So have to strip down to bare essentials, like send race id instead of race name and reconstruct as much as we can on receiving end
-- I'm sure there's a cooler way of doing this :)
local function SerializeMessage(inMessage, inEncodeUnitData)
	local messageData = {}

	messageData.M = inMessage:GetMainName()
	messageData.N = inMessage:GetName()
	messageData.U = inMessage:GetUnitName()
	if(inMessage:HasGuild()) then
		messageData.H = inMessage:GetGuild():GetKey()
		-- Remove G/R once everyone is on 4.4 build
		messageData.G = inMessage:GetGuild():GetName()
		messageData.R = inMessage:GetGuild():GetRealm():GetID()
	end

	if(inMessage:HasUnitData() and inEncodeUnitData) then
		messageData.D = XF:SerializeUnitData(inMessage:GetData())
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

function XF:SerializeUnitData(inUnitData)
	local messageData = {}

	messageData.A = inUnitData:GetRace():GetKey()
	messageData.B = inUnitData:GetAchievementPoints()
	messageData.C = inUnitData:GetID()
	messageData.E = inUnitData:GetPresence()
	messageData.F = inUnitData:GetFaction():GetKey()	
	messageData.H = inUnitData:GetGuild():GetKey()
	-- Remove G/R after everyone on 4.4
	messageData.G = inUnitData:GetGuild():GetName()
	messageData.R = inUnitData:GetGuild():GetRealm():GetID()
	messageData.K = inUnitData:GetGUID()
	messageData.I = inUnitData:GetItemLevel()
	messageData.J = inUnitData:GetRank()
	messageData.L = inUnitData:GetLevel()
	messageData.M = inUnitData:HasMythicKey() and inUnitData:GetMythicKey():Serialize() or nil
	messageData.N = inUnitData:GetNote()
	messageData.O = inUnitData:GetClass():GetKey()
	messageData.P1 = inUnitData:HasProfession1() and inUnitData:GetProfession1():GetKey() or nil
	messageData.P2 = inUnitData:HasProfession2() and inUnitData:GetProfession2():GetKey() or nil
	messageData.U = inUnitData:GetUnitName()
	messageData.V = inUnitData:HasSpec() and inUnitData:GetSpec():GetKey() or nil
	messageData.X = inUnitData:GetVersion():GetKey()
	messageData.Y = inUnitData:GetPvP()

	if(inUnitData:GetZone():HasID()) then
		messageData.D = inUnitData:GetZone():GetID()
	else
		messageData.Z = inUnitData:GetZone():GetName()
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