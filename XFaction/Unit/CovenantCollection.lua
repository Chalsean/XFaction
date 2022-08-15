local XFG, G = unpack(select(2, ...))

CovenantCollection = ObjectCollection:newChildConstructor()

function CovenantCollection:new()
	local _Object = CovenantCollection.parent.new(self)
	_Object.__name = 'CovenantCollection'
    return _Object
end

function CovenantCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		if(XFG.WoW:IsRetail()) then
			for _, _CovenantID in pairs (C_Covenants.GetCovenantIDs()) do
				local _NewCovenant = Covenant:new()
				_NewCovenant:SetID(_CovenantID)
				_NewCovenant:Initialize()
				self:AddObject(_NewCovenant)
				XFG:Info(self:GetObjectName(), 'Initialized covenant [%s]', _NewCovenant:GetName())
			end
		end
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end