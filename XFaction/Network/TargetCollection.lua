local XFG, G = unpack(select(2, ...))
local ObjectName = 'TargetCollection'

TargetCollection = ObjectCollection:newChildConstructor()

function TargetCollection:new()
	local _Object = TargetCollection.parent.new(self)
	_Object.__name = ObjectName
    return _Object
end

local function GetTargetKey(inRealm, inFaction)
	assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', "argument must be Realm object")
    assert(type(inFaction) == 'table' and inFaction.__name ~= nil and inFaction.__name == 'Faction', "argument must be Faction object")
	return inRealm:GetID() .. ':' .. inFaction:GetID()
end

function TargetCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for _, _Guild in XFG.Guilds:Iterator() do
			local _Realm = _Guild:GetRealm()
			local _Faction = _Guild:GetFaction()
			local _Key = GetTargetKey(_Realm, _Faction)
			local _NewTarget = Target:new()
			_NewTarget:SetKey(_Key)
			_NewTarget:SetRealm(_Realm)
			_NewTarget:SetFaction(_Faction)
			
			if(not self:Contains(_NewTarget:GetKey())) then	
				XFG:Info(ObjectName, 'Initializing target [%s]', _Key)
				self:Add(_NewTarget)
			end
			if(XFG.Player.Target == nil and _Realm:Equals(XFG.Player.Realm) and _Faction:Equals(XFG.Player.Faction)) then
				XFG:Info(ObjectName, 'Initializing player target [%s]', _Key)
				XFG.Player.Target = _NewTarget
			end
		end
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function TargetCollection:ContainsByRealmFaction(inRealm, inFaction)
	assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', "argument must be Realm object")
    assert(type(inFaction) == 'table' and inFaction.__name ~= nil and inFaction.__name == 'Faction', "argument must be Faction object")
	local _Key = GetTargetKey(inRealm, inFaction)
    return self:Contains(_Key)
end

function TargetCollection:GetByRealmFaction(inRealm, inFaction)
	assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', "argument must be Realm object")
    assert(type(inFaction) == 'table' and inFaction.__name ~= nil and inFaction.__name == 'Faction', "argument must be Faction object")
	local _Key = GetTargetKey(inRealm, inFaction)
    return self:Get(_Key)
end