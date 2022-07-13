local XFG, G = unpack(select(2, ...))
local ObjectName = 'TargetCollection'
local LogCategory = 'NCTarget'

TargetCollection = {}

function TargetCollection:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Targets = {}
    self._TargetCount = 0
    self._Initialized = false

    return _Object
end

local function GetTargetKey(inRealm, inFaction)
	assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', "argument must be Realm object")
    assert(type(inFaction) == 'table' and inFaction.__name ~= nil and inFaction.__name == 'Faction', "argument must be Faction object")
	return inRealm:GetID() .. ':' .. inFaction:GetID()
end

function TargetCollection:Initialize()
	if(self:IsInitialized() == false) then
		self:SetKey(math.GenerateUID())
		for _, _Guild in XFG.Guilds:Iterator() do
			local _Realm = _Guild:GetRealm()
			local _Faction = _Guild:GetFaction()
			local _Key = GetTargetKey(_Realm, _Faction)
			local _NewTarget = Target:new()
			_NewTarget:SetKey(_Key)
			_NewTarget:SetRealm(_Realm)
			_NewTarget:SetFaction(_Faction)
			
			if(not self:ContainsByKey(_NewTarget:GetKey())) then	
				XFG:Debug(LogCategory, 'Initializing target [%s]', _Key)
				self:AddTarget(_NewTarget)
			end
			if(_Realm:Equals(XFG.Player.Realm) and _Faction:Equals(XFG.Player.Faction)) then
				XFG:Debug(LogCategory, 'Initializing player target [%s]', _Key)
				XFG.Player.Target = _NewTarget
			end
		end
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function TargetCollection:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function TargetCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
	XFG:Debug(LogCategory, "  _TargetCount (" .. type(self._TargetCount) .. "): ".. tostring(self._TargetCount))
	XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
    for _, _Target in self:Iterator() do
        _Target:Print()
    end
end

function TargetCollection:GetKey()
    return self._Key
end

function TargetCollection:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function TargetCollection:Contains(inRealm, inFaction)
	assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', "argument must be Realm object")
    assert(type(inFaction) == 'table' and inFaction.__name ~= nil and inFaction.__name == 'Faction', "argument must be Faction object")
	local _Key = GetTargetKey(inRealm, inFaction)
    return self:ContainsByKey(_Key)
end

function TargetCollection:ContainsByKey(inKey)
	assert(type(inKey) == 'string')
    return self._Targets[inKey] ~= nil
end

function TargetCollection:GetTarget(inRealm, inFaction)
	assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', "argument must be Realm object")
    assert(type(inFaction) == 'table' and inFaction.__name ~= nil and inFaction.__name == 'Faction', "argument must be Faction object")
	local _Key = GetTargetKey(inRealm, inFaction)
    return self._Targets[_Key]
end

function TargetCollection:GetTargetByKey(inKey)
	assert(type(inKey) == 'string')
    return self._Targets[inKey]
end

function TargetCollection:AddTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name ~= nil and inTarget.__name == 'Target', "argument must be Target object")
	if(self:ContainsByKey(inTarget:GetKey()) == false) then
		self._TargetCount = self._TargetCount + 1
	end
    self._Targets[inTarget:GetKey()] = inTarget
    return self:ContainsByKey(inTarget:GetKey())
end

function TargetCollection:Iterator()
	return next, self._Targets, nil
end

function TargetCollection:GetCount()
	return self._TargetCount
end