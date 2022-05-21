local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'CCovenant'
local LogCategory = 'O' .. ObjectName
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
			local _Covenant = Covenant:new(_CovenantID); _Covenant:Initialize()
			if(self:Contains(_Covenant) == false) then
				self._Covenants[_Covenant:GetName()] = _Covenant
				self._CovenantCount = self._CovenantCount + 1
			end
		end
		self._Initialized = true
	end
	return self._Initialized
end

function CovenantCollection:Print()
	CON:DoubleLine(LogCategory)
	CON:Debug(LogCategory, "CovenantCollection Object")
	CON:Debug(LogCategory, "  _CovenantCount (" .. type(self._CovenantCount) .. "): ".. tostring(self._CovenantCount))
	CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
	for _, _Covenant in pairs (self._Covenants) do
		_Covenant:Print()
	end
end

function CovenantCollection:Contains(_Argument)
	local _typeof = type(_Argument)
	assert(_typeof == 'string' or _typeof == 'number' or
	      (_typeof == 'table' and _Argument.__name ~= nil and _Argument.__name == 'Covenant'), 
		  "argument must be string, number or Covenant object")

	if(_typeof == 'table') then
		return self._Covenants[_Argument:GetName()] ~= nil
	elseif(_typeof == 'string') then
		return self._Covenants[_Argument] ~= nil
	else
		for _CovenantName, _Covenant in pairs (self._Covenants) do
			if(_Covenant:GetID() == _Argument) then
				return true
			end
		end
	end

	return false
end

function CovenantCollection:GetCovenant(_Argument)
	local _typeof = type(_Argument)
	assert(_typeof == 'string' or _typeof == 'number', "argument must be string or number")

	for _CovenantName, _Covenant in pairs (self._Covenants) do
		if(_typeof == 'string' and _CovenantName == _Argument) then
			return _Covenant
		elseif(_typeof == 'number' and _Covenant:GetID() == _Argument) then
			return _Covenant
		end
	end
	
    return nil
end

function CovenantCollection:AddCovenant(_Covenant)
    assert(type(_Covenant) == 'table' and _Covenant.__name ~= nil and _Covenant.__name == 'Covenant', "argument must be Covenant object")
	if(self:Contains(_Covenant) == false) then
		self._CovenantCount = self._CovenantCount + 1
	end
	self._Covenants[_Covenant:GetName()] = _Covenant
	return self:Contains(_Covenant)
end

function CovenantCollection:GetCovenants()
	return self._Covenants
end