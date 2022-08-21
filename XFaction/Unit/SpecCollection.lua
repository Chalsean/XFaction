local XFG, G = unpack(select(2, ...))
local ObjectName = 'SpecCollection'

SpecCollection = ObjectCollection:newChildConstructor()

function SpecCollection:new()
    local _Object = SpecCollection.parent.new(self)
	_Object.__name = ObjectName
    return _Object
end

function SpecCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		local _Lib = LibStub('LibSpec')
		for _, _Spec in _Lib:Iterator() do
			local _NewSpec = Spec:new()
			_NewSpec:SetID(_Spec.ID)
			_NewSpec:SetKey(_Spec.ID)
			_NewSpec:SetName(_Spec.Name)
			_NewSpec:SetIconID(_Spec.Icon)
			self:Add(_NewSpec)
			XFG:Info(ObjectName, 'Initialized spec [%s]', _NewSpec:GetName())
		end
		self:IsInitialized(true)
	end
end