local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'CClass'
local LogCategory = 'U' .. ObjectName
local MaxRaces = 37

ClassCollection = {}

function ClassCollection:new(_Argument)
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
        self._Classes = {}
		self._ClassCount = 0
		self._Initialized = false
    end

    return Object
end

function ClassCollection:Initialize()
	if(self._Initialized == false) then
		for i = 1, GetNumClasses() do
			local _ClassInfo = C_CreatureInfo.GetClassInfo(i)
			local _Class = Class:new()
			_Class:SetKey(_ClassInfo.classID)
			_Class:SetID(_ClassInfo.classID)
			_Class:SetName(_ClassInfo.className)
			_Class:SetAPIName(_ClassInfo.classFile)
			self._ClassCount = self._ClassCount + 1
			self._Classes[_Class:GetKey()] = _Class
		end
		self._Initialized = true
	end
	return self._Initialized
end

function ClassCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, "ClassCollection Object")
	XFG:Debug(LogCategory, "  _ClassCount (" .. type(self._ClassCount) .. "): ".. tostring(self._ClassCount))
	XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
	for _, _Class in pairs (self._Classes) do
		_Class:Print()
	end
end

function ClassCollection:Contains(inKey)
	assert(type(inKey) == 'number')
	return self._Classes[inKey] ~= nil
end

function ClassCollection:GetClass(inKey)
	local _typeof = type(inKey)
	assert(_typeof == 'number' or _typeof == 'string', "argument must be number or string")

	if(_typeof == 'string') then
		for _, _Class in pairs (self._Classes) do
			if(_Class:GetName() == inKey) then
				return _Class
			end
		end
	end

	return self._Classes[inKey]
end

function ClassCollection:AddClass(inClass)
    assert(type(inClass) == 'table' and inClass.__name ~= nil and inClass.__name == 'Class', "argument must be Class object")
	if(self:Contains(inClass:GetKey()) == false) then
		self._ClassCount = self._ClassCount + 1
	end
	self._Classes[inClass:GetKey()] = inClass
	return self:Contains(inClass:GetKey())
end

function ClassCollection:Iterator()
	return next, self._Classes, nil
end