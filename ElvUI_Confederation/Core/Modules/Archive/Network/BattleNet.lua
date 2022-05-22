local CON, E, L, V, P, G = unpack(select(2, ...))
local DB = E.db.Confederation
local LogCategory = 'MBnet'
local Initialized = false

local function CallbackBNet(Event, MessageType, Message, CommType, SenderID)
	if(MessageType == DB.Network.Message.BNet) then

		CON:Info(LogCategory, "Received BNet communication [%s][%s][%s]", Event, CommType, 'Chalsean#1172')

		local UnitData = CON:DecodeUnitData(Message)
		CON:DataDumper(LogCategory, UnitData)

		if(UnitData.Online == true) then
			CON:AddGuildMember(UnitData)
		else
			CON:RemoveGuildMember(UnitData)
		end
	end
end

local function CallbackBNetFriendsChanged()
	Initialize()
	local friends = BNGetNumFriends()
	wipe(DB.Data.Network.BNet.Friends)
	for i = 1, BNGetNumFriends() do
		local AccountInfo = C_BattleNet.GetFriendAccountInfo(i)
		if(AccountInfo ~= nil and
		   AccountInfo.isFriend == true and 
		   AccountInfo.gameAccountInfo.isOnline == true and 
		   AccountInfo.gameAccountInfo.clientProgram == "WoW") then
			if(DB.Network.BNet.Friends[AccountInfo.gameAccountInfo.realmID] == nil) then
				DB.Network.BNet.Friends[AccountInfo.gameAccountInfo.realmID] = {}
			end

			table.insert(DB.Network.BNet.Friends[AccountInfo.gameAccountInfo.realmID], {
				AccountID = AccountInfo.gameAccountInfo.gameAccountID,
				AccountName = AccountInfo.accountName,
				BattleTag = AccountInfo.battleTag,
				RealmID = AccountInfo.gameAccountInfo.realmID
			})
		end
	end
end

local function CallbackBNetOnline()
	DB.Network.BNet.Connected = true
	-- if toggle states, may have to broadcast status request
end

local function CallbackBNetOffline()
	DB.Network.BNet.Connected = false
end

local function IdentifyPassthru(TargetRealmID)
	-- CON:Debug(LogCategory, "Friends online for given realms:")
	-- CON:DataDumper(LogCategory, DB.Data.Friends)

	if(TargetRealmID == nil or DB.Network.BNet.Friends[TargetRealmID] == nil or table.getn(DB.Network.BNet.Friends[TargetRealmID]) == 0) then
		CON:Warn(LogCategory, "No friends are online connected to target realm [%d]", TargetRealmID)
		return
	end
	
	local FriendsOnRealm = DB.Network.BNet.Friends[TargetRealmID]
	local RandomNumber = math.random(1, table.getn(FriendsOnRealm))
	CON:Debug(LogCategory, "Chose friend [%d] out of [%d]", RandomNumber, table.getn(FriendsOnRealm))

	return DB.Network.BNet.Friends[TargetRealmID][RandomNumber]
end

function CON:BnetUnitData(UnitData)
	if(DB.Network.BNet.Connected == true) then
		for _, TargetRealmID in pairs (DB.RealmIDs) do
			if(TargetRealmID ~= DB.Data.CurrentRealm.ID) then
				local TargetAccount = IdentifyPassthru(TargetRealmID)	
				if(TargetAccount ~= nil) then		
					CON:Info(LogCategory, "BNet whispering data for [%s] to [%d:%s] for broadcast on realm [%d]", UnitData.Unit, TargetAccount.AccountID, TargetAccount.BattleTag, TargetRealmID)
					local MessageData = CON:EncodeUnitData(UnitData)
					BNSendGameData(TargetAccount.AccountID, DB.Network.Message.BNet, "test")
				end
			end
		end
	else
		CON:Warn(LogCategory, "BNet disconnected")
	end
end

local function Initialize()
	if(Initialized == false) then
		DB.Network.BNet.Connected = BNConnected()
		CON:RegisterEvent('BN_CHAT_MSG_ADDON', CallbackBNet)
		CON:RegisterEvent('BN_FRIEND_LIST_SIZE_CHANGED', CallbackBNetFriendsChanged)
		CON:RegisterEvent('BN_FRIEND_ACCOUNT_OFFLINE', CallbackBNetFriendsChanged)
		CON:RegisterEvent('BN_FRIEND_ACCOUNT_ONLINE', CallbackBNetFriendsChanged)
		CON:RegisterEvent('BN_CONNECTED', CallbackBNetOnline)
		CON:RegisterEvent('BN_DISCONNECTED', CallbackBNetOffline)		
		Initialized = true
	end
end

do
	Initialize()	
end