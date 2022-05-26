local CON, E, L, V, P, G = unpack(select(2, ...))
local LogCategory = 'MEncode'
local Initialized = false

-- Reconstruct a Unit object from the message
function CON:DecodeMessage(inMessage)	
	
	local _Decoded = CON.Lib.Encode:Decode(inMessage)
	local _Decompressed = CON.Lib.Compress:DecompressHuffman(_Decoded)
	local _, _MessageData = CON:Deserialize(_Decompressed)

	local _Message = Message:new()
	if(_MessageData.K ~= nil) then	_Message:SetKey(_MessageData.K)	end
	if(_MessageData.To ~= nil) then	_Message:SetTo(_MessageData.To)	end
	if(_MessageData.F ~= nil) then _Message:SetFrom(_MessageData.F)	end
	if(_MessageData.S ~= nil) then _Message:SetSubject(_MessageData.S) end
	if(_MessageData.Ty ~= nil) then	_Message:SetType(_MessageData.Ty) end
	if(_MessageData.FN ~= nil) then _Message:SetFaction(CON.Factions:GetFaction(_MessageData.FN)) end

	if(_Message:GetSubject() == CON.Network.Message.Subject.DATA) then
		local _UnitData = Unit:new()
		_UnitData:SetKey(_Message:GetFrom())
		_UnitData:SetGuildIndex(_MessageData.GI)
		_UnitData:SetName(_MessageData.N)
		_UnitData:SetGuildName(_MessageData.GN)
		_UnitData:SetLevel(_MessageData.L)
		_UnitData:SetNote(_MessageData.No)
		_UnitData:IsOnline(_MessageData.O == 1)
		_UnitData:IsMobile(_MessageData.M == 1)
		_UnitData:SetGUID(_MessageData.G)
		_UnitData:SetTimeStamp(_MessageData.TS)
		_UnitData:SetTeamName(_MessageData.T)
		_UnitData:IsAlt(_MessageData.A == 1)
		_UnitData:IsRunningAddon(_MessageData.RA == 1)
		_UnitData:SetUnitName(_MessageData.U)
		_UnitData:SetRealmName(_MessageData.RN)
		_UnitData:SetZone(_MessageData.Z)

		_UnitData:SetClass(CON.Classes:GetClass(_MessageData.C))
		_UnitData:SetRace(CON.Races:GetRace(_MessageData.R))
		if(_MessageData.Co ~= nil) then
			_UnitData:SetCovenant(CON.Covenants:GetCovenant(_MessageData.Co))
		end
		if(_MessageData.So ~= nil) then
			_UnitData:SetSoulbind(CON.Soulbinds:GetSoulbind(_MessageData.So))
		end
		if(_MessageData.P1 ~= nil) then
			_UnitData:SetProfession1(CON.Professions:GetProfession(_MessageData.P1))
		end
		if(_MessageData.P2 ~= nil) then
			_UnitData:SetProfession2(CON.Professions:GetProfession(_MessageData.P2))
		end
		if(_MessageData.X ~= nil) then
			_UnitData:SetSpec(CON.Specs:GetSpec(_MessageData.X))
		end
		_Message:SetData(_UnitData)
	else
		_Message:SetData(_MessageData.Y)
	end

	return _Message
end