local EKX, E, L, V, P, G = unpack(select(2, ...))
local LogCategory = 'NDecode'
local Initialized = false

-- Reconstruct a Unit object from the message
function EKX:DecodeMessage(inMessage)	
	
	local _Decoded = EKX.Lib.Encode:Decode(inMessage)
	local _Decompressed = EKX.Lib.Compress:DecompressHuffman(_Decoded)
	local _, _MessageData = EKX:Deserialize(_Decompressed)

	local _Message = Message:new(); _Message:Initialize()
	if(_MessageData.K ~= nil) then	_Message:SetKey(_MessageData.K)	end
	if(_MessageData.To ~= nil) then	_Message:SetTo(_MessageData.To)	end
	if(_MessageData.F ~= nil) then _Message:SetFrom(_MessageData.F)	end
	if(_MessageData.FG ~= nil) then _Message:SetFromGUID(_MessageData.FG)	end
	if(_MessageData.S ~= nil) then _Message:SetSubject(_MessageData.S) end
	if(_MessageData.Ty ~= nil) then	_Message:SetType(_MessageData.Ty) end
	if(_MessageData.FN ~= nil) then _Message:SetFaction(EKX.Factions:GetFaction(_MessageData.FN)) end
	if(_MessageData.TS ~= nil) then	_Message:SetTimeStamp(_MessageData.TS) end
	if(_MessageData.Fl ~= nil) then	_Message:SetFlags(_MessageData.Fl) end
	if(_MessageData.LI ~= nil) then	_Message:SetLineID(_MessageData.LI) end

	if(_Message:GetSubject() == EKX.Network.Message.Subject.DATA) then
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
		_UnitData:SetFaction(EKX.Factions:GetFaction(_MessageData.Fa))
		_UnitData:SetClass(EKX.Classes:GetClass(_MessageData.C))
		_UnitData:SetRace(EKX.Races:GetRace(_MessageData.R))
		
		if(_MessageData.Co ~= nil) then
			_UnitData:SetCovenant(EKX.Covenants:GetCovenant(_MessageData.Co))
		end
		if(_MessageData.So ~= nil) then
			_UnitData:SetSoulbind(EKX.Soulbinds:GetSoulbind(_MessageData.So))
		end
		if(_MessageData.P1 ~= nil) then
			_UnitData:SetProfession1(EKX.Professions:GetProfession(_MessageData.P1))
		end
		if(_MessageData.P2 ~= nil) then
			_UnitData:SetProfession2(EKX.Professions:GetProfession(_MessageData.P2))
		end
		if(_MessageData.X ~= nil) then
			_UnitData:SetSpec(EKX.Specs:GetSpec(_MessageData.X))
		end
		_Message:SetData(_UnitData)
	else
		_Message:SetData(_MessageData.Y)
	end

	return _Message
end