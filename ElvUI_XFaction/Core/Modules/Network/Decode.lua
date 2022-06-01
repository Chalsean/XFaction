local XFG, E, L, V, P, G = unpack(select(2, ...))
local LogCategory = 'NDecode'

-- Reconstruct a Unit object from the message
function XFG:DecodeMessage(inMessage)	
	
	local _Decoded = XFG.Lib.Encode:Decode(inMessage)
	local _Decompressed = XFG.Lib.Compress:DecompressHuffman(_Decoded)
	local _, _MessageData = XFG:Deserialize(_Decompressed)

	local _Message
	if(_MessageData.W ~= nil) then
		_Message = GuildMessage:new()
	else
		_Message = Message:new()
	end	
	_Message:Initialize()
	
	if(_MessageData.A ~= nil) then	_Message:SetKey(_MessageData.A)	end
	--if(_MessageData.To ~= nil) then	_Message:SetTo(_MessageData.To)	end
	if(_MessageData.B ~= nil) then _Message:SetFrom(_MessageData.B)	end	
	if(_MessageData.D ~= nil) then _Message:SetSubject(_MessageData.D) end
	if(_MessageData.E ~= nil) then	_Message:SetType(_MessageData.E) end	
	if(_MessageData.K ~= nil) then	_Message:SetTimeStamp(_MessageData.K) end	

	if(_Message.__name == 'GuildMessage') then
		if(_MessageData.W ~= nil) then _Message:SetFromGUID(_MessageData.W) end
		if(_MessageData.F ~= nil) then _Message:SetFaction(XFG.Factions:GetFaction(_MessageData.F)) end
		if(_MessageData.H ~= nil) then	_Message:SetFlags(_MessageData.H) end
		if(_MessageData.L ~= nil) then	_Message:SetLineID(_MessageData.L) end
		if(_MessageData.S ~= nil) then _Message:SetGuildShortName(_MessageData.S) end
		if(_MessageData.M ~= nil) then	_Message:SetMainName(_MessageData.M) end
	end

	if(_Message:GetSubject() == XFG.Network.Message.Subject.DATA or _Message:GetSubject() == XFG.Network.Message.Subject.LOGIN) then
		local _UnitData = XFG:ExtractTarball(_MessageData)
		_Message:SetData(_UnitData)
	else
		_Message:SetData(_MessageData.Y)
	end

	return _Message
end

function XFG:ExtractTarball(inTarball)
	local _UnitData = Unit:new()
	if(inTarball.C ~= nil) then
		_UnitData:SetCovenant(XFG.Covenants:GetCovenant(inTarball.C))
	end
	_UnitData:SetFaction(XFG.Factions:GetFaction(inTarball.F))
	_UnitData:SetGUID(inTarball.G)
	_UnitData:SetKey(inTarball.G)
	_UnitData:SetGuild(XFG.Guilds:GetGuildByID(inTarball.H))	
	
	local _, _ClassAPIName, _RaceName, _, _, _Name, _RealmAPIName = GetPlayerInfoByGUID(_UnitData:GetGUID())
	_UnitData:SetClass(XFG.Classes:GetClassByAPIName(_ClassAPIName))
	_UnitData:SetRace(XFG.Races:GetRaceByName(_RaceName, _UnitData:GetFaction()))
	_UnitData:SetName(_Name)
	_UnitData:SetUnitName(_Name .. '-' .. _RealmAPIName)
	_RealmName = (_RealmAPIName == 'Area52') and 'Area 52' or 'Proudmoore'
	_UnitData:SetRealm(XFG.Realms:GetRealm(_RealmName))

	_UnitData:Print()

	-- There is no API to query for all guild ranks+names, so have to add them as you see them
	if(inTarball.I ~= nil) then
		if(XFG.Ranks:Contains(inTarball.I) == false) then
			local _NewRank = Rank:new()
			_NewRank:SetKey(inTarball.I)
			_NewRank:SetID(inTarball.I)
			_NewRank:SetName(inTarball.J)
			XFG.Ranks:AddRank(_NewRank)
		end
		_UnitData:SetRank(XFG.Ranks:GetRank(inTarball.I))
	end

	_UnitData:SetLevel(inTarball.L)
	_UnitData:IsMobile(inTarball.M == 1)
	_UnitData:SetNote(inTarball.Q)	
	_UnitData:IsOnline(true)
	if(inTarball.P1 ~= nil) then
		_UnitData:SetProfession1(XFG.Professions:GetProfession(inTarball.P1))
	end
	if(inTarball.P2 ~= nil) then
		_UnitData:SetProfession2(XFG.Professions:GetProfession(inTarball.P2))
	end
	_UnitData:IsRunningAddon(true)
	if(inTarball.S ~= nil) then
		_UnitData:SetSoulbind(XFG.Soulbinds:GetSoulbind(inTarball.S))
	end
	_UnitData:SetTimeStamp(GetServerTime())
	if(inTarball.X ~= nil) then
		_UnitData:SetSpec(XFG.Specs:GetSpec(inTarball.X))
	end
	_UnitData:SetZone(inTarball.Z)

	local _Note = _UnitData:GetNote()
    local _UpperNote = string.upper(_Note)
	if(string.match(_UpperNote, "%[EN?KA?H?%]")) then
		_UnitData:IsAlt(true)
        local _MainName = string.match(_Note, "(%w+)$") 
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
