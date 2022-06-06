local XFG, E, L, V, P, G = unpack(select(2, ...))
local LogCategory = 'NDecode'

function XFG:DecodeMessage(inEncodedMessage)
	local _Decoded = XFG.Lib.Encode:Decode(inEncodedMessage)
	local _Decompressed = XFG.Lib.Compress:DecompressHuffman(_Decoded)
	local _, _MessageData = XFG:Deserialize(_Decompressed)

	local _Message
	if(_MessageData.D == XFG.Network.Message.Subject.GCHAT) then
		_Message = GuildMessage:new()
	elseif(_MessageData.D == XFG.Network.Message.Subject.LOGOUT) then
		_Message = LogoutMessage:new()
	elseif(_MessageData.D == XFG.Network.Message.Subject.ACHIEVEMENT) then
		_Message = AchievementMessage:new()
	else
		_Message = Message:new()
	end	
	_Message:Initialize()
	
	if(_MessageData.A ~= nil) then	_Message:SetKey(_MessageData.A)	end
	if(_MessageData.T ~= nil) then	_Message:SetTo(_MessageData.T)	end
	if(_MessageData.B ~= nil) then _Message:SetFrom(_MessageData.B)	end	
	if(_MessageData.D ~= nil) then _Message:SetSubject(_MessageData.D) end
	if(_MessageData.E ~= nil) then	_Message:SetType(_MessageData.E) end	
	if(_MessageData.K ~= nil) then	_Message:SetTimeStamp(_MessageData.K) end	
	if(_MessageData.G ~= nil) then	_Message:SetGuildID(_MessageData.G) end
	if(_MessageData.Q ~= nil) then _Message:SetRemainingTargets(_MessageData.Q) end
	if(_MessageData.PN ~= nil) then _Message:SetPacketNumber(_MessageData.PN) end
	if(_MessageData.TP ~= nil) then _Message:SetTotalPackets(_MessageData.TP) end

	if(_Message:GetSubject() == XFG.Network.Message.Subject.GCHAT) then
		if(_MessageData.H ~= nil) then	_Message:SetFlags(_MessageData.H) end
		if(_MessageData.L ~= nil) then	_Message:SetLineID(_MessageData.L) end		
		if(_MessageData.M ~= nil) then	_Message:SetMainName(_MessageData.M) end
		if(_MessageData.W ~= nil) then	_Message:SetUnitName(_MessageData.W) end
	elseif(_Message:GetSubject() == XFG.Network.Message.Subject.LOGOUT or _Message:GetSubject() == XFG.Network.Message.Subject.ACHIEVEMENT) then
		if(_MessageData.M ~= nil) then	_Message:SetMainName(_MessageData.M) end
		if(_MessageData.W ~= nil) then	_Message:SetUnitName(_MessageData.W) end
	end

	-- Leave any UnitData serialized for now
	_Message:SetData(_MessageData.Y)
	return _Message
end

function XFG:DeserializeUnitData(inData)
	local _, _DeserializedData = XFG:Deserialize(inData)
	local _UnitData = Unit:new()
	if(_DeserializedData.C ~= nil) then
		_UnitData:SetCovenant(XFG.Covenants:GetCovenant(_DeserializedData.C))
	end
	_UnitData:SetFaction(XFG.Factions:GetFaction(_DeserializedData.F))
	_UnitData:SetGUID(_DeserializedData.H)
	_UnitData:SetKey(_DeserializedData.H)
	_UnitData:SetClass(XFG.Classes:GetClass(_DeserializedData.O))
	_UnitData:SetRace(XFG.Races:GetRace(_DeserializedData.R))
	local _UnitNameParts = string.Split(_DeserializedData.W, '-')
	_UnitData:SetName(_UnitNameParts[1])
	_UnitData:SetUnitName(_DeserializedData.W)
	local _Guild = XFG.Guilds:GetGuildByID(_DeserializedData.G)
	_UnitData:SetGuild(_Guild)
	_UnitData:SetRealm(_Guild:GetRealm())

	-- There is no API to query for all guild ranks+names, so have to add them as you see them
	if(_DeserializedData.I ~= nil) then
		if(XFG.Ranks:Contains(_DeserializedData.I) == false) then
			local _NewRank = Rank:new()
			_NewRank:SetKey(_DeserializedData.I)
			_NewRank:SetID(_DeserializedData.I)
			_NewRank:SetName(_DeserializedData.J)
			XFG.Ranks:AddRank(_NewRank)
		end
		_UnitData:SetRank(XFG.Ranks:GetRank(_DeserializedData.I))
	end

	_UnitData:SetLevel(_DeserializedData.L)
	_UnitData:IsMobile(_DeserializedData.M == 1)
	_UnitData:SetNote(_DeserializedData.N)	
	_UnitData:IsOnline(true)
	if(_DeserializedData.P1 ~= nil) then
		_UnitData:SetProfession1(XFG.Professions:GetProfession(_DeserializedData.P1))
	end
	if(_DeserializedData.P2 ~= nil) then
		_UnitData:SetProfession2(XFG.Professions:GetProfession(_DeserializedData.P2))
	end
	_UnitData:IsRunningAddon(true)
	if(_DeserializedData.S ~= nil) then
		_UnitData:SetSoulbind(XFG.Soulbinds:GetSoulbind(_DeserializedData.S))
	end
	_UnitData:SetTimeStamp(GetServerTime())
	if(_DeserializedData.V ~= nil) then
		_UnitData:SetSpec(XFG.Specs:GetSpec(_DeserializedData.V))
	end
	_UnitData:SetZone(_DeserializedData.Z)

	local _Note = _UnitData:GetNote()
    local _UpperNote = string.upper(_Note)
	if(string.match(_UpperNote, "%[EN?KA?H?%]")) then
		_UnitData:IsAlt(true)
        local _MainName = string.match(_Note, "[^%s%d]*$") 
        if(_MainName ~= nil) then
            _UnitData:SetMainName(_MainName)
        end
	end

    for _Key, _Team in XFG.Teams:Iterator() do
        local _Regex = '%[' .. _Team:GetShortName() .. '%]'
        if(string.match(_UpperNote, _Regex)) then
            _UnitData:SetTeam(_Team)
            break
        end
    end

	if(_UnitData:HasTeam() == false) then
        local _Team = XFG.Teams:GetTeam('U')
        _UnitData:SetTeam(_Team)
    end

	return _UnitData
end
