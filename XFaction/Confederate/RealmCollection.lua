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
		local _Lib = LibStub:GetLibrary('LibRealm')
		for _ID, _Data in pairs(_Lib:GetAllRealms()) do
			local _Realm = Realm:new()
			_Realm:SetKey(_Data.Name)
			_Realm:SetName(_Data.Name)
			_Realm:SetAPIName(_Data.API)
			_Realm:SetIDs(_Data.IDs)
			XFG.Realms:Add(_Realm)
		end
		self:IsInitialized(true)
	end
end

function RealmCollection:GetByID(inID)
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