local XFG, E, L, V, P, G = unpack(select(2, ...))
local DB = E.db.Confederation
local LogCategory = 'NBnet'
local Initialized = false

-- local function CallbackBNet(Event, MessageType, ...)
-- 	local EncodedMessage = {...}
-- 	XFG:Error(LogCategory, "event trigger [%s][%s]", event, sender)

-- 	-- if(MessageType == XFG.Network.Message.BNet) then
-- 	-- 	local UnitData = XFG:DecodeUnitData(EncodedMessage)
-- 	-- 	XFG:DataDumper(LogCategory, UnitData)
-- 	-- end
-- end

local function Initialize()
	if(Initialized == false) then
		if(DB.Data.Friends == nil) then
			DB.Data.Friends = {}
		end
		XFG:RegisterEvent('BN_CHAT_MSG_ADDON', CallbackBNet)
	end
end

function XFG:ScanFriends()
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
	XFG:ScanFriends()
	XFG:DataDumper(LogCategory, DB.Data.Friends)

	if(TargetRealmID == nil or DB.Data.Friends[TargetRealmID] == nil or table.getn(DB.Data.Friends[TargetRealmID]) == 0) then
		XFG:Warn(LogCategory, "No friends are online connected to target realm [%d]", TargetRealmID)
		return
	end
	
	local FriendsOnRealm = DB.Data.Friends[TargetRealmID]
	local RandomNumber = math.random(1, table.getn(FriendsOnRealm))
	XFG:Debug(LogCategory, "Chose friend [%d] out of [%d]", RandomNumber, table.getn(FriendsOnRealm))

	return DB.Data.Friends[TargetRealmID][RandomNumber]
end

function XFG:BnetUnitData(UnitData)
	for _, TargetRealmID in pairs (DB.RealmIDs) do
		if(TargetRealmID ~= DB.Data.CurrentRealm.ID) then
			local TargetAccount = IdentifyPassthru(TargetRealmID)	
			if(TargetAccount ~= nil) then		
				XFG:Info(LogCategory, "BNet whispering data for [%s] to [%d:%s] for broadcast on realm [%d]", UnitData.Unit, TargetAccount.AccountID, TargetAccount.BattleTag, TargetRealmID)
				local MessageData = XFG:EncodeUnitData(UnitData)
				BNSendGameData(TargetAccount.AccountID, 'XFG_BNET_DATA', "test")
			end
		end
	end
end