local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'RealmCollection'
local LogCategory = 'GCRealm'

RealmCollection = {}

function RealmCollection:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or 
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(_typeof == 'table') then
        Object = inObject
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject == true) then
		self._Key = nil
        self._Realms = {}
		self._RealmCount = 0
		self._Initialized = false
    end

    return Object
end

function RealmCollection:IsInitialized(inBoolean)
    assert(inInitialized == nil or type(inInitialized) == 'boolean', "argument needs to be nil or boolean")
    if(inInitialized ~= nil) then
        self._Initialized = inInitialized
    end
	return self._Initialized
end

function RealmCollection:Initialize()
	if(self:IsInitialized() == false) then
        self:SetKey(math.GenerateUID())
		local _Realm = Realm:new()
		_Realm:SetKey(GetRealmName())
		_Realm:SetName(GetRealmName())
		self:AddRealm(_Realm)
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function RealmCollection:Print()
	CON:DoubleLine(LogCategory)
	CON:Debug(LogCategory, ObjectName .. " Object")
	CON:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
	CON:Debug(LogCategory, "  _RealmCount (" .. type(self._RealmCount) .. "): ".. tostring(self._RealmCount))
	CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
	for _, _Realm in pairs (self._Realms) do
		_Realm:ShallowPrint()
	end
end

function RealmCollection:GetKey()
    return self._Key
end

function RealmCollection:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function RealmCollection:Contains(inKey)
	assert(type(inKey) == 'string')
	return self._Realms[inKey] ~= nil
end

function RealmCollection:GetRealm(inKey)
	assert(type(inKey) == 'string')
	return self._Realms[inKey]
end

function RealmCollection:GetCurrentRealm()
	return self._Realms[GetRealmName()]
end

function RealmCollection:AddRealm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', "argument must be Realm object")
	if(inRealm:IsInitialized() == false) then
		inRealm:Initialize()
	end
	if(self:Contains(inRealm:GetKey()) == false) then
		self._RealmCount = self._RealmCount + 1
	end
	self._Realms[inRealm:GetKey()] = inRealm
	return self:Contains(inRealm:GetKey())
end

function RealmCollection:AddUnit(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name ~= nil and inUnit.__name == 'Unit', "argument must be Unit object")

    if(self:Contains(inUnit:GetRealmName()) == false) then 
		local _NewRealm = Realm:new()
		_NewRealm:SetKey(inUnit:GetRealmName())
		_NewRealm:SetName(inUnit:GetRealmName())
		_NewRealm:Initialize()
		self:AddRealm(_NewRealm)
    end

	local _Realm = self:GetRealm(inUnit:GetRealmName())
	_Realm:AddUnit(inUnit)

    return true
end