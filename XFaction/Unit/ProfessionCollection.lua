local XFG, G = unpack(select(2, ...))

ProfessionCollection = ObjectCollection:newChildConstructor()

function ProfessionCollection:new()
	local _Object = ProfessionCollection.parent.new(self)
	_Object.__name = 'ProfessionCollection'
    return _Object
end

function ProfessionCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for _, _Profession in XFG.Lib.Profession:Iterator() do
			local _NewProfession = Profession:new()
			_NewProfession:SetID(_Profession.ID)
			_NewProfession:SetIconID(_Profession.Icon)
			_NewProfession:SetName(_Profession.Name)
			_NewProfession:SetKey(_Profession.ID)
			self:AddObject(_NewProfession)
			XFG:Info(self:GetObjectName(), 'Initialized profession [%s]', _NewProfession:GetName())
		end	
		self:IsInitialized(true)
	end
end