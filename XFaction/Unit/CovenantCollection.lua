local XFG, G = unpack(select(2, ...))
local ObjectName = 'CovenantCollection'

CovenantCollection = ObjectCollection:newChildConstructor()

function CovenantCollection:new()
	local _Object = CovenantCollection.parent.new(self)
	_Object.__name = ObjectName
    return _Object
end

function CovenantCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for _, _CovenantID in pairs (C_Covenants.GetCovenantIDs()) do
			local _NewCovenant = Covenant:new()
			_NewCovenant:SetID(_CovenantID)
			_NewCovenant:Initialize()
			self:Add(_NewCovenant)
			XFG:Info(ObjectName, 'Initialized covenant [%s]', _NewCovenant:GetName())
		end
		self:IsInitialized(true)
	end
end