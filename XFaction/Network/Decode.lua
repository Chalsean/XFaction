local XFG, G = unpack(select(2, ...))
local LogCategory = 'Decode'

local Deflate = XFG.Lib.Deflate
local ServerTime = GetServerTime
local RaiderIO = _G.RaiderIO

local function DeserializeMessage(inSerializedMessage)
	local _, _MessageData = XFG:Deserialize(inSerializedMessage)
	local _Message
	-- GCHAT, LOGOUT, ACHIEVEMENT use GuildMessage class
	if(_MessageData.S == XFG.Settings.Network.Message.Subject.GCHAT or
	   _MessageData.S == XFG.Settings.Network.Message.Subject.LOGOUT or
	   _MessageData.S == XFG.Settings.Network.Message.Subject.ACHIEVEMENT) then
		_Message = XFG.Factories.GuildMessage:CheckOut()
	else
	-- DATA, LOGIN, LINKS use Message class
		_Message = XFG.Factories.Message:CheckOut()
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
	if(_MessageData.V ~= nil) then 
		local _Version = XFG.Versions:GetObject(_MessageData.V)
		if(_Version == nil) then
			_Version = Version:new()
			_Version:SetKey(_MessageData.V)
			XFG.Versions:AddObject(_Version)
		end
		_Message:SetVersion(_Version) 
	end

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
	local _UnitData = XFG.Factories.Unit:CheckOut()
	_UnitData:IsRunningAddon(true)
	if(_DeserializedData.C ~= nil) then
		_UnitData:SetCovenant(XFG.Covenants:GetObject(_DeserializedData.C))
	end
	_UnitData:SetFaction(XFG.Factions:GetObject(_DeserializedData.F))
	_UnitData:SetGUID(_DeserializedData.K)
	_UnitData:SetKey(_DeserializedData.K)
	_UnitData:SetClass(XFG.Classes:GetObject(_DeserializedData.O))
	_UnitData:SetRace(XFG.Races:GetObject(_DeserializedData.A))
	local _UnitNameParts = string.Split(_DeserializedData.U, '-')
	_UnitData:SetName(_UnitNameParts[1])
	_UnitData:SetUnitName(_DeserializedData.U)
	_UnitData:SetRealm(XFG.Realms:GetRealmByID(_DeserializedData.R))
	_UnitData:SetGuild(XFG.Guilds:GetGuildByRealmGuildName(_UnitData:GetRealm(), _DeserializedData.G))
	if(_DeserializedData.I ~= nil) then _UnitData:SetItemLevel(_DeserializedData.I) end
	_UnitData:SetRank(_DeserializedData.J)
	_UnitData:SetLevel(_DeserializedData.L)
	_UnitData:SetNote(_DeserializedData.N)	
	_UnitData:IsOnline(true)
	if(_DeserializedData.P1 ~= nil) then
		_UnitData:SetProfession1(XFG.Professions:GetObject(_DeserializedData.P1))
	end
	if(_DeserializedData.P2 ~= nil) then
		_UnitData:SetProfession2(XFG.Professions:GetObject(_DeserializedData.P2))
	end
	_UnitData:IsRunningAddon(true)
	if(_DeserializedData.S ~= nil) then
		_UnitData:SetSoulbind(XFG.Soulbinds:GetObject(_DeserializedData.S))
	end
	_UnitData:SetTimeStamp(ServerTime())
	if(_DeserializedData.V ~= nil) then
		_UnitData:SetSpec(XFG.Specs:GetObject(_DeserializedData.V))
	end

	if(_DeserializedData.D ~= nil and XFG.Zones:ContainsByID(tonumber(_DeserializedData.D))) then
		_UnitData:SetZone(XFG.Zones:GetZoneByID(tonumber(_DeserializedData.D)))
	elseif(_DeserializedData.Z == nil) then
		_UnitData:SetZone(XFG.Zones:GetObject('?'))
	else
		if(not XFG.Zones:Contains(_DeserializedData.Z)) then
			XFG.Zones:AddZone(_DeserializedData.Z)
		end
		_UnitData:SetZone(XFG.Zones:GetObject(_DeserializedData.Z))
	end

	if(_DeserializedData.B ~= nil) then _UnitData:SetAchievementPoints(_DeserializedData.B) end
	if(_DeserializedData.Y ~= nil) then _UnitData:SetPvPString(_DeserializedData.Y) end
	if(_DeserializedData.X ~= nil) then 
		local _Version = XFG.Versions:GetObject(_DeserializedData.X)
		if(_Version == nil) then
			_Version = Version:new()
			_Version:SetKey(_DeserializedData.X)
			XFG.Versions:AddObject(_Version)
		end
		_UnitData:SetVersion(_Version) 
	end

	local _RaidIO = XFG.RaidIO:GetRaidIO(_UnitData)
    if(_RaidIO ~= nil) then
        _UnitData:SetRaidIO(_RaidIO)
    end

	return _UnitData
end

function XFG:DecodeMessage(inEncodedMessage)
	local _Decoded = Deflate:DecodeForWoWAddonChannel(inEncodedMessage)
	local _Decompressed = Deflate:DecompressDeflate(_Decoded)	
	return DeserializeMessage(_Decompressed)
end

function XFG:DecodeBNetMessage(inEncodedMessage)
	local _Decoded = Deflate:DecodeForPrint(inEncodedMessage)
	local _Decompressed = Deflate:DecompressDeflate(_Decoded)	
	return DeserializeMessage(_Decompressed)
end