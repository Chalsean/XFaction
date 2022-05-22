local CON, E, L, V, P, G = unpack(select(2, ...))
local LogCategory = 'MEncode'
local Initialized = false
local COMPRESS = LibStub:GetLibrary("LibCompress")
local ENCODE = COMPRESS:GetAddonEncodeTable()

-- Reconstruct a Unit object from the message
function CON:DecodeMessage(inMessage)	
	
	local _Decoded = ENCODE:Decode(inMessage)
	local _Decompressed = COMPRESS:DecompressHuffman(_Decoded)
	local _, _MessageData = CON:Deserialize(_Decompressed)

	CON:DataDumper(LogCategory, _MessageData)

	local _Message = Message:new()
	if(_MessageData.To ~= nil) then	_Message:SetTo(_MessageData.To)	end
	if(_MessageData.F ~= nil) then _Message:SetFrom(_MessageData.F)	end
	if(_MessageData.S ~= nil) then _Message:SetSubject(_MessageData.S) end
	if(_MessageData.Ty ~= nil) then	_Message:SetType(_MessageData.Ty) end

	if(_Message:GetSubject() == CON.Network.Message.Subject.DATA) then
		local _UnitData = Unit:new()
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
		--_UnitData:SetZone(_MessageData[Z])

		_UnitData:SetClass(CON.Classes:GetClass(_MessageData.C))
		_UnitData:SetRace(CON.Races:GetRace(_MessageData.R))
		_UnitData:SetCovenant(CON.Covenants:GetCovenant(_MessageData.Co))
		_UnitData:SetSoulbind(CON.Soulbinds:GetSoulbind(_MessageData.So))
		-- _UnitData:SetProfession1(CON.Professions:GetProfession(_MessageData.P1))
		-- _UnitData:SetProfession2(CON.Professions:GetProfession(_MessageData.P2))
		_UnitData:SetSpec(CON.Specs:GetSpec(_MessageData.X))
		_Message:SetData(_UnitData)
	else
		_Message:SetData(_MessageData.Z)
	end

	return _Message
end