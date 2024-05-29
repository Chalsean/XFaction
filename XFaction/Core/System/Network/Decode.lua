local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Decode'
local Deflate = XF.Lib.Deflate
local ServerTime = GetServerTime
local RaiderIO = _G.RaiderIO

local function DeserializeMessage(inObject, inCompressedData)
	local decompressed = nil
	for i = 1, 10 do
		if(decompressed == nil) then
			decompressed = Deflate:DecompressDeflate(inCompressedData)
		end
	end

	local messageData = unpickle(decompressed)
	inObject:Initialize()

	if(messageData.K ~= nil) then inObject:Key(messageData.K)	end
	if(messageData.T ~= nil) then inObject:SetTo(messageData.T)	end
	if(messageData.F ~= nil) then inObject:SetFrom(messageData.F)	end
	if(messageData.S ~= nil) then inObject:SetSubject(messageData.S) end
	if(messageData.Y ~= nil) then inObject:SetType(messageData.Y) end	
	if(messageData.I ~= nil) then inObject:SetTimeStamp(messageData.I) end	
	if(messageData.A ~= nil) then inObject:SetRemainingTargets(messageData.A) end
	if(messageData.P ~= nil) then inObject:SetPacketNumber(messageData.P) end
	if(messageData.Q ~= nil) then inObject:SetTotalPackets(messageData.Q) end
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
	if(messageData.U ~= nil) then inObject:SetUnitName(messageData.U) end
	if(messageData.N ~= nil) then 
		inObject:Name(messageData.N) 
	elseif(messageData.U ~= nil) then
		inObject:Name(inObject:GetUnitName())
	end
	if(messageData.H ~= nil and XFO.Guilds:Contains(messageData.H)) then
		inObject:SetGuild(XFO.Guilds:Get(messageData.H))
	end		

	if(messageData.W ~= nil) then inObject:SetFaction(XFO.Factions:Get(messageData.W)) end
	if(messageData.X ~= nil) then
		local unit = XFO.Confederate:Pop()
		try(function()
			unit:Deserialize(messageData.X)
			XFO.Confederate:Add(unit)
			inObject:FromUnit(unit)
		end).
		catch(function(err)
			XF:Error(ObjectName, err)
			XFO.Confederate:Push(unit)
		end)
	end

	inObject:SetData(messageData.D)
	return inObject
end

function XF:DeserializeUnitData(inData)
	local deserializedData = unpickle(inData)
	local unit = XFO.Confederate:Pop()
	unit:IsRunningAddon(true)
	unit:Race(XFO.Races:Get(deserializedData.A))
	if(deserializedData.B ~= nil) then unit:AchievementPoints(deserializedData.B) end
	if(deserializedData.C ~= nil) then unit:ID(tonumber(deserializedData.C)) end
	if(deserializedData.E ~= nil) then 
		unit:Presence(tonumber(deserializedData.E)) 
	else
		unit:Presence(Enum.ClubMemberPresence.Online)
	end
	--unit:Faction(XFO.Factions:Get(deserializedData.F))
	unit:GUID(deserializedData.K)
	unit:Key(deserializedData.K)
	--unit:SetClass(XFO.Classes:Get(deserializedData.O))
	local unitNameParts = string.Split(deserializedData.U, '-')
	unit:Name(unitNameParts[1])
	--unit:SetUnitName(deserializedData.U)
	if(deserializedData.H ~= nil and XFO.Guilds:Contains(deserializedData.H)) then
		unit:Guild(XFO.Guilds:Get(deserializedData.H))
		unit:Realm(unit:Guild():Realm())
	end
	if(deserializedData.I ~= nil) then unit:ItemLevel(deserializedData.I) end
	unit:Rank(deserializedData.J)
	unit:Level(deserializedData.L)
	if(deserializedData.M ~= nil) then
		local key = XFC.MythicKey:new(); key:Initialize()
		key:Deserialize(deserializedData.M)
		unit:MythicKey(key)
	end
	unit:Note(deserializedData.N)	
	unit:IsOnline(true)
	if(deserializedData.P1 ~= nil) then
		unit:Profession1(XFO.Professions:Get(tonumber(deserializedData.P1)))
	end
	if(deserializedData.P2 ~= nil) then
		unit:Profession2(XFO.Professions:Get(tonumber(deserializedData.P2)))
	end
	unit:IsRunningAddon(true)
	unit:TimeStamp(ServerTime())
	if(deserializedData.V ~= nil) then
		unit:Spec(XFO.Specs:Get(deserializedData.V))
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

	if(deserializedData.Y ~= nil) then unit:PvP(deserializedData.Y) end
	if(deserializedData.X ~= nil) then 
		local version = XFO.Versions:Get(deserializedData.X)
		if(version == nil) then
			version = XFC.Version:new()
			version:Key(deserializedData.X)
			XFO.Versions:Add(version)
		end
		unit:Version(version) 
	end

	local raiderIO = XF.Addons.RaiderIO:Get(unit)
    if(raiderIO ~= nil) then
        unit:RaiderIO(raiderIO)
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