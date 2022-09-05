local XFG, G = unpack(select(2, ...))
local ObjectName = 'RealmCollection'

RealmCollection = ObjectCollection:newChildConstructor()

function RealmCollection:new()
	local object = RealmCollection.parent.new(self)
	object.__name = 'RealmCollection'
    return object
end

-- Realm information comes from disk, so no need to stick in cache
function RealmCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		local lib = LibStub:GetLibrary('LibRealm')
		for ID, data in pairs(lib:GetAllRealms()) do
			local realm = Realm:new()
			realm:SetKey(data.Name)
			realm:SetName(data.Name)
			realm:SetAPIName(data.API)
			realm:SetID(ID)
			realm:SetIDs(data.IDs)
			XFG.Realms:Add(realm)
		end

		-- Setup default realms (Torghast)
		for realmID, realmName in pairs (XFG.Settings.Confederate.DefaultRealms) do
			local realm = Realm:new()
			realm:SetKey(realmName)
			realm:SetName(realmName)
			realm:SetAPIName(realmName)
			realm:SetID(realmID)
			realm:SetIDs({realmID})
			XFG.Realms:Add(realm)
		end

		self:IsInitialized(true)
	end
end

function RealmCollection:SetPlayerRealm()
	local localRealm = XFG.Realms:Get(XFG.Cache.Player.Realm)
	for _, realmID in localRealm:IDIterator() do
		local connectedRealm = XFG.Realms:GetByID(realmID)
		for _, guild in XFG.Guilds:Iterator() do
			if(guild:GetRealm():Equals(connectedRealm) and guild:GetFaction():Equals(XFG.Player.Faction)) then
				if(not localRealm:Equals(connectedRealm)) then
					XFG:Info(ObjectName, 'Switching from local realm [%s] to connected realm [%s]', localRealm:GetName(), connectedRealm:GetName())
				end
				XFG.Player.Realm = connectedRealm
				break
			end
		end
	end
	if(XFG.Player.Realm == nil) then
		error('Player is not on a supported guild or realm: ' .. tostring(XFG.Player.Cache.Realm))
	end
end

function RealmCollection:GetByID(inID)
	assert(type(inID) == 'number')
	for _, realm in self:Iterator() do
		if(realm:GetID() == inID) then
			return realm
		end
	end
end