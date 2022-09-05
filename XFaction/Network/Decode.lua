local XFG, G = unpack(select(2, ...))
local ObjectName = 'Decode'
local Deflate = XFG.Lib.Deflate
local ServerTime = GetServerTime
local RaiderIO = _G.RaiderIO

local function DeserializeMessage(inObject, inCompressedData)
	local decompressed = Deflate:DecompressDeflate(inCompressedData)
	local _, messageData = unpickle(decompressed)
	inObject:Initialize()

	if(messageData.K ~= nil) then inObject:SetKey(messageData.K)	end
	if(messageData.T ~= nil) then inObject:SetTo(messageData.T)	end
	if(messageData.F ~= nil) then inObject:SetFrom(messageData.F)	end
	if(messageData.S ~= nil) then inObject:SetSubject(messageData.S) end
	if(messageData.Y ~= nil) then inObject:SetType(messageData.Y) end	
	if(messageData.I ~= nil) then inObject:SetTimeStamp(messageData.I) end	
	if(messageData.A ~= nil) then inObject:SetRemainingTargets(messageData.A) end
	if(messageData.P ~= nil) then inObject:SetPacketNumber(messageData.P) end
	if(messageData.Q ~= nil) then inObject:SetTotalPackets(messageData.Q) end
	if(messageData.V ~= nil) then 
		local version = XFG.Versions:Get(messageData.V)
		if(version == nil) then
			version = Version:new()
			version:SetKey(messageData.V)
			XFG.Versions:Add(version)
		end
		inObject:SetVersion(version)
	end

	if(messageData.M ~= nil) then inObject:SetMainName(messageData.M) end
	if(messageData.U ~= nil) then inObject:SetUnitName(messageData.U) end
	if(messageData.N ~= nil) then 
		inObject:SetName(messageData.N) 
	elseif(messageData.U ~= nil) then
		inObject:SetName(_Message:GetUnitName()) 
	end
	if(messageData.R ~= nil) then
		inObject:SetRealm(XFG.Realms:GetByID(messageData.R))
		if(messageData.G ~= nil) then
			inObject:SetGuild(XFG.Guilds:GetByRealmGuildName(inObject:GetRealm(), messageData.G))
		end
	end		

	-- Leave any UnitData serialized for now
	inObject:SetData(messageData.D)
	return inObject
end

function XFG:DeserializeUnitData(inData)
	local _, deserializedData = XFG:Deserialize(inData)
	local unit = XFG.Confederate:Pop()
	unit:IsRunningAddon(true)
	unit:SetRace(XFG.Races:Get(deserializedData.A))
	if(deserializedData.B ~= nil) then unit:SetAchievementPoints(deserializedData.B) end
	unit:SetFaction(XFG.Factions:Get(deserializedData.F))
	unit:SetGUID(deserializedData.K)
	unit:SetKey(deserializedData.K)
	unit:SetClass(XFG.Classes:Get(deserializedData.O))
	local unitNameParts = string.Split(deserializedData.U, '-')
	unit:SetName(unitNameParts[1])
	unit:SetUnitName(deserializedData.U)
	unit:SetRealm(XFG.Realms:GetByID(deserializedData.R))
	unit:SetGuild(XFG.Guilds:GetByRealmGuildName(unit:GetRealm(), deserializedData.G))
	if(deserializedData.I ~= nil) then unit:SetItemLevel(deserializedData.I) end
	unit:SetRank(deserializedData.J)
	unit:SetLevel(deserializedData.L)
	unit:SetNote(deserializedData.N)	
	unit:IsOnline(true)
	if(deserializedData.P1 ~= nil) then
		unit:SetProfession1(XFG.Professions:Get(deserializedData.P1))
	end
	if(deserializedData.P2 ~= nil) then
		unit:SetProfession2(XFG.Professions:Get(deserializedData.P2))
	end
	unit:IsRunningAddon(true)
	unit:SetTimeStamp(ServerTime())
	if(deserializedData.V ~= nil) then
		unit:SetSpec(XFG.Specs:Get(deserializedData.V))
	end

	if(deserializedData.D ~= nil and XFG.Zones:ContainsByID(tonumber(deserializedData.D))) then
		unit:SetZone(XFG.Zones:GetByID(tonumber(deserializedData.D)))
	elseif(deserializedData.Z == nil) then
		unit:SetZone(XFG.Zones:Get('?'))
	else
		if(not XFG.Zones:Contains(deserializedData.Z)) then
			XFG.Zones:AddZone(deserializedData.Z)
		end
		unit:SetZone(XFG.Zones:Get(deserializedData.Z))
	end

	if(deserializedData.Y ~= nil) then unit:SetPvPString(deserializedData.Y) end
	if(deserializedData.X ~= nil) then 
		local version = XFG.Versions:Get(deserializedData.X)
		if(version == nil) then
			version = version:new()
			version:SetKey(deserializedData.X)
			XFG.Versions:Add(version)
		end
		unit:SetVersion(version) 
	end

	local raidIO = XFG.RaidIO:Get(unit)
    if(raidIO ~= nil) then
        unit:SetRaidIO(raidIO)
    end

	return unit
end

function XFG:DecodeChatMessage(inEncodedMessage)
	local decoded = Deflate:DecodeForWoWAddonChannel(inEncodedMessage)
	return DeserializeMessage(XFG.Mailbox.Chat:Pop(), decoded)
end

function XFG:DecodeBNetMessage(inEncodedMessage)
	local decoded = Deflate:DecodeForPrint(inEncodedMessage)
	return DeserializeMessage(XFG.Mailbox.BNet:Pop(), decoded)
end