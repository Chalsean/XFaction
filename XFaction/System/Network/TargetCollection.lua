local XF, G = unpack(select(2, ...))
local ObjectName = 'TargetCollection'

TargetCollection = ObjectCollection:newChildConstructor()

--#region Constructors
function TargetCollection:new()
	local object = TargetCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
local function GetTargetKey(inRealm, inFaction)
	assert(type(inRealm) == 'table' and inRealm.__name == 'Realm', 'argument must be Realm object')
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction', 'argument must be Faction object')
	return inRealm:GetID() .. ':' .. inFaction:GetKey()
end

function TargetCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for _, guild in XF.Guilds:Iterator() do
			local realm = guild:GetRealm()
			local faction = guild:GetFaction()
			local key = GetTargetKey(realm, faction)
			
			if(self:Contains(key)) then	
				self:Get(key):IncrementTargetCount()
			else
				XF:Info(ObjectName, 'Initializing target [%s]', key)
				local target = Target:new()
				target:SetKey(key)
				target:SetRealm(realm)
				target:SetFaction(faction)
				self:Add(target)
				realm:IsTargeted(true)
				target:Print()

				if(XF.Player.Target == nil and realm:Equals(XF.Player.Guild:GetRealm()) and faction:Equals(XF.Player.Faction)) then
					XF:Info(ObjectName, 'Initializing player target [%s]', key)
					XF.Player.Target = target
				end
			end
		end
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end
--#endregion

--#region Hash
function TargetCollection:GetByRealmFaction(inRealm, inFaction)
	assert(type(inRealm) == 'table' and inRealm.__name == 'Realm', 'argument must be Realm object')
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction', 'argument must be Faction object')
	local key = GetTargetKey(inRealm, inFaction)
    if(self:Contains(key)) then return self:Get(key) end
	for _, connectedRealm in inRealm:ConnectedIterator() do
		local key = GetTargetKey(connectedRealm, inFaction)
    	if(self:Contains(key)) then return self:Get(key) end
	end
end

function TargetCollection:GetByGuild(inGuild)
    assert(type(inGuild) == 'table' and inGuild.__name == 'Guild', 'argument must be Guild object')
	return self:GetByRealmFaction(inGuild:GetRealm(), inGuild:GetFaction())
end
--#endregion