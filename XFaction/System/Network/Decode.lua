local XF, G = unpack(select(2, ...))
local ObjectName = 'Decode'
local Deflate = XF.Lib.Deflate
local ServerTime = GetServerTime
local RaiderIO = _G.RaiderIO

local function DeserializeMessage(inObject, inCompressedData)
	local decompressed = Deflate:DecompressDeflate(inCompressedData)
	local messageData = unpickle(decompressed)
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
		local version = XF.Versions:Get(messageData.V)
		if(version == nil) then
			version = Version:new()
			version:SetKey(messageData.V)
			XF.Versions:Add(version)
		end
		inObject:SetVersion(version)
	end

	if(messageData.M ~= nil) then inObject:SetMainName(messageData.M) end
	if(messageData.U ~= nil) then inObject:SetUnitName(messageData.U) end
	if(messageData.N ~= nil) then 
		inObject:SetName(messageData.N) 
	elseif(messageData.U ~= nil) then
		inObject:SetName(inObject:GetUnitName())
	end
	if(messageData.H ~= nil and XF.Guilds:Contains(messageData.H)) then
		inObject:SetGuild(XF.Guilds:Get(messageData.H))
	elseif(messageData.R ~= nil and messageData.G ~= nil) then
		-- Remove this deprecated logic after everyone on 4.4
		inObject:SetGuild(XF.Guilds:GetByRealmGuildName(XF.Realms:GetByID(messageData.R), messageData.G))
	end		

	-- Leave any UnitData serialized for now
	inObject:SetData(messageData.D)
	return inObject
end

function XF:DeserializeUnitData(inData)
	local deserializedData = unpickle(inData)
	local unit = XF.Confederate:Pop()
	unit:IsRunningAddon(true)
	unit:SetRace(XF.Races:Get(deserializedData.A))
	if(deserializedData.B ~= nil) then unit:SetAchievementPoints(deserializedData.B) end
	if(deserializedData.C ~= nil) then unit:SetID(tonumber(deserializedData.C)) end
	if(deserializedData.E ~= nil) then 
		unit:SetPresence(tonumber(deserializedData.E)) 
	else
		unit:SetPresence(Enum.ClubMemberPresence.Online)
	end
	unit:SetFaction(XF.Factions:Get(deserializedData.F))
	unit:SetGUID(deserializedData.K)
	unit:SetKey(deserializedData.K)
	unit:SetClass(XF.Classes:Get(deserializedData.O))
	local unitNameParts = string.Split(deserializedData.U, '-')
	unit:SetName(unitNameParts[1])
	unit:SetUnitName(deserializedData.U)
	if(deserializedData.H ~= nil and XF.Guilds:Contains(deserializedData.H)) then
		unit:SetGuild(XF.Guilds:Get(deserializedData.H))
	else
		-- Remove this deprecated logic after everyone on 4.4
		unit:SetGuild(XF.Guilds:GetByRealmGuildName(XF.Realms:GetByID(deserializedData.R), deserializedData.G))
	end
	if(deserializedData.I ~= nil) then unit:SetItemLevel(deserializedData.I) end
	unit:SetRank(deserializedData.J)
	unit:SetLevel(deserializedData.L)
	unit:SetNote(deserializedData.N)	
	unit:IsOnline(true)
	if(deserializedData.P1 ~= nil) then
		unit:SetProfession1(XF.Professions:Get(deserializedData.P1))
	end
	if(deserializedData.P2 ~= nil) then
		unit:SetProfession2(XF.Professions:Get(deserializedData.P2))
	end
	unit:IsRunningAddon(true)
	unit:SetTimeStamp(ServerTime())
	if(deserializedData.V ~= nil) then
		unit:SetSpec(XF.Specs:Get(deserializedData.V))
	end

	if(deserializedData.D ~= nil and XF.Zones:ContainsByID(tonumber(deserializedData.D))) then
		unit:SetZone(XF.Zones:GetByID(tonumber(deserializedData.D)))
	elseif(deserializedData.Z == nil) then
		unit:SetZone(XF.Zones:Get('?'))
	else
		if(not XF.Zones:Contains(deserializedData.Z)) then
			XF.Zones:AddZone(deserializedData.Z)
		end
		unit:SetZone(XF.Zones:Get(deserializedData.Z))
	end

	if(deserializedData.Y ~= nil) then unit:SetPvPString(deserializedData.Y) end
	if(deserializedData.X ~= nil) then 
		local version = XF.Versions:Get(deserializedData.X)
		if(version == nil) then
			version = Version:new()
			version:SetKey(deserializedData.X)
			XF.Versions:Add(version)
		end
		unit:SetVersion(version) 
	end

	local raiderIO = XF.Addons.RaiderIO:Get(unit)
    if(raiderIO ~= nil) then
        unit:SetRaiderIO(raiderIO)
    end

	return unit
end

function XF:DecodeChatMessage(inEncodedMessage)
	local decoded = Deflate:DecodeForWoWAddonChannel(inEncodedMessage)
	return DeserializeMessage(XF.Mailbox.Chat:Pop(), decoded)
end

function XF:DecodeBNetMessage(inEncodedMessage)
	local decoded = Deflate:DecodeForPrint(inEncodedMessage)
	return DeserializeMessage(XF.Mailbox.BNet:Pop(), decoded)
end