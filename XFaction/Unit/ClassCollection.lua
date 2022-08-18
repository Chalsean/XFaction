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
			self:AddObject(_NewClass)
			XFG:Info(ObjectName, 'Initialized class [%s]', _NewClass:GetName())
		end
		self:IsInitialized(true)
	end
end

function ClassCollection:GetClassByAPIName(inAPIName)
	assert(type(inAPIName) == 'string')
	for _, _Class in self:Iterator() do
		if(_Class:GetAPIName() == inAPIName) then
			return _Class
		end
	end
end

function ClassCollection:GetClassByName(inName)
	assert(type(inName) == 'string')
	for _, _Class in self:Iterator() do
		if(_Class:GetName() == inName) then
			return _Class
		end
	end
end