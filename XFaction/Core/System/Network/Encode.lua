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
	messageData.H = inMessage:GetGuild():Key()

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
	messageData.X = inMessage:HasFromUnit() and inMessage:FromUnit():Serialize() or nil
	messageData.L = XFO.Links:Serialize(true)

	return pickle(messageData)
end

function XF:SerializeUnitData(inUnitData)
	local messageData = {}

	messageData.A = inUnitData:Race():Key()
	messageData.B = inUnitData:AchievementPoints()
	messageData.C = inUnitData:ID()
	messageData.E = inUnitData:Presence()
	messageData.F = inUnitData:Race():Faction():Key()	
	messageData.H = inUnitData:Guild():Key()
	messageData.K = inUnitData:GUID()
	messageData.I = inUnitData:ItemLevel()
	messageData.J = inUnitData:Rank()
	messageData.L = inUnitData:Level()
	messageData.M = inUnitData:HasMythicKey() and inUnitData:MythicKey():Serialize() or nil
	messageData.N = inUnitData:Note()
	messageData.O = inUnitData:Spec():Class():Key()
	messageData.P1 = inUnitData:HasProfession1() and inUnitData:Profession1():Key() or nil
	messageData.P2 = inUnitData:HasProfession2() and inUnitData:Profession2():Key() or nil
	messageData.U = inUnitData:UnitName()
	messageData.V = inUnitData:Spec():Key()
	messageData.X = inUnitData:Version():Key()
	messageData.Y = inUnitData:PvP()

	if(inUnitData:Zone():HasID()) then
		messageData.D = inUnitData:Zone():ID()
	else
		messageData.Z = inUnitData:Zone():Name()
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