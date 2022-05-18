local CON, E, L, V, P, G = unpack(select(2, ...))
local DB = E.db.Confederation
local LogCategory = 'MMessage'
local Initialized = false
local COMM = LibStub("AceAddon-3.0"):NewAddon(CON.Category, "AceComm-3.0")
CON.Comm = COMM

local function ProcessDataMessage(Message, Sender)

	local UnitData = CON:DecodeUnitData(Message)
	CON:DataDumper(LogCategory, UnitData)

    -- Ignore if it's your own message (unfortunately there's no realm name attached)
	if(DB.Data.Player.Name == Sender) then
		return
	end

	-- It's about you, sender needs current information
	if(UnitData.Unit == DB.Data.PlayerUnit) then
		CON:WhisperUnitData(DB.Data.Player, Sender)
		return
	end

	-- Process if coming from the Unit themselves
	if(UnitData.Name == Sender and UnitData.RealmName == DB.Data.RealmName) then
		if(CON:AddGuildMember(UnitData)) then
			CON:Info(LogCategory, format("Updated unit [%s] information based on message received", UnitData.Unit))
		end
		return
	end

	-- Process if you've never heard of this unit before
	if(DB.Data.Guild.Roster[UnitData.Unit] == nil) then
		if(UnitData.Online == true and CON:AddGuildMember(UnitData)) then
			CON:Info(LogCategory, format("Updated unit [%s] information based on message received", UnitData.Unit))
		elseif(UnitData.Online == false and CON:RemoveGuildMember(UnitData)) then
			CON:Info(LogCategory, format("Removed unit [%s] information based on message received", UnitData.Unit))
		end
		return
	end

	-- Ignore if Unit is known to be running addon and it's not coming from Unit themselves
	if(UnitData.Online == true and DB.Data.Guild.Roster[UnitData.Unit].RunningAddon == true) then
		return
	end

	-- Ignore if same guild and unit is not running addon
	-- Your scans will contain the same information
	if(UnitData.GuildName == DB.Data.Player.GuildName and DB.Data.Guild.Roster[UnitData.Unit].RunningAddon == false) then
		return
	end

	-- If passed all above checks, process message
	if(UnitData.Online == true and CON:AddGuildMember(UnitData)) then
		CON:Info(LogCategory, format("Updated unit [%s] information based on message received", UnitData.Unit))
	elseif(UnitData.Online == false and CON:RemoveGuildMember(UnitData)) then
		CON:Info(LogCategory, format("Removed unit [%s] information based on message received", UnitData.Unit))
	end
end

local function ProcessStatusMessage(RealmName, Sender)
	-- Ignore your own messages
	if(DB.Data.RealmName == RealmName and DB.Data.Player.Name == Sender) then
		return
	end

	CON:Info(LogCategory, "Request for current status from %s-%s", Sender, RealmName)
	-- Whisper if on same server
	if(DB.Data.RealmName == RealmName) then		
		CON:WhisperUnitData(DB.Data.Player, Sender)
	-- Otherwise broadcast
	else
		CON:BroadcastUnitData(DB.Data.Player)
	end
end

function COMM:OnCommReceived(MessageType, Message, Distribution, Sender)
	
	CON:Debug(LogCategory, "Message received [%s][%s][%s]", MessageType, Distribution, Sender)

	if(MessageType == CON.Network.Message.UnitData) then
		ProcessDataMessage(Message, Sender)
	elseif(MessageType == CON.Network.Message.Status) then
		ProcessStatusMessage(Message, Sender)
	end	
end

function COMM:Initialize()
	if(Initialized == false) then
		for Key, Value in pairs (CON.Network.Message) do
			CON:Info(LogCategory, format("Registering to receive [%s] messages", CON.Network.Message[Key]))
			self:RegisterComm(CON.Network.Message[Key])
		end
		Initialized = true
	end
end

local function SendCommunication(MessageType, Message, Medium, ChannelID)
	CON:Debug(LogCategory, format("Sending communication type [%s] length [%d] medium [%s]", MessageType, string.len(Message), Medium))
	COMM:SendCommMessage(MessageType, Message, Medium, ChannelID)
end

function CON:BroadcastUnitData(UnitData)
	COMM:Initialize()
	CON:Info(LogCategory, format("Broadcasting data for [%s] on channel [%d]", UnitData.Unit, CON.Network.ChannelID))
	local MessageData = CON:EncodeUnitData(UnitData)
	SendCommunication(CON.Network.Message.UnitData, MessageData, "CHANNEL", CON.Network.ChannelID)
end

function CON:BroadcastStatus()
	CON:Info(LogCategory, "Broadcasting status request on channel [%d]", CON.Network.ChannelID)
	SendCommunication(CON.Network.Message.Status, DB.Data.RealmName, "CHANNEL", CON.Network.ChannelID)
end

function CON:WhisperUnitData(UnitData, Target)
	CON:Info(LogCategory, "Whispering data for [%s] to [%s]", UnitData.Unit, Target)
	local MessageData = CON:EncodeUnitData(UnitData)
	SendCommunication(CON.Network.Message.UnitData, MessageData, "WHISPER", Target)
end