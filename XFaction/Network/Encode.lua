local XFG, G = unpack(select(2, ...))
local LogCategory = 'Encode'

local Deflate = XFG.Lib.Deflate

-- BNet seems to have a cap of around 300 characters and there is no BNet support from AceComm/ChatThrottle
-- So have to strip down to bare essentials, like send race id instead of race name and reconstruct as much as we can on receiving end
-- I'm sure there's a cooler way of doing this :)
local function SerializeMessage(inMessage, inEncodeUnitData)
	local _MessageData = {}

	_MessageData.M = inMessage:GetMainName()
	_MessageData.N = inMessage:GetName()
	_MessageData.U = inMessage:GetUnitName()
	if(inMessage:HasGuild()) then
		_MessageData.G = inMessage:GetGuild():GetName()
	end
	if(inMessage:HasRealm()) then
		_MessageData.R = inMessage:GetRealm():GetID()
	end

	if(inMessage:HasUnitData() and inEncodeUnitData) then
		_MessageData.D = XFG:SerializeUnitData(inMessage:GetData())
	else
		_MessageData.D = inMessage:GetData()
	end

	_MessageData.K = inMessage:GetKey()
	_MessageData.T = inMessage:GetTo()
	_MessageData.F = inMessage:GetFrom()	
	_MessageData.S = inMessage:GetSubject()
	_MessageData.Y = inMessage:GetType()
	_MessageData.I = inMessage:GetTimeStamp()
	_MessageData.A = inMessage:GetRemainingTargets()
	_MessageData.P = inMessage:GetPacketNumber()
	_MessageData.Q = inMessage:GetTotalPackets()
	_MessageData.V = inMessage:GetVersion():GetKey()

	return XFG:Serialize(_MessageData)
end

function XFG:SerializeUnitData(inUnitData)
	local _MessageData = {}

	local _Race = inUnitData:GetRace()
	_MessageData.A = _Race:GetKey()
	_MessageData.B = inUnitData:GetAchievementPoints()
	if(inUnitData:HasCovenant()) then
		_MessageData.C = inUnitData:GetCovenant():GetKey()
	end
	_MessageData.F = inUnitData:GetFaction():GetKey()
	_MessageData.G = inUnitData:GetGuild():GetName()
	_MessageData.R = inUnitData:GetRealm():GetID()
	_MessageData.K = inUnitData:GetGUID()
	_MessageData.I = inUnitData:GetItemLevel()
	_MessageData.J = inUnitData:GetRank()
	_MessageData.L = inUnitData:GetLevel()
	_MessageData.N = inUnitData:GetNote()
	_MessageData.O = inUnitData:GetClass():GetKey()
	if(inUnitData:HasProfession1()) then
		_MessageData.P1 = inUnitData:GetProfession1():GetKey()
	end
	if(inUnitData:HasProfession2()) then
		_MessageData.P2 = inUnitData:GetProfession2():GetKey()
	end
	if(inUnitData:HasSoulbind()) then
		_MessageData.S = inUnitData:GetSoulbind():GetKey()
	end	
	_MessageData.U = inUnitData:GetUnitName()	
	if(inUnitData:HasSpec()) then
		_MessageData.V = inUnitData:GetSpec():GetKey()
	end
	_MessageData.X = inUnitData:GetVersion():GetKey()
	_MessageData.Y = inUnitData:GetPvP()

	if(inUnitData:GetZone():HasID()) then
		_MessageData.D = inUnitData:GetZone():GetID()
	else
		_MessageData.Z = inUnitData:GetZone():GetName()
	end

	return XFG:Serialize(_MessageData)
end

function XFG:EncodeChatMessage(inMessage, inEncodeUnitData)
	assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be a Message type object")
	local _Serialized = SerializeMessage(inMessage, inEncodeUnitData)
	local _Compressed = Deflate:CompressDeflate(_Serialized, {level = XFG.Settings.Network.CompressionLevel})
	return Deflate:EncodeForWoWAddonChannel(_Compressed)
end

-- Have not been able to identify why, but bnet does not like the output of deflate
function XFG:EncodeBNetMessage(inMessage)
	assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be a Message type object")
	local _Serialized = SerializeMessage(inMessage, true)
	local _Compressed = Deflate:CompressDeflate(_Serialized, {level = XFG.Settings.Network.CompressionLevel})
	return Deflate:EncodeForPrint(_Compressed)
end