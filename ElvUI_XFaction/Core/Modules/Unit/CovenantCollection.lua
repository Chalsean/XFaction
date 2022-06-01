local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'CCovenant'
local LogCategory = 'UCCovenant'
local MaxRaces = 37

CovenantCollection = {}

function CovenantCollection:new(_Argument)
    local _typeof = type(_Argument)
    local _newObject = true

	assert(_Argument == nil or 
	      (_typeof == 'table' and _Argument.__name ~= nil and _Argument.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(_typeof == 'table') then
        Object = _Argument
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject == true) then
        self._Covenants = {}
		self._CovenantCount = 0
		self._Initialized = false
    end

    return Object
end

function CovenantCollection:Initialize()
	if(self._Initialized == false) then
		for _, _CovenantID in pairs (C_Covenants.GetCovenantIDs()) do
			local _NewCovenant = Covenant:new()
			_NewCovenant:SetID(_CovenantID)
			_NewCovenant:Initialize()
			if(self:Contains(_NewCovenant:GetKey()) == false) then
				self._Covenants[_NewCovenant:GetKey()] = _NewCovenant
				self._CovenantCount = self._CovenantCount + 1
			end
		end
		self._Initialized = true
	end
	return self._Initialized
end

function CovenantCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _CovenantCount (" .. type(self._CovenantCount) .. "): ".. tostring(self._CovenantCount))
	XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
	for _, _Covenant in pairs (self._Covenants) do
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

function CovenantCollection:AddCovenant(_Covenant)
    assert(type(_Covenant) == 'table' and _Covenant.__name ~= nil and _Covenant.__name == 'Covenant', "argument must be Covenant object")
	if(self:Contains(_Covenant:GetKey()) == false) then
		self._CovenantCount = self._CovenantCount + 1
	end
	self._Covenants[_Covenant:GetKey()] = _Covenant
	return self:Contains(_Covenant:GetKey())
end

function CovenantCollection:GetCovenants()
	return self._Covenants
end

function CovenantCollection:Iterator()
	return next, self._Covenants, nil
end