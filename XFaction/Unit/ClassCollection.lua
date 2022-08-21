local XFG, G = unpack(select(2, ...))
local ObjectName = 'ClassCollection'

ClassCollection = ObjectCollection:newChildConstructor()

function ClassCollection:new()
	local _Object = ClassCollection.parent.new(self)
	_Object.__name = ObjectName
    return _Object
end

function ClassCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		local _Lib = LibStub('LibClass')
		for _, _Class in _Lib:Iterator() do
			local _NewClass = Class:new()
			_NewClass:Initialize()
			_NewClass:SetKey(_Class.ID)
			_NewClass:SetID(_Class.ID)
			_NewClass:SetName(_Class.Name)
			_NewClass:SetAPIName(_Class.API)
			_NewClass:SetRGB(_Class.R, _Class.G, _Class.B)
			_NewClass:SetHex(_Class.Hex)
			self:Add(_NewClass)
			XFG:Info(ObjectName, 'Initialized class [%s]', _NewClass:GetName())
		end
		self:IsInitialized(true)
	end
end