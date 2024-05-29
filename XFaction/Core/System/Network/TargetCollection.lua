local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'TargetCollection'

TargetCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function TargetCollection:new()
	local object = TargetCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
local function GetTarKey(inRealm, inFaction)
	assert(type(inRealm) == 'table' and inRealm.__name == 'Realm', 'argument must be Realm object')
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction', 'argument must be Faction object')
	return inRealm:ID() .. ':' .. inFaction:Key()
end

function TargetCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for _, guild in XFO.Guilds:Iterator() do
			local realm = guild:Realm()
			local faction = guild:Faction()
			local key = GetTarKey(realm, faction)
			
			if(self:Contains(key)) then	
				self:Get(key):IncrementTargetCount()
			else
				XF:Info(ObjectName, 'Initializing target [%s]', key)
				local target = Target:new()
				target:Key(key)
				target:SetRealm(realm)
				target:SetFaction(faction)
				self:Add(target)
				realm:IsTargeted(true)
				target:Print()

				if(XF.Player.Target == nil and realm:Equals(XF.Player.Realm) and faction:Equals(XF.Player.Faction)) then
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
	assert(type(inRealm) == 'number')
    assert(type(inFaction) == 'number')

	local realm = XFO.Realms:Get(inRealm)
	local faction = XFO.Factions:Get(inFaction)

	if(realm ~= nil and faction ~= nil) then
		local key = GetTarKey(realm, faction)
		if(self:Contains(key)) then return self:Get(key) end
		for _, connectedRealm in realm:ConnectedIterator() do
			local key = GetTarKey(connectedRealm, faction)
			if(self:Contains(key)) then return self:Get(key) end
		end
	end
end

function TargetCollection:GetByGuild(inGuild)
    assert(type(inGuild) == 'table' and inGuild.__name == 'Guild')
	return self:GetByRealmFaction(inGuild:Realm():ID(), inGuild:Faction():Key())
end
--#endregion