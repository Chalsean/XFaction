local XFG, G = unpack(select(2, ...))
local LogCategory = 'NEncode'

-- BNet seems to have a cap of around 300 characters and there is no BNet support from AceComm/ChatThrottle
-- So have to strip down to bare essentials, like send race id instead of race name and reconstruct as much as we can on receiving end
-- I'm sure there's a cooler way of doing this :)
local function SerializeMessage(inMessage, inEncodeUnitData)
	local _MessageData = {}

	if(inMessage.__name == 'GuildMessage') then
		_MessageData.M = inMessage:GetMainName()
		_MessageData.N = inMessage:GetName()
		_MessageData.U = inMessage:GetUnitName()
		local _Guild = inMessage:GetGuild()
		_MessageData.G = _Guild:GetName()
		local _Realm = inMessage:GetRealm()
		_MessageData.R = _Realm:GetID()
	end

	if(inMessage:HasUnitData() and inEncodeUnitData) then
		_MessageData.D = XFG:SerializeUnitData(inMessage:GetData())
	else
		_MessageData.D = inMessage:GetData()
	end

	_MessageData.K = inMessage:GetKey()
	_MessageData.F = inMessage:GetFrom()	
	_MessageData.S = inMessage:GetSubject()
	_MessageData.Y = inMessage:GetType()
	_MessageData.I = inMessage:GetTimeStamp()
	_MessageData.A = inMessage:GetRemainingTargets()
	_MessageData.P = inMessage:GetPacketNumber()
	_MessageData.Q = inMessage:GetTotalPackets()
	_MessageData.V = inMessage:GetVersion()
	if(inMessage:HasTargets() and inMessage:HasNodes()) then
		_MessageData.L = ''
		for _, _Node in (inMessage:NodeIterator()) do
			_MessageData.L = _Message.L .. _Node:GetString() .. ';'
		end
	end

	return XFG:Serialize(_MessageData)
end

function XFG:SerializeUnitData(inUnitData)
	local _MessageData = {}

	local _Race = inUnitData:GetRace()
	_MessageData.A = _Race:GetKey()
	_MessageData.B = inUnitData:GetAchievementPoints()
	if(inUnitData:HasCovenant()) then
		local _Covenant = inUnitData:GetCovenant()
		_MessageData.C = _Covenant:GetKey()
	end
	local _Faction = inUnitData:GetFaction()
	_MessageData.F = _Faction:GetKey()
	local _Guild = inUnitData:GetGuild()
	_MessageData.G = _Guild:GetName()
	local _Realm = inUnitData:GetRealm()
	_MessageData.R = _Realm:GetID()
	_MessageData.K = inUnitData:GetGUID()
	_MessageData.I = inUnitData:GetItemLevel()
	_MessageData.J = inUnitData:GetRank()
	_MessageData.L = inUnitData:GetLevel()
	_MessageData.N = inUnitData:GetNote()
	local _Class = inUnitData:GetClass()
	_MessageData.O = _Class:GetKey()
	if(inUnitData:HasProfession1()) then
		local _Profession = inUnitData:GetProfession1()
		_MessageData.P1 = _Profession:GetKey()
	end
	if(inUnitData:HasProfession2()) then
		local _Profession = inUnitData:GetProfession2()
		_MessageData.P2 = _Profession:GetKey()
	end
	if(inUnitData:HasSoulbind()) then
		local _Soulbind = inUnitData:GetSoulbind()
		_MessageData.S = _Soulbind:GetKey()
	end	
	_MessageData.U = inUnitData:GetUnitName()	
	if(inUnitData:HasSpec()) then
		local _Spec = inUnitData:GetSpec()
		_MessageData.V = _Spec:GetKey()
	end
	_MessageData.X = inUnitData:GetVersion()
	_MessageData.Y = inUnitData:GetPvP()
	_MessageData.Z = inUnitData:GetZone()

	return XFG:Serialize(_MessageData)
end

function XFG:EncodeMessage(inMessage, inEncodeUnitData)
	assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be a Message type object")
	-- local _Serialized = SerializeMessage(inMessage, inEncodeUnitData)
	-- local _Compressed = XFG.Lib.Deflate:CompressDeflate(_Serialized, {level = XFG.Settings.Network.CompressionLevel})
	-- return XFG.Lib.Deflate:EncodeForWoWAddonChannel(_Compressed)
	local _Serialized = SerializeMessage(inMessage, inEncodeUnitData)
	local _Compressed = XFG.Lib.Compress:CompressHuffman(_Serialized)
	return XFG.Lib.Encode:Encode(_Compressed)
end

-- Have not been able to identify why, but bnet does not like the output of deflate
function XFG:EncodeBNetMessage(inMessage, inEncodeUnitData)
	assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be a Message type object")
	local _Serialized = SerializeMessage(inMessage, inEncodeUnitData)
	local _Compressed = XFG.Lib.Compress:CompressHuffman(_Serialized)
	return XFG.Lib.Encode:Encode(_Compressed)
end