local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'SpecCollection'
local LogCategory = 'UCSpec'

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

function SpecCollection:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or _typeof == 'string' or
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(_typeof == 'table') then
        Object = inObject
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
			local _Spec = Spec:new()
			_Spec:SetID(_id)
			_Spec:Initialize()
			self._Specs[_Spec:GetKey()] = _Spec
			self._SpecCount = self._SpecCount + 1
		end
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function SpecCollection:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument needs to be nil or boolean")
    if(type(inBoolean) == 'boolean') then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function SpecCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, "SpecCollection Object")
	XFG:Debug(LogCategory, "  _SpecCount (" .. type(self._SpecCount) .. "): ".. tostring(self._SpecCount))
	XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
	XFG:Debug(LogCategory, "  _Specs (" .. type(self._Specs) .. "): ")
	for _, _Spec in pairs (self._Specs) do
		_Spec:Print()
	end
end

function SpecCollection:Contains(inKey)
	assert(type(inKey) == 'number')
    return self._Specs[inKey] ~= nil
end

function SpecCollection:GetSpec(inKey)
	assert(type(inKey) == 'number')
    return self._Specs[inKey]
end

function SpecCollection:Iterator()
	return next, self._Specs, nil
end