local CON, E, L, V, P, G = unpack(select(2, ...))
local DB = E.db.Confederation
local LogCategory = 'MBnet'
local Initialized = false

local function CallbackBNet(Event, MessageType, ...)
	local EncodedMessage = {...}
	CON:Error(LogCategory, "event trigger [%s][%s]", event, sender)

	-- if(MessageType == CON.Network.Message.BNet) then
	-- 	local UnitData = CON:DecodeUnitData(EncodedMessage)
	-- 	CON:DataDumper(LogCategory, UnitData)
	-- end
end

local function Initialize()
	if(Initialized == false) then
		if(DB.Data.Friends == nil) then
			DB.Data.Friends = {}
		end
		CON:RegisterEvent('BN_CHAT_MSG_ADDON', CallbackBNet)
	end
end

function CON:ScanFriends()
	Initialize()
	local friends = BNGetNumFriends()
	wipe(DB.Data.Friends)
	for i = 1, BNGetNumFriends() do
		local AccountInfo = C_BattleNet.GetAccountInfoByID(i)
		if(AccountInfo ~= nil and
		   AccountInfo.isFriend == true and 
		   AccountInfo.gameAccountInfo.isOnline == true and 
		   AccountInfo.gameAccountInfo.clientProgram == "WoW") then
			if(DB.Data.Friends[AccountInfo.gameAccountInfo.realmID] == nil) then
				DB.Data.Friends[AccountInfo.gameAccountInfo.realmID] = {}
			end

			table.insert(DB.Data.Friends[AccountInfo.gameAccountInfo.realmID], {
				AccountID = AccountInfo.gameAccountInfo.gameAccountID,
				AccountName = AccountInfo.accountName,
				BattleTag = AccountInfo.battleTag,
				RealmID = AccountInfo.gameAccountInfo.realmID
			})
		end
	end
end

local function IdentifyPassthru(TargetRealmID)
	CON:ScanFriends()
	CON:DataDumper(LogCategory, DB.Data.Friends)

	if(TargetRealmID == nil or DB.Data.Friends[TargetRealmID] == nil or table.getn(DB.Data.Friends[TargetRealmID]) == 0) then
		CON:Warn(LogCategory, "No friends are online connected to target realm [%d]", TargetRealmID)
		return
	end
	
	local FriendsOnRealm = DB.Data.Friends[TargetRealmID]
	local RandomNumber = math.random(1, table.getn(FriendsOnRealm))
	CON:Debug(LogCategory, "Chose friend [%d] out of [%d]", RandomNumber, table.getn(FriendsOnRealm))

	return DB.Data.Friends[TargetRealmID][RandomNumber]
end

function CON:BnetUnitData(UnitData)
	for _, TargetRealmID in pairs (DB.RealmIDs) do
		if(TargetRealmID ~= DB.Data.CurrentRealm.ID) then
			local TargetAccount = IdentifyPassthru(TargetRealmID)	
			if(TargetAccount ~= nil) then		
				CON:Info(LogCategory, "BNet whispering data for [%s] to [%d:%s] for broadcast on realm [%d]", UnitData.Unit, TargetAccount.AccountID, TargetAccount.BattleTag, TargetRealmID)
				local MessageData = CON:EncodeUnitData(UnitData)
				BNSendGameData(TargetAccount.AccountID, 'CON_BNET_DATA', "test")
			end
		end
	end
end