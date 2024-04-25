local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'TargetCollection'

XFC.TargetCollection = XFC.Factory:newChildConstructor()

--#region Constructors
function XFC.TargetCollection:new()
	local object = XFC.TargetCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

function XFC.TargetCollection:NewObject()
	return XFC.Target:new()
end

local function TargetKey(inRealm, inFaction)
	assert(type(inRealm) == 'table' and inRealm.__name == 'Realm', 'argument must be Realm object')
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction', 'argument must be Faction object')
	return inRealm:ID() .. '-' .. inFaction:Key()
end

function XFC.TargetCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for _, guild in XFO.Guilds:Iterator() do
			local realm = guild:Realm()
			for _, faction in XFO.Factions:Iterator() do
				if(faction:IsAlliance() or faction:IsHorde()) then
					local key = TargetKey(realm, faction)
					
					if(not self:Contains(key)) then	
						XF:Info(ObjectName, 'Initializing target [%s]', key)
						local target = self:Pop()
						target:Key(key)
						target:Realm(realm)
						target:Faction(faction)
						self:Add(target)
						realm:IsTargeted(true)
						target:Print()

						if(XF.Player.Target == nil and realm:Equals(XF.Player.Realm) and faction:Equals(XF.Player.Faction)) then
							XF:Info(self:ObjectName(), 'Initializing player target [%s]', target:Key())
							XF.Player.Target = target
						end
					end
				end
			end
		end
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end
--#endregion

--#region Methods
function XFC.TargetCollection:Contains(inRealm, inFaction)
	assert(type(inRealm) == 'table' and inRealm.__name == 'Realm' or type(inRealm) == 'string', 'argument must be Realm object or string')
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction' or inFaction == nil, 'argument must be Faction object or nil')
	local key = inFaction ~= nil and TargetKey(inRealm, inFaction) or inRealm
	return self.parent.Contains(self, key)
end

function XFC.TargetCollection:Get(inRealm, inFaction)
	assert(type(inRealm) == 'table' and inRealm.__name == 'Realm' or type(inRealm) == 'string', 'argument must be Realm object or string')
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction' or inFaction == nil, 'argument must be Faction object or nil')

	if(inFaction == nil) then
		return self.parent.Get(self, inRealm)
	else
		local key = TargetKey(inRealm, inFaction)
		if(self:Contains(key)) then 
			return self.parent.Get(self, key)
		elseif(type(inRealm) == 'table') then
			for _, connectedRealm in inRealm:ConnectedIterator() do
				key = TargetKey(connectedRealm, inFaction)
    			if(self:Contains(key)) then 
					return self.parent.Get(self, key) 
				end
			end
		end
	end
end
--#endregion