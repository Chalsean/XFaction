local XFG, G = unpack(select(2, ...))
local ObjectName = 'RealmCollection'
local LogCategory = 'CCRealm'

RealmCollection = {}

function RealmCollection:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

	self._Key = nil
    self._Realms = {}
	self._RealmCount = 0
	self._Initialized = false

    return Object
end

function RealmCollection:IsInitialized(inBoolean)
    assert(inInitialized == nil or type(inInitialized) == 'boolean', 'argument needs to be nil or boolean')
    if(inInitialized ~= nil) then
        self._Initialized = inInitialized
    end
	return self._Initialized
end

function RealmCollection:Initialize()
	if(self:IsInitialized() == false) then
        self:SetKey(math.GenerateUID())
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function RealmCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. ' Object')
	XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
	XFG:Debug(LogCategory, '  _RealmCount (' .. type(self._RealmCount) .. '): ' .. tostring(self._RealmCount))
	XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
	for _, _Realm in pairs (self._Realms) do
		_Realm:Print()
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

function RealmCollection:GetRealmByID(inID)
	assert(type(inID) == 'number')
	for _, _Realm in self:Iterator() do
		local _IDs = _Realm:GetIDs()
		for _, _ID in pairs (_IDs) do
			if(_ID == inID) then
				return _Realm
			end
		end
	end
end

function RealmCollection:GetCurrentRealm()
	return self._Realms[GetRealmName()]
end

function RealmCollection:AddRealm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', 'argument must be Realm object')
	if(self:Contains(inRealm:GetKey()) == false) then
		self._RealmCount = self._RealmCount + 1
	end
	self._Realms[inRealm:GetKey()] = inRealm
	return self:Contains(inRealm:GetKey())
end

function RealmCollection:Iterator()
	return next, self._Realms, nil
end

function RealmCollection:GetNumberOfRealms()
	return self._RealmCount
end