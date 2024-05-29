local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'TargetCollection'

XFC.TargetCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.TargetCollection:new()
	local object = XFC.TargetCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

local function GetTargetKey(inRealm, inFaction)
	assert(type(inRealm) == 'table' and inRealm.__name == 'Realm')
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction')
	return inRealm:ID() .. ':' .. inFaction:Key()
end

function XFC.TargetCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for _, guild in XFO.Guilds:Iterator() do
			local realm = guild:Realm()
			local faction = guild:Faction()
			local key = GetTargetKey(realm, faction)
			
			if(not self:Contains(key)) then	
				XF:Info(self:ObjectName(), 'Initializing target [%s]', key)
				local target = XFC.Target:new()
				target:Key(key)
				target:SetRealm(realm)
				target:SetFaction(faction)
				self:Add(target)
				realm:IsTargeted(true)
				target:Print()

				if(XF.Player.Target == nil and realm:Equals(XF.Player.Realm) and faction:Equals(XF.Player.Faction)) then
					XF:Info(self:ObjectName(), 'Initializing player target [%s]', key)
					XF.Player.Target = target
				end
			end
		end
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end
--#endregion

--#region Methods
function XFC.TargetCollection:Get(inObject, inFaction)
    assert(type(inObject) == 'table' and inObject == 'Realm' or type(inObject) == 'string' or type(inObject) == 'number')
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction' or type(inFaction) == 'number' or inFaction == nil)

    if(inFaction ~= nil) then
        local realm = type(inObject) == 'table' and inObject or XFO.Realms:Get(inObject)
        local faction = type(inFaction) == 'table' and inFaction or XFO.Factions:Get(inFaction)
        local key = GetTargetKey(realm, faction)

		if(self:Contains(key)) then 
            return self.parent.Get(self, key)
        else
            for _, connectedRealm in realm:ConnectedIterator() do
                local key = GetTargetKey(connectedRealm, faction)
                if(self:Contains(key)) then 
                    return self.parent.Get(self, key) 
                end
            end
        end
    end

    return self.parent.Get(self, inObject)
end
--#endregion