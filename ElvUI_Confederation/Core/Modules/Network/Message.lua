local CON, E, L, V, P, G = unpack(select(2, ...))
local DB = E.db.Confederation
local LogCategory = 'MMessage'
local Initialized = false

local function ProcessDataMessage(Message, Sender)

	local UnitData = CON:DecodeUnitData(Message)
	--CON:DataDumper(LogCategory, UnitData)

    -- Ignore if it's your own message (unfortunately there's no realm name attached)
	if(DB.Data.Player.Name == Sender) then
		return
	end

	-- It's about you, sender needs current information
	if(UnitData.GUID == DB.PlayerGUID) then
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

function CON:OnCommReceived(MessageType, Message, Distribution, Sender)
	
	--CON:Debug(LogCategory, "Message received [%s][%s][%s]", MessageType, Distribution, Sender)

	if(MessageType == CON.Network.Message.UnitData) then
		ProcessDataMessage(Message, Sender)
	elseif(MessageType == CON.Network.Message.Status) then
		ProcessStatusMessage(Message, Sender)
	else
		CON:Warning(LogCategory, "Received unknown message type [%s] from [%s] over [%s]", MessageType, Sender, Distribution)
	end	
end

function CON:InitializeComm()
	if(Initialized == false) then
		for Key, Value in pairs (CON.Network.Message) do
			CON:Info(LogCategory, format("Registering to receive [%s] messages", CON.Network.Message[Key]))
			self:RegisterComm(CON.Network.Message[Key])
		end
		Initialized = true
	end
end