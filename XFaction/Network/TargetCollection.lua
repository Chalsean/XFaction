local XFG, G = unpack(select(2, ...))
local ObjectName = 'TargetCollection'

TargetCollection = ObjectCollection:newChildConstructor()

function TargetCollection:new()
	local object = TargetCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

local function GetTargetKey(inRealm, inFaction)
	assert(type(inRealm) == 'table' and inRealm.__name == 'Realm', 'argument must be Realm object')
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction', 'argument must be Faction object')
	return inRealm:GetID() .. ':' .. inFaction:GetKey()
end

function TargetCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for _, guild in XFG.Guilds:Iterator() do
			local realm = guild:GetRealm()
			local faction = guild:GetFaction()
			local key = GetTargetKey(realm, faction)
			local target = Target:new()
			target:SetKey(key)
			target:SetRealm(realm)
			target:SetFaction(faction)
			
			if(not self:Contains(target:GetKey())) then	
				XFG:Info(ObjectName, 'Initializing target [%s]', key)
				self:Add(target)
			end
			if(XFG.Player.Target == nil and realm:Equals(XFG.Player.Realm) and faction:Equals(XFG.Player.Faction)) then
				XFG:Info(ObjectName, 'Initializing player target [%s]', key)
				XFG.Player.Target = target
			end
		end
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function TargetCollection:ContainsByRealmFaction(inRealm, inFaction)
	assert(type(inRealm) == 'table' and inRealm.__name == 'Realm', 'argument must be Realm object')
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction', 'argument must be Faction object')
	local key = GetTargetKey(inRealm, inFaction)
    return self:Contains(key)
end

function TargetCollection:GetByRealmFaction(inRealm, inFaction)
	assert(type(inRealm) == 'table' and inRealm.__name == 'Realm', 'argument must be Realm object')
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction', 'argument must be Faction object')
	local key = GetTargetKey(inRealm, inFaction)
    return self:Get(key)
end