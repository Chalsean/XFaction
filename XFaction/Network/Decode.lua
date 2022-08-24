local XFG, G = unpack(select(2, ...))
local LogCategory = 'Decode'

local Deflate = XFG.Lib.Deflate
local ServerTime = GetServerTime
local RaiderIO = _G.RaiderIO

local function DeserializeMessage(inObject, inCompressedData)

	local _Decompressed = Deflate:DecompressDeflate(inCompressedData)
	local _, _MessageData = XFG:Deserialize(_Decompressed)
	inObject:Initialize()

	if(_MessageData.K ~= nil) then inObject:SetKey(_MessageData.K)	end
	if(_MessageData.T ~= nil) then inObject:SetTo(_MessageData.T)	end
	if(_MessageData.F ~= nil) then inObject:SetFrom(_MessageData.F)	end
	if(_MessageData.S ~= nil) then inObject:SetSubject(_MessageData.S) end
	if(_MessageData.Y ~= nil) then inObject:SetType(_MessageData.Y) end	
	if(_MessageData.I ~= nil) then inObject:SetTimeStamp(_MessageData.I) end	
	if(_MessageData.A ~= nil) then inObject:SetRemainingTargets(_MessageData.A) end
	if(_MessageData.P ~= nil) then inObject:SetPacketNumber(_MessageData.P) end
	if(_MessageData.Q ~= nil) then inObject:SetTotalPackets(_MessageData.Q) end
	if(_MessageData.V ~= nil) then 
		local _Version = XFG.Versions:Get(_MessageData.V)
		if(_Version == nil) then
			_Version = Version:new()
			_Version:SetKey(_MessageData.V)
			XFG.Versions:Add(_Version)
		end
		inObject:SetVersion(_Version) 
	end

	if(_MessageData.M ~= nil) then inObject:SetMainName(_MessageData.M) end
	if(_MessageData.U ~= nil) then inObject:SetUnitName(_MessageData.U) end
	if(_MessageData.N ~= nil) then 
		inObject:SetName(_MessageData.N) 
	elseif(_MessageData.U ~= nil) then
		inObject:SetName(inObject:GetUnitName()) 
	end
	if(_MessageData.R ~= nil) then
		inObject:SetRealm(XFG.Realms:GetByID(_MessageData.R))
		if(_MessageData.G ~= nil) then
			inObject:SetGuild(XFG.Guilds:GetByRealmGuildName(inObject:GetRealm(), _MessageData.G))
		end
	end		

	-- Leave any UnitData serialized for now
	inObject:SetData(_MessageData.D)
	return inObject
end

function XFG:DeserializeUnitData(inData)
	local _, _DeserializedData = XFG:Deserialize(inData)
	local _UnitData = XFG.Confederate:Pop()
	_UnitData:IsRunningAddon(true)
	if(_DeserializedData.C ~= nil) then
		_UnitData:SetCovenant(XFG.Covenants:Get(_DeserializedData.C))
	end
	_UnitData:SetFaction(XFG.Factions:Get(_DeserializedData.F))
	_UnitData:SetGUID(_DeserializedData.K)
	_UnitData:SetKey(_DeserializedData.K)
	_UnitData:SetClass(XFG.Classes:Get(_DeserializedData.O))
	_UnitData:SetRace(XFG.Races:Get(_DeserializedData.A))
	local _UnitNameParts = string.Split(_DeserializedData.U, '-')
	_UnitData:SetName(_UnitNameParts[1])
	_UnitData:SetUnitName(_DeserializedData.U)
	_UnitData:SetRealm(XFG.Realms:GetByID(_DeserializedData.R))
	_UnitData:SetGuild(XFG.Guilds:GetByRealmGuildName(_UnitData:GetRealm(), _DeserializedData.G))
	if(_DeserializedData.I ~= nil) then _UnitData:SetItemLevel(_DeserializedData.I) end
	_UnitData:SetRank(_DeserializedData.J)
	_UnitData:SetLevel(_DeserializedData.L)
	_UnitData:SetNote(_DeserializedData.N)	
	_UnitData:IsOnline(true)
	if(_DeserializedData.P1 ~= nil) then
		_UnitData:SetProfession1(XFG.Professions:Get(_DeserializedData.P1))
	end
	if(_DeserializedData.P2 ~= nil) then
		_UnitData:SetProfession2(XFG.Professions:Get(_DeserializedData.P2))
	end
	_UnitData:IsRunningAddon(true)
	if(_DeserializedData.S ~= nil) then
		_UnitData:SetSoulbind(XFG.Soulbinds:Get(_DeserializedData.S))
	end
	_UnitData:SetTimeStamp(ServerTime())
	if(_DeserializedData.V ~= nil) then
		_UnitData:SetSpec(XFG.Specs:Get(_DeserializedData.V))
	end

	if(_DeserializedData.D ~= nil and XFG.Zones:ContainsByID(tonumber(_DeserializedData.D))) then
		_UnitData:SetZone(XFG.Zones:GetByID(tonumber(_DeserializedData.D)))
	elseif(_DeserializedData.Z == nil) then
		_UnitData:SetZone(XFG.Zones:Get('?'))
	else
		if(not XFG.Zones:Contains(_DeserializedData.Z)) then
			XFG.Zones:AddZone(_DeserializedData.Z)
		end
		_UnitData:SetZone(XFG.Zones:Get(_DeserializedData.Z))
	end

	if(_DeserializedData.B ~= nil) then _UnitData:SetAchievementPoints(_DeserializedData.B) end
	if(_DeserializedData.Y ~= nil) then _UnitData:SetPvPString(_DeserializedData.Y) end
	if(_DeserializedData.X ~= nil) then 
		local _Version = XFG.Versions:Get(_DeserializedData.X)
		if(_Version == nil) then
			_Version = Version:new()
			_Version:SetKey(_DeserializedData.X)
			XFG.Versions:Add(_Version)
		end
		_UnitData:SetVersion(_Version) 
	end

	local _RaidIO = XFG.RaidIO:Get(_UnitData)
    if(_RaidIO ~= nil) then
        _UnitData:SetRaidIO(_RaidIO)
    end

	return _UnitData
end

function XFG:DecodeMessage(inEncodedMessage)
	local _Decoded = Deflate:DecodeForWoWAddonChannel(inEncodedMessage)
	return DeserializeMessage(XFG.Mailbox.Chat:Pop(), _Decoded)
end

function XFG:DecodeBNetMessage(inEncodedMessage)
	local _Decoded = Deflate:DecodeForPrint(inEncodedMessage)
	return DeserializeMessage(XFG.Mailbox.BNet:Pop(), _Decoded)	
end