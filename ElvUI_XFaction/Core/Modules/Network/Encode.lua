local XFG, E, L, V, P, G = unpack(select(2, ...))
local LogCategory = 'NEncode'
local Initialized = false

-- To reduce payload, strip out unnecessary key characters, replace text with ids, compress, etc.
-- The message will get reconstructed to original state on receiving end
function XFG:EncodeMessage(inMessage)
	assert(type(inMessage) == 'table' and inMessage.__name ~= nil and inMessage.__name == 'Message', "argument must be a Message object")

	local _MessageData = {}
	_MessageData.K = inMessage:GetKey()
	_MessageData.To = inMessage:GetTo()
	_MessageData.F = inMessage:GetFrom()
	_MessageData.FG = inMessage:GetFromGUID()
	_MessageData.S = inMessage:GetSubject()
	_MessageData.Ty = inMessage:GetType()
	local _Faction = inMessage:GetFaction()
	_MessageData.FN = _Faction:GetKey()
	_MessageData.TS = inMessage:GetTimeStamp()
	_MessageData.Fl = inMessage:GetFlags()
	_MessageData.LI = inMessage:GetLineID()

	if(inMessage:GetSubject() == XFG.Network.Message.Subject.DATA) then
		local _UnitData = inMessage:GetData()

		_MessageData.GI = _UnitData:GetGuildIndex()
		_MessageData.N = _UnitData:GetName()
		_MessageData.GN = _UnitData:GetGuildName()
		--_MessageUnitData.GR = _UnitData:GetGuildRank()
		_MessageData.L = _UnitData:GetLevel()
		_MessageData.No = _UnitData:GetNote()
		_MessageData.O = (_UnitData:IsOnline() == true) and 1 or 0
		--_MessageUnitData.S = _UnitData:GetStatus()
		_MessageData.M = (_UnitData:IsMobile() == true) and 1 or 0
		_MessageData.G = _UnitData:GetGUID()
		_MessageData.TS = _UnitData:GetTimeStamp()
		_MessageData.T = _UnitData:GetTeamName()
		_MessageData.A = (_UnitData:IsAlt() == true) and 1 or 0
		_MessageData.RA = (_UnitData:IsRunningAddon() == true) and 1 or 0
		_MessageData.U = _UnitData:GetUnitName()
		_MessageData.RN = _UnitData:GetRealmName()
		_MessageData.Z = _UnitData:GetZone()
		_MessageData.MN = _UnitData:GetMainName()

		local _Faction = _UnitData:GetFaction()
		_MessageData.Fa = _Faction:GetKey()

		local _Class = _UnitData:GetClass()
		_MessageData.C = _Class:GetKey()
		
		local _Race = _UnitData:GetRace()
		_MessageData.R = _Race:GetKey()

		if(_UnitData:HasCovenant()) then
			local _Covenant = _UnitData:GetCovenant()
			_MessageData.Co = _Covenant:GetKey()
		 end

		if(_UnitData:HasSoulbind()) then
			local _Soulbind = _UnitData:GetSoulbind()
			_MessageData.So = _Soulbind:GetKey()
		end
		
		if(_UnitData:HasProfession1()) then
			local _Profession = _UnitData:GetProfession1()
			_MessageData.P1 = _Profession:GetKey()
		end

		if(_UnitData:HasProfession2()) then
			local _Profession = _UnitData:GetProfession2()
			_MessageData.P2 = _Profession:GetKey()
		end

		if(_UnitData:HasSpec()) then
			local _Spec = _UnitData:GetSpec()
			_MessageData.X = _Spec:GetKey()
		end

		-- Rare instance where whole object is sent, receiver may not have seen this rank yet
		--_MessageData.GR = _UnitData:GetRank()
	else
		_MessageData.Y = inMessage:GetData()
	end

	local _Serialized = XFG:Serialize(_MessageData)
	local _Compressed = XFG.Lib.Compress:Compress(_Serialized)
	return XFG.Lib.Encode:Encode(_Compressed)
end