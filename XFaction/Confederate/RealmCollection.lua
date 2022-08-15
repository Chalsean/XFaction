local XFG, G = unpack(select(2, ...))

RealmCollection = ObjectCollection:newChildConstructor()

function RealmCollection:new()
	local _Object = RealmCollection.parent.new(self)
	_Object.__name = 'RealmCollection'
    return _Object
end

function RealmCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for _ID, _Data in pairs(XFG.Lib.Realm:GetAllRealms()) do
			local _Realm = Realm:new()
			_Realm:SetKey(_Data.Name)
			_Realm:SetName(_Data.Name)
			_Realm:SetAPIName(_Data.API)
			_Realm:SetIDs(_Data.IDs)
			XFG.Realms:AddObject(_Realm)
		end		
		self:IsInitialized(true)
	end
	return self:IsInitialized()
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
	return self._Objects[GetRealmName()]
end