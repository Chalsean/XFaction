local XFG, G = unpack(select(2, ...))
local ObjectName = 'CCovenant'
local LogCategory = 'UCCovenant'

CovenantCollection = {}

function CovenantCollection:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Covenants = {}
	self._CovenantCount = 0
	self._Initialized = false

    return Object
end

function CovenantCollection:Initialize()
	if(not self:IsInitialized() and XFG.WoW:IsRetail()) then
		for _, _CovenantID in pairs (C_Covenants.GetCovenantIDs()) do
			local _NewCovenant = Covenant:new()
			_NewCovenant:SetID(_CovenantID)
			_NewCovenant:Initialize()
			self:AddCovenant(_NewCovenant)
			XFG:Debug(LogCategory, 'Initialized covenant [%s]', _NewCovenant:GetName())
		end
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function CovenantCollection:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function CovenantCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. ' Object')
	XFG:Debug(LogCategory, '  _CovenantCount (' .. type(self._CovenantCount) .. '): ' .. tostring(self._CovenantCount))
	XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
	for _, _Covenant in self:Iterator() do
		_Covenant:Print()
	end
end

function CovenantCollection:Contains(inKey)
	assert(type(inKey) == 'number')
	return self._Covenants[inKey] ~= nil
end

function CovenantCollection:GetCovenant(inKey)
	assert(type(inKey) == 'number')
    return self._Covenants[inKey]
end

function CovenantCollection:AddCovenant(inCovenant)
    assert(type(inCovenant) == 'table' and inCovenant.__name ~= nil and inCovenant.__name == 'Covenant', 'argument must be Covenant object')
	if(self:Contains(inCovenant:GetKey()) == false) then
		self._CovenantCount = self._CovenantCount + 1
	end
	self._Covenants[inCovenant:GetKey()] = inCovenant
	return self:Contains(inCovenant:GetKey())
end

function CovenantCollection:GetCovenants()
	return self._Covenants
end

function CovenantCollection:Iterator()
	return next, self._Covenants, nil
end