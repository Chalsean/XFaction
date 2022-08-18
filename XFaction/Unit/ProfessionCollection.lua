local XFG, G = unpack(select(2, ...))
local ObjectName = 'ProfessionCollection'

ProfessionCollection = ObjectCollection:newChildConstructor()

function ProfessionCollection:new()
	local _Object = ProfessionCollection.parent.new(self)
	_Object.__name = ObjectName
    return _Object
end

function ProfessionCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		local _Lib = LibStub('LibProfession')
		for _, _Profession in _Lib:Iterator() do
			local _NewProfession = Profession:new()
			_NewProfession:SetID(_Profession.ID)
			_NewProfession:SetIconID(_Profession.Icon)
			_NewProfession:SetName(_Profession.Name)
			_NewProfession:SetKey(_Profession.ID)
			self:AddObject(_NewProfession)
			XFG:Info(ObjectName, 'Initialized profession [%s]', _NewProfession:GetName())
		end	
		self:IsInitialized(true)
	end
end