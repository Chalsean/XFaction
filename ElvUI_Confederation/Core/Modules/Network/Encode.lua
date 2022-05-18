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
	Z = "Zone",
	No = "Note",
	O = "Online",
	S = "Status",
	IM = "IsMobile",
	G = "GUID",
	R = "Race",
	TS = "TimeStamp",
	T = "Team",
	A = "Alt",
	RA = "RunningAddon",
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

	MessageUnitData.C = CON:GetClassID(UnitData.Class)
	MessageUnitData.R = CON:GetRaceID(UnitData.Race, UnitData.Faction)
	MessageUnitData.RI = CON:GetRealmID(UnitData.RealmName)
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

	UnitData.Class = CON:GetClass(MessageUnitData.C)
	UnitData.Race, UnitData.Faction = CON:GetRace(MessageUnitData.R)
	UnitData.RealmName = CON:GetRealmName(MessageUnitData.RI)
	UnitData.Unit = UnitData.Name .. "-" .. UnitData.RealmName
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

	return UnitData
end