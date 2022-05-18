local CON, E, L, V, P, G = unpack(select(2, ...))
local DB = E.db.Confederation
local LogCategory = 'MEncode'
local Initialized = false
local COMPRESS = LibStub:GetLibrary("LibCompress")
local ENCODE = COMPRESS:GetAddonEncodeTable()

local KeyMapping = {
	GI = "GuildIndex",
	N = "Name",
	GN = "GuildName",
	GR = "GuildRank",
	L = "Level",
	C = "Class",
	No = "Note",
	O = "Online",
	S = "Status",
	IM = "IsMobile",
	G = "GUID",
	TS = "TimeStamp",
	T = "Team",
	A = "Alt",
	RA = "RunningAddon",
	U = "Unit",
	RI = "RealmID",
	Z = "Zone"
}

function CON:EncodeMessage(Message)
	local SerializedMessage = CON:Serialize(Message)
	local CompressedMessage = COMPRESS:CompressHuffman(SerializedMessage)
	return ENCODE:Encode(CompressedMessage)
end

function CON:EncodeUnitData(UnitData)

	local MessageUnitData = {}
	for EncodeKey, DecodeKey in pairs (KeyMapping) do
		MessageUnitData[EncodeKey] = UnitData[DecodeKey]
	end

	CON:DataDumper(LogCategory, UnitData)

	MessageUnitData.C = CON:GetClassID(UnitData.Class) and CON:GetClassID(UnitData.Class) or UnitData.Class
	MessageUnitData.R = CON:GetRaceID(UnitData.Race, UnitData.Faction) and CON:GetRaceID(UnitData.Race, UnitData.Faction) or UnitData.Race
	--MessageUnitData.Z = CON:GetZoneID(UnitData.Zone) and CON:GetZoneID(UnitData.Zone) or UnitData.Zone
	MessageUnitData.IM = (UnitData.IsMobile == true) and 1 or 0
	MessageUnitData.Lo = (UnitData.Local == true) and 1 or 0
	MessageUnitData.O = (UnitData.Online == true) and 1 or 0
	MessageUnitData.A = (UnitData.Alt == true) and 1 or 0
	MessageUnitData.RA = (UnitData.RunningAddon == true) and 1 or 0

	if(UnitData.Covenant ~= nil) then
		MessageUnitData.Co = UnitData.Covenant.ID
	end
	if(UnitData.Soulbind ~= nil) then
		MessageUnitData.So = UnitData.Soulbind.ID
	end
	
	if(UnitData.Profession1 ~= nil) then
		MessageUnitData.P1 = UnitData.Profession1.ID
	end
	if(UnitData.Profession2 ~= nil) then
		MessageUnitData.P2 = UnitData.Profession2.ID
	end

	if(UnitData.Spec ~= nil) then
		MessageUnitData.X = UnitData.Spec.ID
	end

	return CON:EncodeMessage(MessageUnitData)
end

function CON:DecodeMessage(Message)	
	local DecodedMessage = ENCODE:Decode(Message)
	local DecompressedMessage = COMPRESS:DecompressHuffman(DecodedMessage)
	return CON:Deserialize(DecompressedMessage)
end

function CON:DecodeUnitData(EncodedUnitData)
	local UnitData = {}
	local ReturnStatus, MessageUnitData = CON:DecodeMessage(EncodedUnitData)
	if(ReturnStatus == false or MessageUnitData == nil) then
		CON:Warn(LogCategory, "Failed to deserialize message")
		return UnitData
	end

	for EncodeKey, DecodeKey in pairs (KeyMapping) do
		UnitData[DecodeKey] = MessageUnitData[EncodeKey]
	end

	UnitData.Class = CON:GetClass(MessageUnitData.C) and CON:GetClass(MessageUnitData.C) or MessageUnitData.C
	UnitData.Race, UnitData.Faction = CON:GetRace(MessageUnitData.R)
	CON:Debug(LogCategory, "realm id [%d]", UnitData.RealmID)
	UnitData.RealmName = CON:GetRealmNameFromID(UnitData.RealmID)
	--UnitData.Zone = CON:GetZoneName(MessageUnitData.Z) and CON:GetZoneName(MessageUnitData.Z) or MessageUnitData.Z
	UnitData.IsMobile = (MessageUnitData.IM == 1) and true or false
	UnitData.Local = (MessageUnitData.Lo == 1) and true or false
	UnitData.Online = (MessageUnitData.O == 1) and true or false
	UnitData.Alt = (MessageUnitData.A == 1) and true or false
	UnitData.RunningAddon = (MessageUnitData.RA == 1) and true or false

	if(MessageUnitData.Co ~= nil) then
		UnitData.Covenant = CON:GetCovenant(MessageUnitData.Co)
	end
	if(MessageUnitData.So ~= nil) then
		UnitData.Soulbind = CON:GetSoulbind(MessageUnitData.So)
	end

	if(MessageUnitData.P1 ~= nil) then
		UnitData.Profession1 = CON:GetProfession(MessageUnitData.P1)
	end
	if(MessageUnitData.P2 ~= nil) then
		UnitData.Profession2 = CON:GetProfession(MessageUnitData.P2)
	end

	if(MessageUnitData.X ~= nil) then
		UnitData.Spec = CON:GetSpec(MessageUnitData.X)
	end

	return UnitData
end