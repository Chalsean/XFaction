local XFG, G = unpack(select(2, ...))
local ObjectName = 'SpecCollection'
local LogCategory = 'UCSpec'

SpecCollection = {}

function SpecCollection:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Specs = {}
	self._SpecCount = 0
	self._Initialized = false

    return Object
end

function SpecCollection:Initialize()
	if(self:IsInitialized() == false) then
		for _, _Spec in XFG.Lib.Spec:Iterator() do
			local _NewSpec = Spec:new()
			_NewSpec:SetID(_Spec.ID)
			_NewSpec:SetKey(_Spec.ID)
			_NewSpec:SetName(_Spec.Name)
			_NewSpec:SetIconID(_Spec.Icon)
			self:AddSpec(_NewSpec)
			XFG:Debug(LogCategory, 'Initialized spec [%s]', _NewSpec:GetName())
		end
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function SpecCollection:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(type(inBoolean) == 'boolean') then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function SpecCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. ' Object')
	XFG:Debug(LogCategory, '  _SpecCount (' .. type(self._SpecCount) .. '): ' .. tostring(self._SpecCount))
	XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
	for _, _Spec in self:Iterator() do
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

function SpecCollection:AddSpec(inSpec)
    assert(type(inSpec) == 'table' and inSpec.__name ~= nil and inSpec.__name == 'Spec', 'argument must be Spec object')
	if(self:Contains(inSpec:GetKey()) == false) then
		self._SpecCount = self._SpecCount + 1
	end		
	self._Specs[inSpec:GetKey()] = inSpec
	return self:Contains(inSpec:GetKey())
end

function SpecCollection:Iterator()
	return next, self._Specs, nil
end