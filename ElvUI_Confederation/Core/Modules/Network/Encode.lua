local CON, E, L, V, P, G = unpack(select(2, ...))
local LogCategory = 'MEncode'
local Initialized = false

-- To reduce payload, strip out unnecessary key characters, replace text with ids, compress, etc.
-- The message will get reconstructed to original state on receiving end
function CON:EncodeMessage(inMessage)
	assert(type(inMessage) == 'table' and inMessage.__name ~= nil and inMessage.__name == 'Message', "argument must be a Message object")

	local _MessageData = {}
	_MessageData.K = inMessage:GetKey()
	_MessageData.To = inMessage:GetTo()
	_MessageData.F = inMessage:GetFrom()
	_MessageData.S = inMessage:GetSubject()
	_MessageData.Ty = inMessage:GetType()

	if(inMessage:GetSubject() == CON.Network.Message.Subject.DATA) then
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
		--_MessageUnitData.T = _UnitData:GetTeamName()
		_MessageData.T = 'Y'
		_MessageData.A = (_UnitData:IsAlt() == true) and 1 or 0
		_MessageData.RA = (_UnitData:IsRunningAddon() == true) and 1 or 0
		_MessageData.U = _UnitData:GetUnitName()
		_MessageData.RN = _UnitData:GetRealmName()
		_MessageData.Z = _UnitData:GetZone()

		local _Class = _UnitData:GetClass()
		_MessageData.C = _Class:GetID()
		
		local _Race = _UnitData:GetRace()
		_MessageData.R = _Race:GetID()

		if(_UnitData:HasCovenant()) then
			local _Covenant = _UnitData:GetCovenant()
			_MessageData.Co = _Covenant:GetID()
		 end

		if(_UnitData:HasSoulbind()) then
			local _Soulbind = _UnitData:GetSoulbind()
			_MessageData.So = _Soulbind:GetID()
		end
		
		if(_UnitData:HasProfession1()) then
			local _Profession = _UnitData:GetSoulbind()
			_MessageData.P1 = _Profession:GetID()
		end

		if(_UnitData:HasProfession2()) then
			local _Profession = _UnitData:GetSoulbind()
			_MessageData.P2 = _Profession:GetID()
		end

		local _Spec = _UnitData:GetSpec()
		_MessageData.X = _Spec:GetID()
	else
		_MessageData.Z = inMessage:GetData()
	end

	local _Serialized = CON:Serialize(_MessageData)
	local _Compressed = CON.Lib.Compress:Compress(_Serialized)
	return CON.Lib.Encode:Encode(_Compressed)
end