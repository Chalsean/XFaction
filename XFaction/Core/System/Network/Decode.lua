local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Decode'
local Deflate = XF.Lib.Deflate
local ServerTime = GetServerTime
local RaiderIO = _G.RaiderIO

local function DeserializeMessage(inObject, inCompressedData)
	local decompressed = Deflate:DecompressDeflate(inCompressedData)
	local messageData = unpickle(decompressed)
	inObject:Initialize()

	if(messageData.K ~= nil) then inObject:Key(messageData.K)	end
	if(messageData.F ~= nil) then inObject:From(messageData.F)	end
	if(messageData.S ~= nil) then inObject:Subject(messageData.S) end
	if(messageData.Y ~= nil) then inObject:Type(messageData.Y) end	
	if(messageData.I ~= nil) then inObject:TimeStamp(messageData.I) end	
	if(messageData.A ~= nil) then inObject:SetRemainingTargets(messageData.A) end
	if(messageData.P ~= nil) then inObject:PacketNumber(messageData.P) end
	if(messageData.Q ~= nil) then inObject:TotalPackets(messageData.Q) end
	if(messageData.V ~= nil) then 
		local version = XFO.Versions:Get(messageData.V)
		if(version == nil) then
			version = XFC.Version:new()
			version:Key(messageData.V)
			XFO.Versions:Add(version)
		end
		inObject:SetVersion(version)
	end

	if(messageData.M ~= nil) then inObject:SetMainName(messageData.M) end
	if(messageData.U ~= nil) then inObject:UnitName(messageData.U) end
	if(messageData.N ~= nil) then 
		inObject:Name(messageData.N) 
	elseif(messageData.U ~= nil) then
		inObject:Name(inObject:UnitName())
	end
	if(messageData.H ~= nil and XFO.Guilds:Contains(messageData.H)) then
		inObject:SetGuild(XFO.Guilds:Get(messageData.H))
	elseif(messageData.R ~= nil and messageData.G ~= nil) then
		-- Remove this deprecated logic after everyone on 4.4
		inObject:SetGuild(XFO.Guilds:GetByRealmGuildName(XFO.Realms:GetByID(messageData.R), messageData.G))
	end		

	if(messageData.W ~= nil) then inObject:SetFaction(XFO.Factions:Get(messageData.W)) end

	-- Leave any UnitData serialized for now
	inObject:Data(messageData.D)
	return inObject
end

function XF:DeserializeUnitData(inData)
	local deserializedData = unpickle(inData)
	local unit = XFO.Confederate:Pop()
	unit:IsRunningAddon(true)
	unit:Race(XFO.Races:Get(deserializedData.A))
	if(deserializedData.B ~= nil) then unit:SetAchievementPoints(deserializedData.B) end
	if(deserializedData.C ~= nil) then unit:ID(tonumber(deserializedData.C)) end
	if(deserializedData.E ~= nil) then 
		unit:Presence(tonumber(deserializedData.E)) 
	else
		unit:Presence(Enum.ClubMemberPresence.Online)
	end
	unit:SetFaction(XFO.Factions:Get(deserializedData.F))
	unit:GUID(deserializedData.K)
	unit:Key(deserializedData.K)
	unit:SetClass(XFO.Classes:Get(deserializedData.O))
	local unitNameParts = string.Split(deserializedData.U, '-')
	unit:Name(unitNameParts[1])
	unit:UnitName(deserializedData.U)
	if(deserializedData.H ~= nil and XFO.Guilds:Contains(deserializedData.H)) then
		unit:SetGuild(XFO.Guilds:Get(deserializedData.H))
	else
		-- Remove this deprecated logic after everyone on 4.4
		unit:SetGuild(XFO.Guilds:GetByRealmGuildName(XFO.Realms:GetByID(deserializedData.R), deserializedData.G))
	end
	if(deserializedData.I ~= nil) then unit:SetItemLevel(deserializedData.I) end
	unit:Rank(deserializedData.J)
	unit:Level(deserializedData.L)
	if(deserializedData.M ~= nil) then
		local key = XFC.MythicKey:new(); key:Initialize()
		key:Deserialize(deserializedData.M)
		unit:SetMythicKey(key)
	end
	unit:SetNote(deserializedData.N)	
	unit:IsOnline(true)
	if(deserializedData.P1 ~= nil) then
		unit:SetProfession1(XFO.Professions:Get(deserializedData.P1))
	end
	if(deserializedData.P2 ~= nil) then
		unit:SetProfession2(XFO.Professions:Get(deserializedData.P2))
	end
	unit:IsRunningAddon(true)
	unit:TimeStamp(ServerTime())
	if(deserializedData.V ~= nil) then
		unit:SetSpec(XFO.Specs:Get(deserializedData.V))
	end

	if(deserializedData.D ~= nil and XFO.Zones:Contains(tonumber(deserializedData.D))) then
		unit:Zone(XFO.Zones:Get(tonumber(deserializedData.D)))
	elseif(deserializedData.Z == nil) then
		unit:Zone(XFO.Zones:Get('?'))
	else
		if(not XFO.Zones:Contains(deserializedData.Z)) then
			XFO.Zones:Add(deserializedData.Z)
		end
		unit:Zone(XFO.Zones:Get(deserializedData.Z))
	end

	if(deserializedData.Y ~= nil) then unit:SetPvPString(deserializedData.Y) end
	if(deserializedData.X ~= nil) then 
		local version = XFO.Versions:Get(deserializedData.X)
		if(version == nil) then
			version = XFC.Version:new()
			version:Key(deserializedData.X)
			XFO.Versions:Add(version)
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
	return DeserializeMessage(XFO.Mailbox:Pop(), decoded)
end

function XF:DecodeBNetMessage(inEncodedMessage)
	local decoded = Deflate:DecodeForPrint(inEncodedMessage)
	return DeserializeMessage(XFO.Mailbox:Pop(), decoded)
end