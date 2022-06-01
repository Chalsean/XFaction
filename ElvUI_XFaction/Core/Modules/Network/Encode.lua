local XFG, E, L, V, P, G = unpack(select(2, ...))
local LogCategory = 'NEncode'

-- To reduce payload, strip out unnecessary key characters, replace text with ids, compress, etc.
-- The message will get reconstructed to original state on receiving end
function XFG:EncodeMessage(inMessage)

	assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be a Message type object")
	local _MessageData = {}

	if(inMessage.__name == 'GuildMessage') then
		_MessageData.FG = inMessage:GetFromGUID()
		local _Faction = inMessage:GetFaction()
		_MessageData.FN = _Faction:GetKey()
		_MessageData.Fl = inMessage:GetFlags()
		_MessageData.LI = inMessage:GetLineID()
		-- Review: Should be transferring guild ID
		_MessageData.GSN = inMessage:GetGuildShortName()
		_MessageData.MN = inMessage:GetMainName()
		_MessageData.Y = inMessage:GetData()
	elseif(inMessage:GetSubject() == XFG.Network.Message.Subject.DATA or inMessage:GetSubject() == XFG.Network.Message.Subject.LOGIN) then
		_MessageData = XFG:TarballUnitData(inMessage:GetData())
	end

	_MessageData.K = inMessage:GetKey()
	_MessageData.To = inMessage:GetTo()
	_MessageData.F = inMessage:GetFrom()	
	_MessageData.S = inMessage:GetSubject()
	_MessageData.Ty = inMessage:GetType()
	_MessageData.TS = inMessage:GetTimeStamp()

	local _Serialized = XFG:Serialize(_MessageData)
	local _Compressed = XFG.Lib.Compress:Compress(_Serialized)
	return XFG.Lib.Encode:Encode(_Compressed)
end

function XFG:TarballUnitData(inUnitData)
	local _MessageData = {}

	_MessageData.GI = inUnitData:GetGuildIndex()
	_MessageData.N = inUnitData:GetName()
	local _Guild = inUnitData:GetGuild()
	_MessageData.GN = _Guild:GetName()
	_MessageData.L = inUnitData:GetLevel()
	_MessageData.No = inUnitData:GetNote()
	_MessageData.O = (inUnitData:IsOnline() == true) and 1 or 0
	_MessageData.M = (inUnitData:IsMobile() == true) and 1 or 0
	_MessageData.G = inUnitData:GetGUID()
	_MessageData.TS = inUnitData:GetTimeStamp()		
	_MessageData.A = (inUnitData:IsAlt() == true) and 1 or 0
	_MessageData.RA = (inUnitData:IsRunningAddon() == true) and 1 or 0
	_MessageData.U = inUnitData:GetUnitName()
	local _Realm = inUnitData:GetRealm()
	-- Review: Should transfer realm ID
	_MessageData.RN = _Realm:GetName()
	_MessageData.Z = inUnitData:GetZone()
	_MessageData.MN = inUnitData:GetMainName()

	local _Team = inUnitData:GetTeam()
	_MessageData.T = _Team:GetKey()

	local _Faction = inUnitData:GetFaction()
	_MessageData.Fa = _Faction:GetKey()

	local _Class = inUnitData:GetClass()
	_MessageData.C = _Class:GetKey()
	
	local _Race = inUnitData:GetRace()
	_MessageData.R = _Race:GetKey()

	if(inUnitData:HasCovenant()) then
		local _Covenant = inUnitData:GetCovenant()
		_MessageData.Co = _Covenant:GetKey()
	 end

	if(inUnitData:HasSoulbind()) then
		local _Soulbind = inUnitData:GetSoulbind()
		_MessageData.So = _Soulbind:GetKey()
	end
	
	if(inUnitData:HasProfession1()) then
		local _Profession = inUnitData:GetProfession1()
		_MessageData.P1 = _Profession:GetKey()
	end

	if(inUnitData:HasProfession2()) then
		local _Profession = inUnitData:GetProfession2()
		_MessageData.P2 = _Profession:GetKey()
	end

	if(inUnitData:HasSpec()) then
		local _Spec = inUnitData:GetSpec()
		_MessageData.X = _Spec:GetKey()
	end	

	if(inUnitData:HasRank()) then
		local _Rank = inUnitData:GetRank()
		_MessageData.GR = _Rank:GetKey()
		_MessageData.GRN = _Rank:GetName()
	end

	return _MessageData
end
