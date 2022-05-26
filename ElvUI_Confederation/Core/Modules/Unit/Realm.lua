local CON, E, L, V, P, G = unpack(select(2, ...))
local DB = E.db.Confederation.Data
local LogCategory = 'MRealm'
local Initialized = false
--local REALM = LibStub('LibRealmInfo')

local function Initialize()
	if(Initialized == false) then
		CON:Info(LogCategory, "Caching realm information")
		if(DB.Realm == nil) then
			DB.Realm = {
				Region = nil,
				RealmsByName = {},
				RealmsByID = {}
			}
		end
--		DB.Realm.Region = REALM:GetCurrentRegion()
		Initialized = true
	end
end

function CON:GetRealmID(RealmName)
	Initialize()
	if(RealmName == "Proudmoore") then
		return 5
	elseif(RealmName == "Area 52") then
		return 3676
	end
	-- if(DB.Realm.RealmsByName[RealmName] == nil) then
	-- 	local id, name, nameForAPI, rules, locale, _, region, timezone, connections, englishName, englishNameForAPI = REALM:GetRealmInfo(RealmName)
	-- 	DB.Realm.RealmsByName[name] = {
	-- 		ID = id,
	-- 		Name = name
	-- 	}
	-- 	DB.Realm.RealmsByID[id] = DB.Realm.RealmsByName[name]
	-- end
	-- return DB.Realm.RealmsByName[RealmName].RealmID
end

function CON:GetRealmName(RealmID)
	Initialize()
	if(RealmID == 5) then
		return "Proudmoore"
	elseif(RealmID == 3676) then
		return "Area 52"
	end
	-- if(DB.Realm.RealmsByID[RealmID] == nil) then
	-- 	local id, name, nameForAPI, rules, locale, _, region, timezone, connections, englishName, englishNameForAPI = REALM:GetRealmInfoByID(RealmID)
	-- 	DB.Realm.RealmsByName[name] = {
	-- 		RealmID = id,
	-- 		RealmName = name
	-- 	}
	-- 	DB.Realm.RealmsByID[id] = DB.Realm.RealmsByName[name]
	-- end
	-- return DB.Realm.RealmsByID[RealmID].RealmName
end