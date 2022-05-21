local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'CSpec'
local LogCategory = 'O' .. ObjectName

SpecCollection = {}
local _SpecIDs = {
	250,
	251,
	252,
	577,
	581,
	102,
	103,
	104,
	105,
	253,
	254,
	255,
	62,
	63,
	64,
	268,
	269,
	270,
	65,
	66,
	70,
	256,
	257,
	258,
	259,
	260,
	261,
	262,
	263,
	264,
	265,
	266,
	267,
	71,
	72,
	73
}

function SpecCollection:new(_Argument)
    local _typeof = type(_Argument)
    local _newObject = true

	assert(_Argument == nil or _typeof == 'string' or
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

    if(_newObject) then
        self._Specs = {}
		self._SpecCount = 0
		self._Initialized = false
    end

    return Object
end

function SpecCollection:Initialize()
	if(self:IsInitialized() == false) then
		for _, _SpecID in pairs (_SpecIDs) do
			local _id, _name, _, _icon, _, _, _class = GetSpecializationInfoByID(_SpecID)
			if(_Argument == nil or (_typeof == 'string' and _Argument == _class)) then
				local _Spec = Spec:new()
				_Spec:SetID(_id)
				_Spec:Initialize()
				self._Specs[_Spec:GetID()] = _Spec
				self._SpecCount = self._SpecCount + 1
			end
		end
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function SpecCollection:IsInitialized(_Argument)
    assert(_Argument == nil or type(_Argument) == 'boolean', "argument needs to be nil or boolean")
    if(type(_Argument) == 'boolean') then
        self._Initialized = _Argument
    end
    return self._Initialized
end

function SpecCollection:Print()
	CON:DoubleLine(LogCategory)
	CON:Debug(LogCategory, "SpecCollection Object")
	CON:Debug(LogCategory, "  _SpecCount (" .. type(self._SpecCount) .. "): ".. tostring(self._SpecCount))
	CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
	CON:Debug(LogCategory, "  _Specs (" .. type(self._Specs) .. "): ")
	for _, _Spec in pairs (self._Specs) do
		_Spec:Print()
	end
end

function SpecCollection:GetSpec(_Argument)
	local _typeof = type(_Argument)
	assert(_typeof == 'string' or _typeof == 'number', "argument must be string or number")

	if(_typeof == 'string') then
		for i = 1, self._SpecCount do
			local _Spec = self._Specs[i]
			if(_Spec:GetName() == _Argument) then
				return _Spec
			end
		end
	end
	
    return self._Specs[_Argument]
end