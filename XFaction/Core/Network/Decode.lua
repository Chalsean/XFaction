local XFG, G = unpack(select(2, ...))
local LogCategory = 'NDecode'

function XFG:DecodeMessage(inEncodedMessage)
	local _Decoded = XFG.Lib.Encode:Decode(inEncodedMessage)
	local _Decompressed = XFG.Lib.Compress:DecompressHuffman(_Decoded)
	local _, _MessageData = XFG:Deserialize(_Decompressed)

	local _Message
	-- GCHAT, LOGOUT, ACHIEVEMENT use GuildMessage class
	if(_MessageData.S == XFG.Settings.Network.Message.Subject.GCHAT or
	   _MessageData.S == XFG.Settings.Network.Message.Subject.LOGOUT or
	   _MessageData.S == XFG.Settings.Network.Message.Subject.ACHIEVEMENT) then
		_Message = GuildMessage:new()
	else
	-- DATA, LOGIN, LINKS use Message class
		_Message = Message:new()
	end	
	_Message:Initialize()
	
	if(_MessageData.K ~= nil) then	_Message:SetKey(_MessageData.K)	end
	if(_MessageData.T ~= nil) then	_Message:SetTo(_MessageData.T)	end
	if(_MessageData.F ~= nil) then _Message:SetFrom(_MessageData.F)	end	
	if(_MessageData.S ~= nil) then _Message:SetSubject(_MessageData.S) end
	if(_MessageData.Y ~= nil) then	_Message:SetType(_MessageData.Y) end	
	if(_MessageData.I ~= nil) then	_Message:SetTimeStamp(_MessageData.I) end	
	if(_MessageData.A ~= nil) then _Message:SetRemainingTargets(_MessageData.A) end
	if(_MessageData.P ~= nil) then _Message:SetPacketNumber(_MessageData.P) end
	if(_MessageData.Q ~= nil) then _Message:SetTotalPackets(_MessageData.Q) end
	if(_MessageData.V ~= nil) then _Message:SetVersion(_MessageData.V) end

	if(_Message.__name == 'GuildMessage') then
		if(_MessageData.M ~= nil) then	_Message:SetMainName(_MessageData.M) end
		if(_MessageData.U ~= nil) then	_Message:SetUnitName(_MessageData.U) end
		if(_MessageData.N ~= nil) then	_Message:SetName(_MessageData.N) else _Message:SetName(_Message:GetUnitName()) end		
		if(_MessageData.R ~= nil) then
			_Message:SetRealm(XFG.Realms:GetRealmByID(_MessageData.R))
			if(_MessageData.G ~= nil) then
				_Message:SetGuild(XFG.Guilds:GetGuildByRealmGuildName(_Message:GetRealm(), _MessageData.G))
			end
		end		
	end

	-- Leave any UnitData serialized for now
	_Message:SetData(_MessageData.D)
	return _Message
end

function XFG:DeserializeUnitData(inData)
	local _, _DeserializedData = XFG:Deserialize(inData)
	local _UnitData = Unit:new()
	_UnitData:IsRunningAddon(true)
	if(_DeserializedData.C ~= nil) then
		_UnitData:SetCovenant(XFG.Covenants:GetCovenant(_DeserializedData.C))
	end
	_UnitData:SetFaction(XFG.Factions:GetFaction(_DeserializedData.F))
	_UnitData:SetGUID(_DeserializedData.K)
	_UnitData:SetKey(_DeserializedData.K)
	_UnitData:SetClass(XFG.Classes:GetClass(_DeserializedData.O))
	_UnitData:SetRace(XFG.Races:GetRace(_DeserializedData.A))
	local _UnitNameParts = string.Split(_DeserializedData.U, '-')
	_UnitData:SetName(_UnitNameParts[1])
	_UnitData:SetUnitName(_DeserializedData.U)
	_UnitData:SetRealm(XFG.Realms:GetRealmByID(_DeserializedData.R))
	_UnitData:SetGuild(XFG.Guilds:GetGuildByRealmGuildName(_UnitData:GetRealm(), _DeserializedData.G))
	_UnitData:SetRank(_DeserializedData.J)
	_UnitData:SetLevel(_DeserializedData.L)
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
	local _EpochTime = GetServerTime()
	_UnitData:SetTimeStamp(_EpochTime)
	if(_DeserializedData.V ~= nil) then
		_UnitData:SetSpec(XFG.Specs:GetSpec(_DeserializedData.V))
	end
	_UnitData:SetZone(_DeserializedData.Z)

	if(_DeserializedData.B ~= nil) then _UnitData:SetAchievementPoints(_DeserializedData.B) end
	if(_DeserializedData.Y ~= nil) then _UnitData:SetPvPString(_DeserializedData.Y) end
	if(_DeserializedData.X ~= nil) then _UnitData:SetVersion(_DeserializedData.X) end

	-- If RaiderIO is installed, grab raid/mythic
    local RaiderIO = _G.RaiderIO
    if(RaiderIO) then
        local _RaiderIO = RaiderIO.GetProfile(_UnitData:GetName(), _UnitData:GetRealm():GetName(), _UnitData:GetFaction():GetID())
        -- Raid
        if(_RaiderIO and _RaiderIO.raidProfile) then
            local _TopProgress = _RaiderIO.raidProfile.sortedProgress[1]
            if(_TopProgress.isProgressPrev == nil or _TopProgress.IsProgressPrev == false) then
                _UnitData:SetRaidProgress(_TopProgress.progress.progressCount, _TopProgress.progress.raid.bossCount, _TopProgress.progress.difficulty)
            end
        end
        -- M+
        if(_RaiderIO and _RaiderIO.mythicKeystoneProfile) then
            if(_RaiderIO.mythicKeystoneProfile.mainCurrentScore > 0) then
                _UnitData:SetDungeonScore(_RaiderIO.mythicKeystoneProfile.mainCurrentScore)
			elseif(_RaiderIO.mythicKeystoneProfile.currentScore > 0) then
                _UnitData:SetDungeonScore(_RaiderIO.mythicKeystoneProfile.currentScore)
            end
        end
    end

	return _UnitData
end
