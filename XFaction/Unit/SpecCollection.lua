local XFG, G = unpack(select(2, ...))

SpecCollection = ObjectCollection:newChildConstructor()

function SpecCollection:new()
    local _Object = SpecCollection.parent.new(self)
	_Object.__name = 'SpecCollection'
    return _Object
end

function SpecCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for _, _Spec in XFG.Lib.Spec:Iterator() do
			local _NewSpec = Spec:new()
			_NewSpec:SetID(_Spec.ID)
			_NewSpec:SetKey(_Spec.ID)
			_NewSpec:SetName(_Spec.Name)
			_NewSpec:SetIconID(_Spec.Icon)
			self:AddObject(_NewSpec)
			XFG:Info(self:GetObjectName(), 'Initialized spec [%s]', _NewSpec:GetName())
		end
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end