local XFG, G = unpack(select(2, ...))
local LogCategory = 'NEncode'

-- BNet seems to have a cap of around 300 characters and there is no BNet support from AceComm/ChatThrottle
-- So have to strip down to bare essentials and reconstruct as much as we can on receiving end
-- I'm sure there's a cooler way of doing this :)
function XFG:EncodeMessage(inMessage, inEncodeUnitData)
	assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be a Message type object")
	local _MessageData = {}

	if(inMessage.__name == 'GuildMessage') then
		_MessageData.H = inMessage:GetFlags()
		_MessageData.L = inMessage:GetLineID()
		_MessageData.M = inMessage:GetMainName()
		_MessageData.W = inMessage:GetUnitName()		
	elseif(inMessage.__name == 'LogoutMessage' or inMessage.__name == 'AchievementMessage') then
		_MessageData.M = inMessage:GetMainName()		
		_MessageData.W = inMessage:GetUnitName()
	end

	if(inMessage:HasUnitData() and inEncodeUnitData) then
		_MessageData.Y = XFG:SerializeUnitData(inMessage:GetData())
	else
		_MessageData.Y = inMessage:GetData()
	end

	_MessageData.A = inMessage:GetKey()
	_MessageData.T = inMessage:GetTo()
	_MessageData.B = inMessage:GetFrom()	
	_MessageData.D = inMessage:GetSubject()
	_MessageData.E = inMessage:GetType()
	_MessageData.K = inMessage:GetTimeStamp()
	_MessageData.G = inMessage:GetGuildID() -- Realm and Faction can be extrapolated from GuildID
	_MessageData.Q = inMessage:GetRemainingTargets()
	_MessageData.PN = inMessage:GetPacketNumber()
	_MessageData.TP = inMessage:GetTotalPackets()

	local _Serialized = XFG:Serialize(_MessageData)
	local _Compressed = XFG.Lib.Compress:CompressHuffman(_Serialized)
	return XFG.Lib.Encode:Encode(_Compressed)
end

function XFG:SerializeUnitData(inUnitData)
	local _MessageData = {}

	if(inUnitData:HasCovenant()) then
		local _Covenant = inUnitData:GetCovenant()
		_MessageData.C = _Covenant:GetKey()
	end
	local _Faction = inUnitData:GetFaction()
	_MessageData.F = _Faction:GetKey()
	local _Guild = inUnitData:GetGuild()
	_MessageData.G = _Guild:GetID()
	_MessageData.H = inUnitData:GetGUID()
	if(inUnitData:HasRank()) then
		local _Rank = inUnitData:GetRank()
		_MessageData.I = _Rank:GetKey()
		_MessageData.J = _Rank:GetName()
	end
	_MessageData.L = inUnitData:GetLevel()
	_MessageData.M = (inUnitData:IsMobile() == true) and 1 or 0
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
	if(inUnitData:HasRace()) then
		local _Race = inUnitData:GetRace()
		_MessageData.R = _Race:GetKey()
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
	_MessageData.W = inUnitData:GetUnitName()
	_MessageData.Z = inUnitData:GetZone()

	return XFG:Serialize(_MessageData)
end