local XFG, E, L, V, P, G = unpack(select(2, ...))
local LogCategory = 'NEncode'

-- BNet seems to have a cap of around 300 characters and there is no BNet support from AceComm/ChatThrottle
-- So have to strip down to bare essentials and reconstruct as much as we can on receiving end
function XFG:EncodeMessage(inMessage)

	assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be a Message type object")
	local _MessageData = {}

	if(inMessage.__name == 'GuildMessage') then
		_MessageData.GUID = inMessage:GetFromGUID()
		local _Faction = inMessage:GetFaction()
		_MessageData.Faction = _Faction:GetKey()
		_MessageData.Flags = inMessage:GetFlags()
		_MessageData.LineID = inMessage:GetLineID()
		-- Review: Should be transferring guild ID
		_MessageData.GuildShortName = inMessage:GetGuildShortName()
		_MessageData.MainName = inMessage:GetMainName()
		_MessageData.Y = inMessage:GetData()
	elseif(inMessage:GetSubject() == XFG.Network.Message.Subject.DATA or inMessage:GetSubject() == XFG.Network.Message.Subject.LOGIN) then
		_MessageData = XFG:TarballUnitData(inMessage:GetData())
	end

	_MessageData.A = inMessage:GetKey()
	--_MessageData.To = inMessage:GetTo()
	_MessageData.B = inMessage:GetFrom()	
	_MessageData.D = inMessage:GetSubject()
	_MessageData.E = inMessage:GetType()
	_MessageData.K = inMessage:GetTimeStamp()

	local _Serialized = XFG:Serialize(_MessageData)
	local _Compressed = XFG.Lib.Compress:CompressHuffman(_Serialized)
	return XFG.Lib.Encode:Encode(_Compressed)
end

function XFG:TarballUnitData(inUnitData)
	
	local _MessageData = {}

	if(inUnitData:HasCovenant()) then
		local _Covenant = inUnitData:GetCovenant()
		_MessageData.C = _Covenant:GetKey()
	end
	local _Faction = inUnitData:GetFaction()
	_MessageData.F = _Faction:GetKey()
	_MessageData.G = inUnitData:GetGUID()
	local _Guild = inUnitData:GetGuild()
	_MessageData.H = _Guild:GetID()
	if(inUnitData:HasRank()) then
		local _Rank = inUnitData:GetRank()
		_MessageData.I = _Rank:GetKey()
		_MessageData.J = _Rank:GetName()
	end
	_MessageData.L = inUnitData:GetLevel()
	_MessageData.M = (inUnitData:IsMobile() == true) and 1 or 0
	_MessageData.Q = inUnitData:GetNote()
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
		_MessageData.X = _Spec:GetKey()
	end	
	_MessageData.Z = inUnitData:GetZone()

	return _MessageData
end
